// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lottery {
    address public manager;
    address payable[] public players;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.1 ether, "Must be 0.01ETH to enter the lottery.");
        // add player to the players array
        players.push(payable(msg.sender));
    }

    function getPlayers() public view managerOnly returns (address payable[] memory) {
        return players;
    }

    function randomizer() internal view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players)));
    }

    function pickWinner() public managerOnly {
        require(players.length >= 3, "Must be at least 3 players.");
        uint index = randomizer() % players.length;
        address payable winner = players[index];

        // transfer smart contract's balance to winner's address
        winner.transfer(address(this).balance);

        players = new address payable[](0) ;
    }

    modifier managerOnly() {
        require(msg.sender == manager, "Can only be called by manager.");
        _;
    }
}
