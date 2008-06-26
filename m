From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: s2io: packet reordering with 2.6.25.4
Date: Wed, 25 Jun 2008 20:36:25 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7703C9C91F@nekter>
References: <4862DEA4.8020305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Peter Phan" <Peter.Phan@neterion.com>
To: "Tom Quetchenbach" <virtualphtn@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:57375 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741AbYFZAg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 20:36:28 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4862DEA4.8020305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom,

We have tested udp traffic on other kernel versions and did not observe
this problem. We will reproduce this problem in our lab and let you
know.

Alternatively, you are welcome to download the driver on our website and
try.

Ram
> -----Original Message-----
> From: Tom Quetchenbach [mailto:virtualphtn@gmail.com]
> Sent: Wednesday, June 25, 2008 5:11 PM
> To: netdev@vger.kernel.org
> Cc: ram.vepa@neterion.com; Rastapur Santosh; Sivakumar Subramani;
> Sreenivasa Honnur
> Subject: s2io: packet reordering with 2.6.25.4
> 
> We've been encountering some packet reordering with our Neterion 10
> Gigabit Ethernet-SR cards using the s2io driver in linux 2.6.25.4.
> 
> We have a WAN testbed with the Neterion cards in two dual-processor
AMD
> Opteron machines; when the machines are connected back-to-back we
start
> to encounter reordering when sending UDP traffic at over 500 Mbit/s.
> (This is synthetic traffic generated with iperf, which reports how
many
> datagrams are received out-of-order.)
> 
> We also see the problem when sending iperf TCP traffic from a machine
> with an e1000 gigabit card to the Neterion card via a Cisco 7609
router.
> It seems to be related to the burstiness of the traffic, as inserting
an
> intermediate 2.5Gbit/s POS link seems to reduce the reordering, and
> inserting a gigabit ethernet link eliminates it.
> 
> We see reordering with 64-bit and 32-bit kernels, but possibly more
with
> the 32-bit kernel.
> 
> Is this a known issue? Is there anything that I can do to debug it
> further? (I'm fairly familiar with the Linux TCP stack, but pretty
much
> a newbie when it comes to debugging network device drivers.)
> 
> Thanks, and let me know if there's anything I can do to help debug,
> -Tom
> 
> Some possibly relevant information:
> 
> NAPI is enabled; LRO is disabled. The s2io module is loaded with
default
> settings.
> 
> lspci, .config, and some other info are available here:
> http://wil-ns.cs.caltech.edu/~quetchen/s2io-reordering/
> 
> After loading the s2io module, dmesg output is:
> PM: Writing back config space on device 0000:03:01.0 at offset 1 (was
> 2300142, writing 2300146)
> eth2: Enabling MSIX failed
> eth2: MSI-X requested but failed to enable
> Copyright(c) 2002-2007 Neterion Inc.
> eth2: Neterion 10 Gigabit Ethernet-SR PCI-X 2.0 DDR Adapter (rev 2)
> eth2: Driver version 2.0.26.22
> eth2: MAC ADDR: 00:0c:fc:00:0d:22
> SERIAL NUMBER: SXT0541048
> eth2: Device is on 64 bit 133MHz PCIX(M1) bus
> eth2: 1-Buffer receive mode enabled
> eth2: Interrupt type INTA
> eth2: Link down
> 
> Here's a sample of the output we see from iperf:
> [quetchen@fast-2 ~]$ iperf -usi1 -w10M
> ------------------------------------------------------------
> Server listening on UDP port 5001
> Receiving 1470 byte datagrams
> UDP buffer size: 9.54 MByte (WARNING: requested 10.0 MByte)
> ------------------------------------------------------------
> [  3] local 10.4.72.2 port 5001 connected with 10.4.72.3 port 42532
> [  3]  0.0- 1.0 sec    279 MBytes  2.34 Gbits/sec  0.004 ms
65/198856
> [  3]  0.0- 1.0 sec  65 datagrams received out-of-order
> [  3]  1.0- 2.0 sec    278 MBytes  2.33 Gbits/sec  0.004 ms
60/198413
> [  3]  1.0- 2.0 sec  60 datagrams received out-of-order
> [  3]  2.0- 3.0 sec    279 MBytes  2.34 Gbits/sec  0.004 ms
87/199063
> [  3]  2.0- 3.0 sec  87 datagrams received out-of-order
> [  3]  3.0- 4.0 sec    279 MBytes  2.34 Gbits/sec  0.004 ms
50/198882
> [  3]  3.0- 4.0 sec  50 datagrams received out-of-order
> [  3]  4.0- 5.0 sec    276 MBytes  2.32 Gbits/sec  0.004 ms
0/197179
> [  3]  5.0- 6.0 sec    270 MBytes  2.27 Gbits/sec  0.001 ms
127/192705
> [  3]  5.0- 6.0 sec  127 datagrams received out-of-order
> [  3]  6.0- 7.0 sec    279 MBytes  2.34 Gbits/sec  0.001 ms
71/198909
> [  3]  6.0- 7.0 sec  71 datagrams received out-of-order
> [  3]  7.0- 8.0 sec    277 MBytes  2.32 Gbits/sec  0.003 ms
18/197584
> [  3]  7.0- 8.0 sec  18 datagrams received out-of-order
> [  3]  8.0- 9.0 sec    280 MBytes  2.35 Gbits/sec  0.015 ms
41/199648
> [  3]  8.0- 9.0 sec  41 datagrams received out-of-order
> [  3]  0.0-10.0 sec  2.71 GBytes  2.33 Gbits/sec  0.002 ms
519/1979857
> [  3]  0.0-10.0 sec  520 datagrams received out-of-order
