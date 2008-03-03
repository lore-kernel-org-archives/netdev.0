From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: e1000e fails to find IRQ
Date: Mon, 3 Mar 2008 14:44:43 +0200
Message-ID: <20080303124443.52gfbwwmahxf7wmk@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:57072 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352AbYCCMos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 07:44:48 -0500
Received: from safari.iki.fi (80.223.84.180) by pne-smtpout3-sn1.fre.skanova.net (7.3.129)
        id 47A7885700174D41 for netdev@vger.kernel.org; Mon, 3 Mar 2008 13:44:45 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e says:
[  844.557662] ACPI: PCI interrupt for device 0000:00:19.0 disabled
[  848.739930] e1000e: Intel(R) PRO/1000 Network Driver - 0.2.0
[  848.739936] e1000e: Copyright (c) 1999-2007 Intel Corporation.

e1000 v 7.3.20-k2 and 7.6.15.4 work:
[  883.836173] Intel(R) PRO/1000 Network Driver - version 7.3.20-k2
[  883.836179] Copyright (c) 1999-2006 Intel Corporation.
[  883.836251] ACPI: PCI Interrupt 0000:00:19.0[A] -> GSI 20 (level, low) -> IRQ 20
[  883.836266] PCI: Setting latency timer of device 0000:00:19.0 to 64
[  883.853782] e1000: 0000:00:19.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:19:d1:00:5f:01
[  883.853789] e1000: 0000:00:19.0: e1000_probe: This device (id 8086:104a) will no longer be supported by this driver in the future.
[  883.853909] e1000: 0000:00:19.0: e1000_probe: please use the "e1000e" driver instead.
[  883.931690] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[  883.993761] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  885.423079] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
[  885.423085] e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
[  885.429521] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

I have Intel DQ965GF mobo, version CO96510J.86A.6002.2007.1125.2356,
Linux 2.6.24.3.

=================================================================================

lspci

