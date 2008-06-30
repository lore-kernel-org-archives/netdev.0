From: Krzysztof Oledzki <olel@ans.pl>
Subject: Problem with sky2 (Yukon-EC)
Date: Mon, 30 Jun 2008 21:28:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1910535866-1214854095=:4958"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:55623 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbYF3T2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:28:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1910535866-1214854095=:4958
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

Hello,

I have several servers with sky2 NIC (bonding + vlan):

sky2 0000:02:00.0: v1.20 addr 0xcfffc000 irq 17 Yukon-EC (0xb6) rev 1

02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gi=
gabit Ethernet Controller (rev 15)
         Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet =
controller PCIe (Asus)
         Flags: bus master, fast devsel, latency 0, IRQ 221
         Memory at cfffc000 (64-bit, non-prefetchable) [size=3D16K]
         I/O ports at d800 [size=3D256]
         Expansion ROM at cffc0000 [disabled] [size=3D128K]
         Capabilities: [48] Power Management version 2
         Capabilities: [50] Vital Product Data <?>
         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queu=
e=3D0/1 Enable+
         Capabilities: [e0] Express Legacy Endpoint, MSI 00
         Kernel driver in use: sky2

All server suffer the same problem - once about two-three weeks network=20
dies completely (log from 2.6.24):

sky2 eth1: hung mac 7:19 fifo 0 (91:101)
sky2 eth1: receiver hang detected
sky2 eth1: disabling interface
sky2 eth1: enabling interface
bonding: bond0: link status definitely down for interface eth1, disabling i=
t
bonding: bond0: now running without any active interface !
sky2 eth1: Link is up at 100 Mbps, full duplex, flow control both
bonding: bond0: link status definitely up for interface eth1.
bonding: bond0: making interface eth1 the new active one.
bonding: bond0: first active interface up!
sky2 eth1: rx length error: status 0x402500 length 64
*last message repeated 9 times
kernel: sky2 eth1: rx length error: status 0x402300 length 64
kernel: sky2 eth1: rx length error: status 0x402500 length 64
*last message repeated 7 times
*last message repeated 6 times
kernel: sky2 eth1: rx length error: status 0x402300 length 64
kernel: sky2 eth1: rx length error: status 0x402500 length 64
(...)

Similar log from 2.6.22:
sky2 eth0: tx timeout
sky2 eth0: transmit ring 141 .. 119 report=3D141 done=3D141
sky2 eth0: disabling interface
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
bonding: bond0: link status definitely down for interface eth0, disabling i=
t
bonding: bond0: making interface eth1 the new active one.
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
bonding: bond0: link status definitely up for interface eth0.
bonding: bond0: making interface eth0 the new active one.
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x402300 length 64
sky2 eth0: rx error, status 0x8a2100 length 138
sky2 eth0: rx error, status 0x8a2100 length 138
sky2 eth0: rx error, status 0x9a2100 length 154
sky2 eth0: rx error, status 0xba2100 length 186
sky2 eth0: rx error, status 0x5e2100 length 94
sky2 eth0: rx error, status 0xba2100 length 186
sky2 eth0: rx error, status 0xea2100 length 234
sky2 eth0: rx error, status 0x8a2100 length 138
sky2 eth0: rx error, status 0x8a2100 length 138
sky2 eth0: rx error, status 0xea2100 length 234
sky2 eth0: rx error, status 0x8a2100 length 138
(...)

It seems that there is somethig wrong with the receiver hang workaround=20
code. After such reset the card is not longer able to receive traffic.=20
Maybe it is somehow related to vlans?

This problem exists in 2.6.21/2.6.22/2.6.24. I have not yet tested=20
2.6.25/2.6.26, any chances it get fixed there?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1910535866-1214854095=:4958--
