From: Simon Arlott <simon@fire.lp0.eu>
Subject: r8169 MAC addresses broken
Date: Sat, 25 Oct 2008 21:25:44 +0100
Message-ID: <490380C8.6070003@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:39940 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbYJYU4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Oct 2008 16:56:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Somewhere between 2.6.24 (it would take too long to bisect) and now 
(e013e13bf605b9e6b702adffbe2853cfc60e7806), 2/3 of my MAC addresses 
are getting set to zero:

[    1.533565] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.539277] r8169 0000:00:09.0: PCI INT A -> Link[LNKC] -> GSI 10 (level, low) -> IRQ 10
[    1.547518] r8169 0000:00:09.0: PCI: Disallowing DAC for device
[    1.553569] r8169 0000:00:09.0: no PCI Express capability
[    1.559063] r8169 0000:00:09.0: VPD access disabled, enabling
[    1.565822] r8169 0000:00:09.0: MAC address found in EEPROM: 00:30:18:b0:25:c2
[    1.573873] eth0: RTL8169sc/8110sc at 0xbf6f8000, 00:00:00:00:25:c2, XID 18000000 IRQ 10

[    1.582877] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.595795] r8169 0000:00:0b.0: PCI INT A -> Link[LNKD] -> GSI 11 (level, low) -> IRQ 11
[    1.604039] r8169 0000:00:0b.0: PCI: Disallowing DAC for device
[    1.610089] r8169 0000:00:0b.0: no PCI Express capability
[    1.615581] r8169 0000:00:0b.0: VPD access disabled, enabling
[    1.622336] r8169 0000:00:0b.0: MAC address found in EEPROM: 00:30:18:b0:25:c3
[    1.630854] eth1: RTL8169sc/8110sc at 0xbf6fc000, 00:00:00:00:25:c3, XID 18000000 IRQ 11

If I set the MAC address to the correct value it then ignores packets 
sent to it and I have to use promiscuous mode.

00:09.0 0200: 10ec:8167 (rev 10)
	Subsystem: 16f3:10ec
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at f600 [size=256]
	Region 1: Memory at fdfff000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 40000000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
	Capabilities: [60] Vital Product Data <?>
	Kernel driver in use: r8169

00:0b.0 0200: 10ec:8167 (rev 10)
	Subsystem: 16f3:10ec
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 11
	Region 0: I/O ports at f800 [size=256]
	Region 1: Memory at fdffe000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 40020000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
	Capabilities: [60] Vital Product Data <?>
	Kernel driver in use: r8169


-- 
Simon Arlott
