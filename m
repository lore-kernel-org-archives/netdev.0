From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: e1000 full-duplex TCP performance well below wire speed
Date: Wed, 30 Jan 2008 06:23:12 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1501667129-339840207-1201695792=:6391"
Cc: Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:52931 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758838AbYA3NUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 08:20:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1501667129-339840207-1201695792=:6391
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

(Pádraig Brady has suggested that I post this to Netdev.  It was 
originally posted to LKML here: http://lkml.org/lkml/2008/1/30/141 )


Dear NetDev,

We've connected a pair of modern high-performance boxes with integrated copper 
Gb/s Intel NICS, with an ethernet crossover cable, and have run some netperf 
full duplex TCP tests.  The transfer rates are well below wire speed.  We're 
reporting this as a kernel bug, because we expect a vanilla kernel with default 
settings to give wire speed (or close to wire speed) performance in this case. 
We DO see wire speed in simplex transfers. The behavior has been verified on 
multiple machines with identical hardware.

Details:
Kernel version: 2.6.23.12
ethernet NIC: Intel 82573L
ethernet driver: e1000 version 7.3.20-k2
motherboard: Supermicro PDSML-LN2+ (one quad core Intel Xeon X3220, Intel 3000 
chipset, 8GB memory)

The test was done with various mtu sizes ranging from 1500 to 9000, with 
ethernet flow control switched on and off, and using reno and cubic as a TCP 
congestion control.

The behavior depends on the setup. In one test we used cubic congestion 
control, flow control off. The transfer rate in one direction was above 0.9Gb/s 
while in the other direction it was 0.6 to 0.8 Gb/s. After 15-20s the rates 
flipped. Perhaps the two steams are fighting for resources. (The performance of 
a full duplex stream should be close to 1Gb/s in both directions.)  A graph of 
the transfer speed as a function of time is here: 
https://n0.aei.uni-hannover.de/networktest/node19-new20-noflow.jpg
Red shows transmit and green shows receive (please ignore other plots):

We're happy to do additional testing, if that would help, and very grateful for 
any advice!

Bruce Allen
Carsten Aulbert
Henning Fehrmann
--1501667129-339840207-1201695792=:6391--
