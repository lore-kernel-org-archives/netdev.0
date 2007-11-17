From: "Denys" <nuclearcat@nuclearcat.com>
Subject: r8169 crash
Date: Sat, 17 Nov 2007 07:39:20 +0200
Message-ID: <20071117053920.M40084@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:43744 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbXKQFja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 00:39:30 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 7BC06BC2AB
	for <netdev@vger.kernel.org>; Sat, 17 Nov 2007 07:39:20 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Recently i start to use r8169 cards and faced some issues.

How to reproduce (kind of difficult, and i cannot that on my live server 
anymore):

1)Badly crimped cable.
2)PCI-Express R8169 card

Kernel 2.6.23.1

05:01.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit 
Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- 
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 21
        Region 0: I/O ports at 1000 [size=256]
        Region 1: Memory at 55001000 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at fffe0000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA 
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-


r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
eth1: RTL8169sb/8110sb at 0xf881c000, 00:19:e0:72:49:88, XID 10000000 IRQ 21

To reproduce issue i need to shake faulty cable. Card will report:
Nov 15 22:09:36 vzone r8169: eth1: link up
So it is going up without going down!

Normally it is like this:
Nov  1 00:50:33 vzone r8169: eth1: link down
Nov  1 00:50:35 vzone r8169: eth1: link up

After that i have.
Nov 15 22:11:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:11:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:12:01 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:12:13 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:12:25 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:12:37 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:12:49 vzone NETDEV WATCHDOG: eth1: transmit timed out
Nov 15 22:13:01 vzone NETDEV WATCHDOG: eth1: transmit timed out

And card completely non-functional (doesn't see traffic at all and doesn't 
send anything). Probably some functions (like NAPI enabling) is has to be 
disabled first, and if interface come twice up, without going down, card come 
crazy.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

