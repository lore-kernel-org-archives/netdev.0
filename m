From: Alban Browaeys <prahal@yahoo.com>
Subject: skge - no traffic and oops after ifdown - 3.3-rc1 main tree
Date: Fri, 27 Jan 2012 12:05:57 +0100
Message-ID: <1327662357.4461.5.camel@penelope>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm11-vm3.bullet.mail.ne1.yahoo.com ([98.138.91.141]:43350 "HELO
	nm11-vm3.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752580Ab2A0LMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 06:12:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I opened https://bugzilla.kernel.org/show_bug.cgi?id=3D42665 namely oop=
s
attachement and :

skge crash after attempt to setup as dhcp then ifdown

commit d0249e44432aa0ffcf710b64449b8eaa3722547e
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Thu Jan 19 14:37:18 2012 +0000

    skge: check for PCI dma mapping errors

    Driver should check for mapping errors.
    Machines with limited DMA maps may return an error when a PCI map i=
s
    requested (not an issue on standard x86).

    Also use upper/lower 32 bits macros for clarity.

    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


leads to failure to ifup <skge interface> if this one is setup as dhcp =
(static
"works" but no traffic) then an ifdown leads to the attached oops.

Reverting this commit fixes both issues (traffic and ifdown) at least u=
ntil
mainline tree commit 87f71ae2dd7471c1b4c94100be1f218e91dc64c3 .


  *-network:2
       description: Ethernet interface
       produit: 88E8001 Gigabit Ethernet Controller
       fabriquant: Marvell Technology Group Ltd.
       identifiant mat=C3=A9riel: d
       information bus: pci@0000:01:0d.0
       nom logique: eth0
       version: 13
       num=C3=A9ro de s=C3=A9rie: 00:18:f3:02:33:79
       taille: 100Mbit/s
       capacit=C3=A9: 1Gbit/s
       bits: 32 bits
       horloge: 66MHz
       fonctionnalit=C3=A9s: bus_master cap_list rom ethernet physical =
tp 10bt
10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd autonegotiation
       configuration: autonegotiation=3Don broadcast=3Dyes driver=3Dskg=
e
driverversion=3D1.14 duplex=3Dfull latency=3D64 maxlatency=3D31 mingnt=3D=
23 multicast=3Dyes
port=3Dtwisted pair promiscuous=3Dyes speed=3D100Mbit/s
       ressources: irq:23 m=C3=A9moire:fbff8000-fbffbfff portE/S:d400(t=
aille=3D256)
m=C3=A9moire:fbfa0000-fbfbffff



01:0d.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Giga=
bit
Ethernet Controller (rev 13)
    Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit Ethernet
Controller (Asus)
    Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- =
<TAbort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 16 bytes
    Interrupt: pin A routed to IRQ 23
    Region 0: Memory at fbff8000 (32-bit, non-prefetchable) [size=3D16K=
]
    Region 1: I/O ports at d400 [size=3D256]
    Expansion ROM at fbfa0000 [disabled] [size=3D128K]
    Capabilities: <access denied>
    Kernel driver in use: skge

01:0d.0 0200: 11ab:4320 (rev 13)
    Subsystem: 1043:811a

arch i686.



Best regards,
Alban
