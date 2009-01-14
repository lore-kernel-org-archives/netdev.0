From: Ben Greear <greearb@candelatech.com>
Subject: Bad tg3 performance on S10 netbook
Date: Wed, 14 Jan 2009 14:18:35 -0800
Message-ID: <496E64BB.7080709@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52967 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761034AbZANWSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:18:40 -0500
Received: from [192.168.100.194] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n0EMIZ1I004969
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 14:18:35 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are testing an S10 netbook from Lenovo and it's built-in
tg3 NIC is getting lots of 'rx-irq-missed' events and is dropping
packets while running at about 45Mbps tx + rx.
This is kernel 2.6.25 plus some hacks.  We did most testing
on the stock 2.6.25 tg3 driver, but a quick attempt at using
the latest tg3 from bcm's site shows the same irq-miss issue.

We tried forcing the cpufreq to max (1.6Ghz) and that didn't
help much.

We tried setting the rx buffers to 511 (max for this chip it seems)
and that didn't help.

The one thing that *does* help is to run something that eats a lot
of CPU.  This is what made us think that the cpufreq was the issue,
but again, hard-coding it didn't help.

We tried turning on adaptive-rx (it is off by default), and again,
no improvement.

So, does anyone have any suggestions on what else to poke at?

Full lspci output is below.

Thanks,
Ben

00:00.0 Host bridge: Intel Corporation Mobile 945GME Express Memory Controller Hub (rev 03)
         Subsystem: Lenovo Device 386f
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
         Latency: 0
         Capabilities: [e0] Vendor Specific Information <?>
         Kernel driver in use: agpgart-intel

00:02.0 VGA compatible controller: Intel Corporation Mobile 945GME Express Integrated Graphics Controller (rev 03) (prog-if 00 [VGA controller])
         Subsystem: Lenovo Device 3870
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin A routed to IRQ 16
         Region 0: Memory at f0500000 (32-bit, non-prefetchable) [size=512K]
         Region 1: I/O ports at 1800 [size=8]
         Region 2: Memory at d0000000 (32-bit, prefetchable) [size=256M]
         Region 3: Memory at f0600000 (32-bit, non-prefetchable) [size=256K]
         Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable-
                 Address: 00000000  Data: 0000
         Capabilities: [d0] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:02.1 Display controller: Intel Corporation Mobile 945GM/GMS/GME, 943/940GML Express Integrated Graphics Controller (rev 03)
         Subsystem: Lenovo Device 3870
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Region 0: Memory at f0580000 (32-bit, non-prefetchable) [size=512K]
         Capabilities: [d0] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:1b.0 Audio device: Intel Corporation 82801G (ICH7 Family) High Definition Audio Controller (rev 02)
         Subsystem: Lenovo Device 3bf8
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 22
         Region 0: Memory at f0840000 (64-bit, non-prefetchable) [size=16K]
         Capabilities: [50] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Count=1/1 Enable-
                 Address: 0000000000000000  Data: 0000
         Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
                         ExtTag- RBE- FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 128 bytes, MaxReadReq 128 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed unknown, Width x0, ASPM unknown, Latency L0 <64ns, L1 <1us
                         ClockPM- Suprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed unknown, Width x0, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100] Virtual Channel <?>
         Capabilities: [130] Root Complex Link <?>
         Kernel driver in use: HDA Intel
         Kernel modules: snd-hda-intel

00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 02) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
         I/O behind bridge: 00002000-00002fff
         Memory behind bridge: f0200000-f02fffff
         Prefetchable memory behind bridge: 00000000f0000000-00000000f00fffff
         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
         BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                         ExtTag- RBE- FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 128 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
                 LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
                         ClockPM- Suprise- LLActRep+ BwNot-
                 LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
                         Slot #  2, PowerLimit 6.500000; Interlock- NoCompl-
                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg-
                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                         Changed: MRL- PresDet- LinkState-
                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                 RootCap: CRSVisible-
                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable+
                 Address: fee0300c  Data: 41c1
         Capabilities: [90] Subsystem: Intel Corporation Device 1999
         Capabilities: [a0] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [100] Virtual Channel <?>
         Capabilities: [180] Root Complex Link <?>
         Kernel driver in use: pcieport-driver