00:00.0 Host bridge: Intel Corporation 82Q963/Q965 Memory Controller Hub (rev 02)
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>
	Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation 82Q963/Q965 Integrated Graphics Controller (rev 02) (prog-if 00 [VGA controller])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at d0200000 (32-bit, non-prefetchable) [size=1M]
	Region 2: Memory at c0000000 (64-bit, prefetchable) [size=256M]
	Region 4: I/O ports at 2410 [size=8]
	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [d0] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:03.0 Communication controller: Intel Corporation 82Q963/Q965 HECI Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
	Latency: 0
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at d0326100 (64-bit, non-prefetchable) [size=16]
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [8c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
	Subsystem: Intel Corporation Unknown device 0001
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 504
	Region 0: Memory at d0300000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at d0324000 (32-bit, non-prefetchable) [size=4K]
	Region 2: I/O ports at 20e0 [size=32]
	Capabilities: [c8] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41e9
	Kernel driver in use: e1000
	Kernel modules: e1000

00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Contoller #4 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at 20c0 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #5 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 21
	Region 4: I/O ports at 20a0 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #2 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 0: Memory at d0325c00 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 2008
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 505
	Region 0: Memory at d0320000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0100c  Data: 41b9
	Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: HDA Intel
	Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  1, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: fee0300c  Data: 4169
	Capabilities: [90] Subsystem: Intel Corporation 82801H (ICH8 Family) PCI Express Port 1
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.1 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: d0100000-d01fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  2, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: fee0300c  Data: 4171
	Capabilities: [90] Subsystem: Intel Corporation 82801H (ICH8 Family) PCI Express Port 2
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.2 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 3 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  3, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: fee0300c  Data: 4179
	Capabilities: [90] Subsystem: Intel Corporation 82801H (ICH8 Family) PCI Express Port 3
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.3 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 4 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  4, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: fee0300c  Data: 4181
	Capabilities: [90] Subsystem: Intel Corporation 82801H (ICH8 Family) PCI Express Port 4
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1c.4 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Express Port 5 (rev 02) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #5, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise- LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
			Slot #  5, PowerLimit 10.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet- LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: fee0300c  Data: 4189
	Capabilities: [90] Subsystem: Intel Corporation 82801H (ICH8 Family) PCI Express Port 5
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Kernel driver in use: pcieport-driver

00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 4: I/O ports at 2080 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 2060 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 2040 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd

00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2 EHCI Controller #1 (rev 02) (prog-if 20 [EHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at d0325800 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev f2) (prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=32
	Memory behind bridge: d0000000-d00fffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Intel Corporation Unknown device 4f43

00:1f.0 ISA bridge: Intel Corporation 82801HO (ICH8DO) LPC Interface Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Capabilities: [e0] Vendor Specific Information <?>
	Kernel modules: iTCO_wdt

00:1f.2 SATA controller: Intel Corporation 82801HR/HO/HH (ICH8R/DO/DH) 6 port SATA AHCI Controller (rev 02) (prog-if 01 [AHCI 1.0])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 506
	Region 0: I/O ports at 2408 [size=8]
	Region 1: I/O ports at 241c [size=4]
	Region 2: I/O ports at 2400 [size=8]
	Region 3: I/O ports at 2418 [size=4]
	Region 4: I/O ports at 2020 [size=32]
	Region 5: Memory at d0325000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/4 Enable+
		Address: fee0100c  Data: 4191
	Capabilities: [70] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA <?>
	Kernel driver in use: ahci

00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controller (rev 02)
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 21
	Region 0: Memory at d0326000 (32-bit, non-prefetchable) [size=256]
	Region 4: I/O ports at 2000 [size=32]
	Kernel driver in use: i801_smbus
	Kernel modules: i2c-i801

02:00.0 IDE interface: Marvell Technology Group Ltd. 88SE6101 single-port PATA133 interface (rev b1) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: Marvell Technology Group Ltd. 88SE6101 single-port PATA133 interface
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: I/O ports at 1018 [size=8]
	Region 1: I/O ports at 1024 [size=4]
	Region 2: I/O ports at 1010 [size=8]
	Region 3: I/O ports at 1020 [size=4]
	Region 4: I/O ports at 1000 [size=16]
	Region 5: Memory at d0100000 (32-bit, non-prefetchable) [size=512]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0+,D1+,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable-
		Address: 00000000  Data: 0000
	Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr+ NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Kernel driver in use: PCI_IDE

06:03.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22/A IEEE-1394a-2000 Controller (PHY/Link) (prog-if 10 [OHCI])
	Subsystem: Intel Corporation Unknown device 4f43
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 32 (500ns min, 1000ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0004000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at d0000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+
	Kernel driver in use: ohci1394
	Kernel modules: ohci1394

=================================================================================

Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: umbg
	Wake-on: g
	Current message level: 0x00000007 (7)
	Link detected: yes

=================================================================================

driver: e1000
version: 7.3.20-k2
firmware-version: 1.1-0
bus-info: 0000:00:19.0

=================================================================================

ethtool -e

Offset		Values
------		------
0x0000		00 19 d1 00 5f 01 00 08 ff ff 10 10 ff ff ff ff 
0x0010		ff ff ff ff c7 10 01 00 86 80 4a 10 86 80 00 00 
0x0020		01 0d 00 00 00 00 05 96 20 50 00 33 00 00 07 8d 
0x0030		84 06 41 03 00 00 00 00 00 00 00 00 00 00 00 00 
0x0040		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0050		00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
0x0060		00 01 00 40 28 12 07 40 ff ff ff ff ff ff ff ff 
0x0070		ff ff ff ff ff ff ff ff ff ff ff ff ff ff 4b 15 
0x0080		20 61 1f 00 02 0e 12 00 40 2f 1f 00 18 90 1b 00 
0x0090		00 00 12 00 a0 2f 1f 00 24 8b 11 00 f0 f8 12 00 
0x00a0		00 20 1f 00 b0 10 10 00 00 00 11 00 c0 20 1f 00 
0x00b0		9a 24 1d 00 d3 00 1e 00 a0 28 1f 00 ce 04 14 00 
0x00c0		60 2f 1f 00 e4 29 10 00 00 00 1f 00 40 01 00 00 
0x00d0		20 1f 1f 00 06 16 10 00 14 b8 11 00 2a 01 15 00 
0x00e0		67 00 1e 00 40 1f 1f 00 65 00 14 00 2a 00 15 00 
0x00f0		2a 00 16 00 60 1f 1f 00 b0 3f 12 00 ff c0 16 00 
0x0100		ec 1d 17 00 ef f9 18 00 10 02 19 00 80 18 1f 00 
0x0110		03 00 15 00 80 17 1f 00 08 00 16 00 80 17 1f 00 
0x0120		08 d0 18 00 80 18 1f 00 18 d9 18 00 60 18 1f 00 
0x0130		00 08 1a 00 00 00 1f 00 01 00 19 00 40 13 00 00 
0x0140		51 60 1f 00 01 00 11 00 00 00 1f 00 ff ff ff ff 
0x0150		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0160		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0170		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0180		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0190		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x01f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0200		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0210		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0220		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0230		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0240		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0250		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0260		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0270		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0280		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0290		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x02f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0300		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0310		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0320		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0330		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0340		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0350		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0360		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0370		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0380		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0390		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x03f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0400		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0410		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0420		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0430		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0440		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0450		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0460		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0470		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0480		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0490		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x04f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0500		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0510		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0520		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0530		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0540		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0550		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0560		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0570		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0580		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0590		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x05f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0600		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0610		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0620		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0630		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0640		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0650		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0660		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0670		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0680		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0690		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x06f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0700		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0710		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0720		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0730		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0740		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0750		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0760		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0770		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0780		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0790		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x07f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0800		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0810		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0820		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0830		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0840		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0850		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0860		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0870		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0880		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0890		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x08f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0900		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0910		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0920		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0930		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0940		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0950		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0960		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0970		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0980		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0990		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09a0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09b0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09c0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09d0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09e0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x09f0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0a90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0aa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ab0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ac0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ad0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ae0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0af0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0b90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ba0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0be0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0bf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0c90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ca0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ce0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0cf0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0d90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0da0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0db0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0dd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0de0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0df0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0e90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ea0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0eb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ec0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ed0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ee0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ef0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f00		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f10		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f20		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f30		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f40		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f50		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f60		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f70		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f80		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0f90		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fa0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fb0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fc0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fd0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0fe0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 
0x0ff0		ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff 

=================================================================================

ethregs

00:19.0 (8086:104a)
Intel Corporation 82566DM Gigabit Network Connection
	Name           Value
	~~~~           ~~~~~
	CTRL           08100240
	STATUS         00080463
	EECD           00000300
	CTRL_EXT       715a0000
	MDIC           18318610
	FEXTNVM        00000341
	FEXT           00000008
	KMRNCTRLSTA    00000000
	ITR            000003d0
	ICS            00000000
	IMS            0000009d
	IMC            0000009d
	IAM            00000000
	RCTL           00008002
	FCTTV          00000680
	TCTL           3103f0fa
	TIPG           00602008
	AIT            00000000
	LEDCTL         00060784
	EXTCNF_CTRL    0020000a
	EXTCNF_SIZE    00330000
	PHY_CTRL       0004008d
	PBA            00080008
	PBS            00000010
	ERT            00000000
	FCRTL          800019b8
	FCRTH          000019c0
	PSRCTL         00040402
	RDBAL          a195e000
	RDBAH          00000000
	RDLEN          00001000
	RDH            00000024
	RDT            00000022
	RDTR           00000000
	RXDCTL         00010000
	RADV           00000008
	RDBAL1         82581200
	RDBAH1         0e84d222
	RDLEN1         00000000
	RDH1           00000000
	RDT1           00000000
	RSRPD          00000000
	RAID           00000000
	CPUVEC         00000000
	TDFH           0000047a
	TDFT           0000047a
	TDFHS          0000047a
	TDFTS          0000047a
	TDFPC          00000000
	TDBAL          a102e000
	TDBAH          00000000
	TDLEN          00001000
	TDH            000000ef
	TDT            000000ef
	TIDV           00000008
	TXDCTL         01410000
	TADV           00000020
	TARC0          3d800403
	TDBAL1         a9041a10
	TDBAH1         a0504211
	TDLEN1         00000000
	TDH1           00000000
	TDT1           00000000
	TXDCTL1        01410000
	TARC1          45000403
	RXCSUM         00000300
	RFCTL          00000000
	MTA[0]         00000000
	MTA[1]         00000000
	MTA[2]         00000000
	MTA[3]         00000000
	MTA[4]         00000000
	MTA[5]         00000000
	MTA[6]         00000000
	MTA[7]         00000000
	MTA[8]         00000000
	MTA[9]         00000000
	MTA[10]        00000000
	MTA[11]        00000000
	MTA[12]        00000000
	MTA[13]        00000000
	MTA[14]        00000000
	MTA[15]        00000000
	MTA[16]        00000000
	MTA[17]        00000000
	MTA[18]        00000000
	MTA[19]        00000000
	MTA[20]        00000000
	MTA[21]        00000000
	MTA[22]        00000000
	MTA[23]        00000000
	MTA[24]        00000000
	MTA[25]        00000000
	MTA[26]        00000000
	MTA[27]        00000000
	MTA[28]        00000000
	MTA[29]        00000000
	MTA[30]        00000000
	MTA[31]        00000000
	RAL[0]         00d11900
	RAH[0]         8000015f
	RAL[1]         00ff3333
	RAH[1]         8000015f
	RAL[2]         005e0001
	RAH[2]         80000100
	RAL[3]         00003333
	RAH[3]         80000100
	RAL[4]         00000000
	RAH[4]         00000000
	RAL[5]         00000000
	RAH[5]         00000000
	RAL[6]         00451625
	RAH[6]         00000aa0
	WUC            00000000
	WUFC           00000002
	WUS            00000000
	MRQC           00000000
	MANC           00220000
	IPAV           00000000
	IP4AT[0]       a05542c3
	IP4AT[1]       00000000
	IP4AT[2]       4657c0ea
	IP4AT[3]       00000000
	MANC2H         00000180
	RSSIM          00000000
	RSSIR          00000000
	IP6AT[0]       00b06410
	IP6AT[1]       c04213a4
	IP6AT[2]       00107000
	IP6AT[3]       4c400000
	DCR            0000003f
	H2ME           00000000
	FWSM           60018044
	RETA[0]        00000000
	RETA[1]        00000000
	RETA[2]        00000000
	RETA[3]        00000000
	RETA[4]        00000000
	RETA[5]        00000000
	RETA[6]        00000000
	RETA[7]        00000000
	RETA[8]        00000000
	RETA[9]        00000000
	RETA[10]       00000000
	RETA[11]       00000000
	RETA[12]       00000000
	RETA[13]       00000000
	RETA[14]       00000000
	RETA[15]       00000000
	RETA[16]       00000000
	RETA[17]       00000000
	RETA[18]       00000000
	RETA[19]       00000000
	RETA[20]       00000000
	RETA[21]       00000000
	RETA[22]       00000000
	RETA[23]       00000000
	RETA[24]       00000000
	RETA[25]       00000000
	RETA[26]       00000000
	RETA[27]       00000000
	RETA[28]       00000000
	RETA[29]       00000000
	RETA[30]       00000000
	RETA[31]       00000000
	RSSRK[0]       00000000
	RSSRK[1]       00000000
	RSSRK[2]       00000000
	RSSRK[3]       00000000
	RSSRK[4]       00000000
	RSSRK[5]       00000000
	RSSRK[6]       00000000
	RSSRK[7]       00000000
	RSSRK[8]       00000000
	RSSRK[9]       00000000
	RSSRK[10]      00000000
	RSSRK[11]      00000000
	RSSRK[12]      00000000
	RSSRK[13]      00000000
	RSSRK[14]      00000000
	RSSRK[15]      00000000
	RSSRK[16]      00000000
	RSSRK[17]      00000000
	RSSRK[18]      00000000
	RSSRK[19]      00000000
	RSSRK[20]      00000000
	RSSRK[21]      00000000
	RSSRK[22]      00000000
	RSSRK[23]      00000000
	RSSRK[24]      00000000
	RSSRK[25]      00000000
	RSSRK[26]      00000000
	RSSRK[27]      00000000
	RSSRK[28]      00000000
	RSSRK[29]      00000000
	RSSRK[30]      00000000
	RSSRK[31]      00000000
	RSSRK[32]      00000000
	RSSRK[33]      00000000
	RSSRK[34]      00000000
	RSSRK[35]      00000000
	RSSRK[36]      00000000
	RSSRK[37]      00000000
	RSSRK[38]      00000000
	RSSRK[39]      00000000
	FFLT[0]        00000000
	FFLT[1]        e00c0000
	FFLT[2]        00000000
	FFLT[3]        00000000
	FFMT[0]        00000007
	FFMT[1]        00000007
	FFMT[2]        0000000e
	FFMT[3]        0000000e
	FFMT[4]        0000000f
	FFMT[5]        0000000f
	FFMT[6]        0000000f
	FFMT[7]        0000000f
	FFMT[8]        0000000d
	FFMT[9]        0000000d
	FFMT[10]       0000000f
	FFMT[11]       0000000f
	FFMT[12]       00000007
	FFMT[13]       00000007
	FFMT[14]       0000000b
	FFMT[15]       0000000b
	FFMT[16]       00000006
	FFMT[17]       00000006
	FFMT[18]       00000004
	FFMT[19]       00000004
	FFMT[20]       00000003
	FFMT[21]       00000003
	FFMT[22]       0000000f
	FFMT[23]       0000000f
	FFMT[24]       0000000f
	FFMT[25]       0000000f
	FFMT[26]       00000005
	FFMT[27]       00000005
	FFMT[28]       0000000d
	FFMT[29]       0000000d
	FFMT[30]       0000000b
	FFMT[31]       0000000b
	FFMT[32]       0000000d
	FFMT[33]       0000000d
	FFMT[34]       0000000f
	FFMT[35]       0000000f
	FFMT[36]       00000005
	FFMT[37]       00000005
	FFMT[38]       0000000e
	FFMT[39]       0000000e
	FFMT[40]       00000003
	FFMT[41]       00000003
	FFMT[42]       0000000c
	FFMT[43]       0000000c
	FFMT[44]       0000000f
	FFMT[45]       0000000f
	FFMT[46]       00000006
	FFMT[47]       00000006
	FFMT[48]       00000001
	FFMT[49]       00000001
	FFMT[50]       0000000e
	FFMT[51]       0000000e
	FFMT[52]       00000007
	FFMT[53]       00000007
	FFMT[54]       00000007
	FFMT[55]       00000007
	FFMT[56]       0000000d
	FFMT[57]       0000000d
	FFMT[58]       0000000f
	FFMT[59]       0000000f
	FFMT[60]       0000000f
	FFMT[61]       0000000f
	FFMT[62]       0000000e
	FFMT[63]       0000000e
	FFMT[64]       0000000f
	FFMT[65]       0000000f
	FFMT[66]       0000000c
	FFMT[67]       0000000c
	FFMT[68]       0000000b
	FFMT[69]       0000000b
	FFMT[70]       0000000f
	FFMT[71]       0000000f
	FFMT[72]       0000000e
	FFMT[73]       0000000e
	FFMT[74]       0000000f
	FFMT[75]       0000000f
	FFMT[76]       00000007
	FFMT[77]       00000007
	FFMT[78]       0000000f
	FFMT[79]       0000000f
	FFMT[80]       0000000e
	FFMT[81]       0000000e
	FFMT[82]       0000000d
	FFMT[83]       0000000d
	FFMT[84]       0000000f
	FFMT[85]       0000000f
	FFMT[86]       00000009
	FFMT[87]       00000009
	FFMT[88]       0000000f
	FFMT[89]       0000000f
	FFMT[90]       0000000f
	FFMT[91]       0000000f
	FFMT[92]       0000000c
	FFMT[93]       0000000c
	FFMT[94]       0000000f
	FFMT[95]       0000000f
	FFMT[96]       0000000f
	FFMT[97]       0000000f
	FFMT[98]       00000007
	FFMT[99]       00000007
	FFMT[100]      0000000f
	FFMT[101]      0000000f
	FFMT[102]      0000000f
	FFMT[103]      0000000f
	FFMT[104]      0000000b
	FFMT[105]      0000000b
	FFMT[106]      00000007
	FFMT[107]      00000007
	FFMT[108]      00000007
	FFMT[109]      00000007
	FFMT[110]      0000000f
	FFMT[111]      0000000f
	FFMT[112]      0000000b
	FFMT[113]      0000000b
	FFMT[114]      0000000b
	FFMT[115]      0000000b
	FFMT[116]      0000000a
	FFMT[117]      0000000a
	FFMT[118]      0000000d
	FFMT[119]      0000000d
	FFMT[120]      0000000f
	FFMT[121]      0000000f
	FFMT[122]      0000000f
	FFMT[123]      0000000f
	FFMT[124]      0000000e
	FFMT[125]      0000000e
	FFMT[126]      0000000f
	FFMT[127]      0000000f
	FFVT[0]        f770f77f
	FFVT[1]        f770f77f
	FFVT[2]        5f299ffc
	FFVT[3]        5f299ffc
	FFVT[4]        ffb337fb
	FFVT[5]        ffb337fb
	FFVT[6]        f7feefe7
	FFVT[7]        f7feefe7
	FFVT[8]        7f8bdfff
	FFVT[9]        7f8bdfff
	FFVT[10]       f7f6df37
	FFVT[11]       f7f6df37
	FFVT[12]       ef9aefa3
	FFVT[13]       ef9aefa3
	FFVT[14]       fffbb39b
	FFVT[15]       fffbb39b
	FFVT[16]       9bdddff7
	FFVT[17]       9bdddff7
	FFVT[18]       ddcfcdf7
	FFVT[19]       ddcfcdf7
	FFVT[20]       feff9fb3
	FFVT[21]       feff9fb3
	FFVT[22]       ffcfbfcb
	FFVT[23]       ffcfbfcb
	FFVT[24]       dfb757ef
	FFVT[25]       dfb757ef
	FFVT[26]       7e739feb
	FFVT[27]       7e739feb
	FFVT[28]       e16bcfd6
	FFVT[29]       e16bcfd6
	FFVT[30]       6fef7f8b
	FFVT[31]       6fef7f8b
	FFVT[32]       73f59e5b
	FFVT[33]       73f59e5b
	FFVT[34]       fff4aae7
	FFVT[35]       fff4aae7
	FFVT[36]       7fbdaad8
	FFVT[37]       7fbdaad8
	FFVT[38]       deffdfbc
	FFVT[39]       deffdfbc
	FFVT[40]       fcffe7fe
	FFVT[41]       fcffe7fe
	FFVT[42]       7fbd74ff
	FFVT[43]       7fbd74ff
	FFVT[44]       2d7ff1ff
	FFVT[45]       2d7ff1ff
	FFVT[46]       ff2ffdff
	FFVT[47]       ff2ffdff
	FFVT[48]       db7f63f5
	FFVT[49]       db7f63f5
	FFVT[50]       37a5ffaf
	FFVT[51]       37a5ffaf
	FFVT[52]       f55ffe1b
	FFVT[53]       f55ffe1b
	FFVT[54]       dfe9f486
	FFVT[55]       dfe9f486
	FFVT[56]       f7fff7ff
	FFVT[57]       f7fff7ff
	FFVT[58]       fdffd1fd
	FFVT[59]       fdffd1fd
	FFVT[60]       fbdfddf8
	FFVT[61]       fbdfddf8
	FFVT[62]       67fcffdd
	FFVT[63]       67fcffdd
	FFVT[64]       edfb7b2e
	FFVT[65]       edfb7b2e
	FFVT[66]       7d9ffdff
	FFVT[67]       7d9ffdff
	FFVT[68]       edf7f7fd
	FFVT[69]       edf7f7fd
	FFVT[70]       dfdcff7f
	FFVT[71]       dfdcff7f
	FFVT[72]       fdffdfff
	FFVT[73]       fdffdfff
	FFVT[74]       dbf7fafc
	FFVT[75]       dbf7fafc
	FFVT[76]       f7bff5ef
	FFVT[77]       f7bff5ef
	FFVT[78]       f71f9dbd
	FFVT[79]       f71f9dbd
	FFVT[80]       96a95bf9
	FFVT[81]       96a95bf9
	FFVT[82]       f7fbfdde
	FFVT[83]       f7fbfdde
	FFVT[84]       f76fe9fd
	FFVT[85]       f76fe9fd
	FFVT[86]       3f7f9de5
	FFVT[87]       3f7f9de5
	FFVT[88]       ffffdfad
	FFVT[89]       ffffdfad
	FFVT[90]       bffff57a
	FFVT[91]       bffff57a
	FFVT[92]       ddeb17eb
	FFVT[93]       ddeb17eb
	FFVT[94]       ff9f7dfb
	FFVT[95]       ff9f7dfb
	FFVT[96]       beffffd7
	FFVT[97]       beffffd7
	FFVT[98]       ffcff8f7
	FFVT[99]       ffcff8f7
	FFVT[100]      1ffffefe
	FFVT[101]      1ffffefe
	FFVT[102]      9ebdb7df
	FFVT[103]      9ebdb7df
	FFVT[104]      ef7fffed
	FFVT[105]      ef7fffed
	FFVT[106]      d73fefff
	FFVT[107]      d73fefff
	FFVT[108]      bdf7ffbb
	FFVT[109]      bdf7ffbb
	FFVT[110]      179fb6df
	FFVT[111]      179fb6df
	FFVT[112]      bfebbeff
	FFVT[113]      bfebbeff
	FFVT[114]      bf5feddb
	FFVT[115]      bf5feddb
	FFVT[116]      5ddbdfef
	FFVT[117]      5ddbdfef
	FFVT[118]      fd6ba66d
	FFVT[119]      fd6ba66d
	FFVT[120]      abbf9fef
	FFVT[121]      abbf9fef
	FFVT[122]      7fff1ffb
	FFVT[123]      7fff1ffb
	FFVT[124]      fb9bb7f5
	FFVT[125]      fb9bb7f5
	FFVT[126]      fff9dff1
	FFVT[127]      fff9dff1

=================================================================================

/proc/interrupts , when e1000 module is loaded

           CPU0       CPU1       
  0:        132          0   IO-APIC-edge      timer
  1:          2          0   IO-APIC-edge      i8042
  7:          0          0   IO-APIC-edge      parport0
  8:          1          0   IO-APIC-edge      rtc
  9:          0          0   IO-APIC-fasteoi   acpi
 12:          7          0   IO-APIC-edge      i8042
 16:        127          0   IO-APIC-fasteoi   uhci_hcd:usb1, i915@pci:0000:00:02.0
 17:        289          2   IO-APIC-fasteoi   ide0
 18:          2          0   IO-APIC-fasteoi   uhci_hcd:usb5, ehci_hcd:usb6
 19:      19363      48973   IO-APIC-fasteoi   uhci_hcd:usb4, ohci1394
 21:         46          0   IO-APIC-fasteoi   uhci_hcd:usb2
 23:          3          0   IO-APIC-fasteoi   uhci_hcd:usb3, ehci_hcd:usb7
504:      32434          0   PCI-MSI-edge      eth0
505:     130341      93387   PCI-MSI-edge      HDA Intel
506:      44696      67739   PCI-MSI-edge      ahci
NMI:          0          0   Non-maskable interrupts
LOC:    4985393    5146514   Local timer interrupts
RES:       5242       5788   Rescheduling interrupts
CAL:       2548       2484   function call interrupts
TLB:       1910       1812   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
SPU:          0          0   Spurious interrupts
ERR:          0



-- 
Do what you love because life is too short for anything else.

