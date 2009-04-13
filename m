From: Anatoly Muliarski <x86ever@gmail.com>
Subject: sky2 TX stuck problem
Date: Mon, 13 Apr 2009 10:44:07 +0300
Message-ID: <38db14850904130044y56cfb53bib0b9310dc0d7deae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53771 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbZDMHoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 03:44:09 -0400
Received: by fxm2 with SMTP id 2so1885737fxm.37
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 00:44:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I need an advice as I am in a dead end with my problem :(

I have a router on iG31 motherboard equipped with integrated Realtek
8111C chip and an extrenal PCI-E card on Marvell 88E8053. It's running
under Linux 2.6.25.17. Both network interfaces running at 1 Gbit
speed, Full-duplex, NO flow-control and connected to 2 managed
switches. eth0(r8169 driver) is connected to an upper one and
eth1(sky2 v1.21 with NAPI) to a lower one as a trunk interface( by
eth1.11 interface ).
The problem arises when there is a big input forwarding stream of
64-byte UDP packets on eth1.11 and I CAN'T transmit any packets on
this interface in response to this heavy  load. I tested it by ping
from eth1.11 - without any RX load it works fine, then heavy RX load
appears and ping stops( tcpdump shows outgoing packets but I can't see
them on the port of the managed switch( by doing port-mirroring of
this port ) - the packets must have stuck in TX ring ) and ping
packets going resume after 30(!) seconds under this heavy RX load.

What I tried:
 - the native Marvell's driver - v10.70.1.3
 - another network card on other Marvell's chip ( 88e8052)
 - another motherboard( on i945GC )

And I had the same result - Marvell's TX is stuck under heavy RX load.

BUT if I exchange Marvell and Realtek network interface( and cables
too ) transmit packets under heavy RX load on Realtek chip works fine.
The problem should be in Marvell's hardware. Is it possible to correct
it by a driver?

Additional info:
kernel: sky2 0000:01:00.0: v1.21 addr 0xe1000000 irq 16 Yukon-EC (0xb6) rev 2
kernel: sky2 eth1: addr 00:30:4f:64:72:27
kernel: sky2 eth1: enabling interface
kernel: sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control both


Settings for eth1:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full
	                        100baseT/Half 100baseT/Full
	                        1000baseT/Half 1000baseT/Full
	Advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: off
	Supports Wake-on: pg
	Wake-on: d
	Current message level: 0x000000ff (255)
	Link detected: yes
	
Offload parameters for eth1:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp segmentation offload: off
udp fragmentation offload: off
generic segmentation offload: off


Ring parameters for eth1:
Pre-set maximums:
RX:		168
RX Mini:	0
RX Jumbo:	0
TX:		511
Current hardware settings:
RX:		168
RX Mini:	0
RX Jumbo:	0
TX:		511

Coalesce parameters for eth1:
Adaptive RX: off  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 100
rx-frames: 16
rx-usecs-irq: 20
rx-frames-irq: 16

tx-usecs: 1000
tx-frames: 10
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

Pause parameters for eth1:
Autonegotiate:	off
RX:		off
TX:		off


-- 
Best regards
Anatoly Muliarski