00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 2 (rev 02) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Bus: primary=00, secondary=03, subordinate=04, sec-latency=0
         I/O behind bridge: 00003000-00003fff
         Memory behind bridge: f0300000-f03fffff
         Prefetchable memory behind bridge: 00000000f0100000-00000000f01fffff
         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
         BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                         ExtTag- RBE- FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 128 bytes
                 DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
                 LnkCap: Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
                         ClockPM- Suprise- LLActRep+ BwNot-
                 LnkCtl: ASPM L0s Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
                         Slot #  3, PowerLimit 6.500000; Interlock- NoCompl-
                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg-
                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                         Changed: MRL- PresDet- LinkState-
                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                 RootCap: CRSVisible-
                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable+
                 Address: fee0300c  Data: 41c9
         Capabilities: [90] Subsystem: Intel Corporation Device 1999
         Capabilities: [a0] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [100] Virtual Channel <?>
         Capabilities: [180] Root Complex Link <?>
         Kernel driver in use: pcieport-driver

00:1c.2 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 3 (rev 02) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Bus: primary=00, secondary=05, subordinate=05, sec-latency=0
         I/O behind bridge: 0000f000-00000fff
         Memory behind bridge: f0400000-f04fffff
         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
         BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
         Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                         ExtTag- RBE- FLReset-
                 DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 128 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
                 LnkCap: Port #3, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
                         ClockPM- Suprise- LLActRep+ BwNot-
                 LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
                 SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surpise+
                         Slot #  4, PowerLimit 6.500000; Interlock- NoCompl-
                 SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet+ CmdCplt- HPIrq+ LinkChg-
                         Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
                 SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
                         Changed: MRL- PresDet- LinkState-
                 RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
                 RootCap: CRSVisible-
                 RootSta: PME ReqID 0000, PMEStatus- PMEPending-
         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Count=1/1 Enable+
                 Address: fee0300c  Data: 41d1
         Capabilities: [90] Subsystem: Intel Corporation Device 1999
         Capabilities: [a0] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [100] Virtual Channel <?>
         Capabilities: [180] Root Complex Link <?>
         Kernel driver in use: pcieport-driver

00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #1 (rev 02) (prog-if 00 [UHCI])
         Subsystem: Lenovo Device 3807
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin A routed to IRQ 23
         Region 4: I/O ports at 1820 [size=32]
         Kernel driver in use: uhci_hcd
         Kernel modules: uhci-hcd

00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #2 (rev 02) (prog-if 00 [UHCI])
         Subsystem: Lenovo Device 3808
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin B routed to IRQ 19
         Region 4: I/O ports at 1840 [size=32]
         Kernel driver in use: uhci_hcd
         Kernel modules: uhci-hcd

00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #3 (rev 02) (prog-if 00 [UHCI])
         Subsystem: Lenovo Device 3809
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin C routed to IRQ 18
         Region 4: I/O ports at 1860 [size=32]
         Kernel driver in use: uhci_hcd
         Kernel modules: uhci-hcd

00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #4 (rev 02) (prog-if 00 [UHCI])
         Subsystem: Lenovo Device 380a
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin D routed to IRQ 16
         Region 4: I/O ports at 1880 [size=32]
         Kernel driver in use: uhci_hcd
         Kernel modules: uhci-hcd

00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 02) (prog-if 20 [EHCI])
         Subsystem: Lenovo Device 380b
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin A routed to IRQ 23
         Region 0: Memory at f0844000 (32-bit, non-prefetchable) [size=1K]
         Capabilities: [50] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [58] Debug port: BAR=1 offset=00a0
         Kernel driver in use: ehci_hcd
         Kernel modules: ehci-hcd

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e2) (prog-if 01 [Subtractive decode])
         Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Bus: primary=00, secondary=06, subordinate=06, sec-latency=32
         I/O behind bridge: 0000f000-00000fff
         Memory behind bridge: fff00000-000fffff
         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
         Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
         BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
         Capabilities: [50] Subsystem: Lenovo Device 380c

00:1f.0 ISA bridge: Intel Corporation 82801GBM (ICH7-M) LPC Interface Bridge (rev 02)
         Subsystem: Lenovo Device 380d
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Capabilities: [e0] Vendor Specific Information <?>
         Kernel modules: intel-rng, iTCO_wdt

