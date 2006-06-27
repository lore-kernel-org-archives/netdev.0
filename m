From: "Chris A. Icide" <chris@netgeeks.net>
Subject: tg3 driver and interrupt coalescence questions
Date: Tue, 27 Jun 2006 10:16:27 -0700
Message-ID: <44A167EB.8000805@netgeeks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 68-185-24-3.static.mdfd.or.charter.com ([68.185.24.3]:53477
	"EHLO pbx.netgeeks.net") by vger.kernel.org with ESMTP
	id S932495AbWF0RSc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 13:18:32 -0400
Received: from [127.0.0.1] (68-185-24-2.static.mdfd.or.charter.com [68.185.24.2])
	by pbx.netgeeks.net (8.12.8/8.12.8) with ESMTP id k5RHITN4002822
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 10:18:30 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've been digging around trying to get some information on the current status of interrupt mitigation features for a Braodcom 5704 interface.

Specifically I'm sending and receiving lots of VoIP packets (50 pps per stream, many streams).

What I can't seem to determine is this:

What version of the linux kernel & tg3 drivers are required to support both rx and tx mitigation?
What do the ethtool coalescence settings actually do (I've not been able to find actual descriptions of the different parameters in the -C section)
Is there anything special that needs to be done when compiling a kernel to enable this feature for both the kernel and the tg3 driver.

Just a warning, I'm not a C coder, so I've not had much luck digging around the code and looking for answers.

I've currently got a blade server with 10 blades I'm using 9 blades to generate this small packet high rate traffic to the 10th blade and trying to improve the ability of a blade to handle VoIP traffic.  I made some guesses at settings for the -C options in ethtool on both the test blade and the traffic generators.  Interestingly it seems to have had a very good effect on the test blade (%cpu for interrupt down from 99.9% to ~20%), but the same settings on the traffic generation servers seems to have had no effect.

Hardware is identical, kernel is identical.

Any help is GREATLY appreciated.

-Chris

05:01.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704S
Gigabit Ethernet (rev 10)
        Subsystem: IBM: Unknown device 02e8
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 201
        Memory at dcfe0000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+
Queue=0/3 Enable-

Linux version 2.6.9-34.ELsmp (buildcentos@nasha.karan.org) (gcc version
3.4.5 20051201 (Red Hat 3.4.5-2)) #1 SMP Thu Mar 9 06:23:23 GMT 2006

[root@db2 ~]# ethtool -c eth1
Coalesce parameters for eth1:
Adaptive RX: off  TX: off
stats-block-usecs: 1000000
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 500
rx-frames: 30
rx-usecs-irq: 500
rx-frames-irq: 20

tx-usecs: 400
tx-frames: 53
tx-usecs-irq: 490
tx-frames-irq: 5

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

[root@db2 ~]# ethtool -i eth1
driver: tg3
version: 3.43-rh
firmware-version:
bus-info: 0000:05:01.1

[root@db2 ~]# ethtool eth1
Settings for eth1:
        Supported ports: [ FIBRE ]
        Supported link modes:   1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: yes


