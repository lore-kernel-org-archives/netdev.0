From: Frederik Himpe <fhimpe@telenet.be>
Subject: Udev coldplugging loads 8139too driver instead of 8139cp
Date: Mon, 28 Jan 2008 22:16:32 +0100
Message-ID: <1201554992.13883.13.camel@Anastacia>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762154AbYA1VRf@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux 2.6.24 kernel gives the following messages when udev coldplugging
loads the driver for my NIC:

8139too 0000:00:0b.0: This (id 10ec:8139 rev 20) is an enhanced 8139C+ chip
8139too 0000:00:0b.0: Use the "8139cp" driver for improved performance and stability.
ACPI: PCI Interrupt Link [LNK1] enabled at IRQ 10
ACPI: PCI Interrupt 0000:00:0b.0[A] -> Link [LNK1] -> GSI 10 (level, low) -> IRQ 10
8139too 0000:00:0b.0: unknown chip version, assuming RTL-8139
8139too 0000:00:0b.0: TxConfig = 0x74800000
eth1: RealTek RTL8139 at 0xcee8e800, 00:08:02:d8:d5:b9, IRQ 10
eth1:  Identified 8139 chip type 'RTL-8139'
ACPI: PCI Interrupt Link [LNK3] enabled at IRQ 11
PCI: setting IRQ 11 as level-triggered
ACPI: PCI Interrupt 0000:00:13.2[C] -> Link [LNK3] -> GSI 11 (level, low) -> IRQ 11

Output of lspci -vvvn:
00:0b.0 0200: 10ec:8139 (rev 20)
	Subsystem: 0e11:0056
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 10
	Region 0: I/O ports at 9000 [size=256]
	Region 1: Memory at f0018800 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: 8139too
	Kernel modules: 8139cp, 8139too

Why does not udev coldpluggin first try to load 8139cp instead of
8139too?

-- 
Frederik Himpe <fhimpe@telenet.be>