00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 02) (prog-if 8a [Master SecP PriP])
         Subsystem: Lenovo Device 3810
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx+
         Latency: 0
         Interrupt: pin B routed to IRQ 19
         Region 0: I/O ports at 01f0 [size=8]
         Region 1: I/O ports at 03f4 [size=1]
         Region 2: I/O ports at 0170 [size=8]
         Region 3: I/O ports at 0374 [size=1]
         Region 4: I/O ports at 1810 [size=16]
         Kernel driver in use: ata_piix
         Kernel modules: ata_piix

00:1f.2 IDE interface: Intel Corporation 82801GBM/GHM (ICH7 Family) SATA IDE Controller (rev 02) (prog-if 8f [Master SecP SecO PriP PriO])
         Subsystem: Lenovo Device 3835
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0
         Interrupt: pin B routed to IRQ 19
         Region 0: I/O ports at 18c8 [size=8]
         Region 1: I/O ports at 18c0 [size=4]
         Region 2: I/O ports at 18a8 [size=8]
         Region 3: I/O ports at 180c [size=4]
         Region 4: I/O ports at 18b0 [size=16]
         Region 5: Memory at f0844400 (32-bit, non-prefetchable) [size=1K]
         Capabilities: [70] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Kernel driver in use: ata_piix
         Kernel modules: ata_piix

00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 02)
         Subsystem: Lenovo Device 380f
         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Interrupt: pin B routed to IRQ 19
         Region 4: I/O ports at 18e0 [size=32]
         Kernel driver in use: i801_smbus
         Kernel modules: i2c-i801

02:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5906M Fast Ethernet PCI Express (rev 02)
         Subsystem: Lenovo Device 3a23
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 219
         Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=64K]
         Expansion ROM at <ignored> [disabled]
         Capabilities: [48] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable+ DSel=0 DScale=0 PME-
         Capabilities: [50] Vital Product Data <?>
         Capabilities: [58] Vendor Specific Information <?>
         Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ Count=1/1 Enable+
                 Address: 00000000fee0300c  Data: 414a
         Capabilities: [d0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 4096 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <4us, L1 <64us
                         ClockPM+ Suprise- LLActRep- BwNot-
                 LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSVoil-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVoil-
                 CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
         Capabilities: [13c] Virtual Channel <?>
         Capabilities: [160] Device Serial Number 06-c1-ac-00-06-68-1e-00
         Kernel driver in use: tg3
         Kernel modules: tg3

03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 20)
         Subsystem: SysKonnect Device 4340
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 220
         Region 0: Memory at f0300000 (64-bit, non-prefetchable) [size=16K]
         Region 2: I/O ports at 3000 [size=256]
         [virtual] Expansion ROM at f0100000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data <?>
         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Count=1/2 Enable+
                 Address: 00000000fee0300c  Data: 413a
         Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 unlimited
                         ClockPM- Suprise- LLActRep- BwNot-
                 LnkCtl: ASPM L0s Enabled; RCB 128 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVoil-
                 CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                 AERCap: First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
         Kernel driver in use: sky2
         Kernel modules: sky2

05:00.0 Network controller: Broadcom Corporation BCM4312 802.11b/g (rev 01)
         Subsystem: Broadcom Corporation Device 04b5
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 3
         Region 0: Memory at f0400000 (64-bit, non-prefetchable) [size=16K]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
         Capabilities: [58] Vendor Specific Information <?>
         Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ Count=1/1 Enable-
                 Address: 0000000000000000  Data: 0000
         Capabilities: [d0] Express (v1) Endpoint, MSI 00
                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                         MaxPayload 128 bytes, MaxReadReq 128 bytes
                 DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
                 LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <4us, L1 <64us
                         ClockPM+ Suprise- LLActRep- BwNot-
                 LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
         Capabilities: [100] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSVoil-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVoil-
                 CESta:  RxErr+ BadTLP+ BadDLLP- Rollover- Timeout- NonFatalErr+
                 CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 AERCap: First Error Pointer: 14, GenCap+ CGenEn- ChkCap+ ChkEn-
         Capabilities: [13c] Virtual Channel <?>
         Capabilities: [160] Device Serial Number 22-00-ae-ff-ff-68-88-ea
         Capabilities: [16c] Power Budgeting <?>




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


