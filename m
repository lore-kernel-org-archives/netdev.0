From: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 09:26:54 +0300
Message-ID: <4C6E202E.5030406@fs.uni-ruse.bg>
References: <bug-16626-10286@https.bugzilla.kernel.org/>	<20100819152143.8a57c465.akpm@linux-foundation.org>	<4C6E0C99.2060407@fs.uni-ruse.bg>	<20100819221142.b8f6a70a.akpm@linux-foundation.org>	<4C6E1CBA.2060605@fs.uni-ruse.bg> <20100819232019.6f6074a8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [83.228.35.12] ([83.228.35.12]:42244 "EHLO fs.ru.acad.bg"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab0HTG05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 02:26:57 -0400
In-Reply-To: <20100819232019.6f6074a8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Posting this only in the hope that it will be helpfull to the
"net guys"...

root@fs:~# uname -a; lspci -vvv; ethtool -i eth1
> Linux fs 2.6.34.4-FS #1 SMP Thu Aug 19 18:09:58 UTC 2010 i686 Intel(R) Pentium(R) D CPU 3.00GHz GenuineIntel GNU/Linux
> 00:00.0 Host bridge: Intel Corporation E7230/3000/3010 Memory Controller Hub
>         Subsystem: Dell Unknown device 01df
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information
>
> 00:01.0 PCI bridge: Intel Corporation E7230/3000/3010 PCI Express Root Port (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000f000-00000fff
>         Memory behind bridge: efe00000-efefffff
>         Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [88] Subsystem: Intel Corporation Unknown device 0000
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
>                 Address: fee0300c  Data: 4149
>         Capabilities: [a0] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s <64ns, L1 <1us
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 2
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x0
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
>                 Slot: Number 1, PowerLimit 25.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Off, PwrInd On, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [140] Unknown (5)
>
> 00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 01) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 00001000-00001fff
>         Memory behind bridge: efd00000-efdfffff
>         Prefetchable memory behind bridge: 0000000020000000-00000000201fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s unlimited, L1 unlimited
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s, Port 1
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x0
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
>                 Slot: Number 4, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
>                 Address: fee0300c  Data: 4151
>         Capabilities: [90] Subsystem: Gammagraphx, Inc. Unknown device 0000
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1c.4 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 5 (rev 01) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         I/O behind bridge: 00002000-00002fff
>         Memory behind bridge: 20200000-203fffff
>         Prefetchable memory behind bridge: 0000000020400000-00000000205fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s unlimited, L1 unlimited
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 5
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x0
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
>                 Slot: Number 1, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
>                 Address: fee0300c  Data: 4159
>         Capabilities: [90] Subsystem: Gammagraphx, Inc. Unknown device 0000
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1c.5 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 6 (rev 01) (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
>         I/O behind bridge: 00003000-00003fff
>         Memory behind bridge: efc00000-efcfffff
>         Prefetchable memory behind bridge: 0000000020600000-00000000207fffff
>         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [40] Express Root Port (Slot+) IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s unlimited, L1 unlimited
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 6
>                 Link: Latency L0s <256ns, L1 <4us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>                 Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
>                 Slot: Number 0, PowerLimit 10.000000
>                 Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
>                 Slot: AttnInd Unknown, PwrInd Unknown, Power-
>                 Root: Correctable- Non-Fatal- Fatal- PME-
>         Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
>                 Address: fee0300c  Data: 4161
>         Capabilities: [90] Subsystem: Gammagraphx, Inc. Unknown device 0000
>         Capabilities: [a0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [100] Virtual Channel
>         Capabilities: [180] Unknown (5)
>
> 00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #1 (rev 01) (prog-if 00 [UHCI])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 21
>         Region 4: I/O ports at ff80 [size=32]
>
> 00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #2 (rev 01) (prog-if 00 [UHCI])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin B routed to IRQ 22
>         Region 4: I/O ports at ff60 [size=32]
>
> 00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #3 (rev 01) (prog-if 00 [UHCI])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 18
>         Region 4: I/O ports at ff40 [size=32]
>
> 00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 01) (prog-if 20 [EHCI])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 21
>         Region 0: Memory at ff980800 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [58] Debug port
>
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1) (prog-if 01 [Subtractive decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Bus: primary=00, secondary=05, subordinate=05, sec-latency=32
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: efa00000-efbfffff
>         Prefetchable memory behind bridge: 00000000e0000000-00000000e7ffffff
>         Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
>         BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
>         Capabilities: [50] Subsystem: Gammagraphx, Inc. Unknown device 0000
>
> 00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge (rev 01)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Capabilities: [e0] Vendor Specific Information
>
> 00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 01) (prog-if 8a [Master SecP PriP])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin A routed to IRQ 16
>         Region 0: I/O ports at 01f0 [size=8]
>         Region 1: I/O ports at 03f4 [size=1]
>         Region 2: I/O ports at 0170 [size=8]
>         Region 3: I/O ports at 0374 [size=1]
>         Region 4: I/O ports at ffa0 [size=16]
>
> 00:1f.2 IDE interface: Intel Corporation 82801GB/GR/GH (ICH7 Family) SATA IDE Controller (rev 01) (prog-if 8f [Master SecP SecO PriP PriO])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0
>         Interrupt: pin C routed to IRQ 20
>         Region 0: I/O ports at fe00 [size=8]
>         Region 1: I/O ports at fe10 [size=4]
>         Region 2: I/O ports at fe20 [size=8]
>         Region 3: I/O ports at fe30 [size=4]
>         Region 4: I/O ports at fec0 [size=16]
>         Region 5: Memory at effffc00 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: [70] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin B routed to IRQ 17
>         Region 4: I/O ports at ece0 [size=32]
>
> 04:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5754 Gigabit Ethernet PCI Express (rev 02)
>         Subsystem: Dell Unknown device 01df
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 28
>         Region 0: Memory at efcf0000 (64-bit, non-prefetchable) [size=64K]
>         Expansion ROM at <ignored> [disabled]
>         Capabilities: [48] Power Management version 3
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data
>         Capabilities: [58] Vendor Specific Information
>         Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
>                 Address: 00000000fee0300c  Data: 4189
>         Capabilities: [d0] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
>                 Device: Latency L0s <4us, L1 unlimited
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
>                 Device: RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
>                 Link: Latency L0s <4us, L1 <64us
>                 Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [13c] Virtual Channel
>         Capabilities: [160] Device Serial Number 1b-8a-38-fe-ff-a0-1a-00
>         Capabilities: [16c] Power Budgeting
>
> 05:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
>         Subsystem: Realtek Semiconductor Co., Ltd. RT8139
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (8000ns min, 16000ns max)
>         Interrupt: pin A routed to IRQ 18
>         Region 0: I/O ports at d400 [size=256]
>         Region 1: Memory at efaefe00 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 05:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
>         Subsystem: Realtek Semiconductor Co., Ltd. RT8139
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (8000ns min, 16000ns max)
>         Interrupt: pin A routed to IRQ 16
>         Region 0: I/O ports at d800 [size=256]
>         Region 1: Memory at efaeff00 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> 05:07.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02) (prog-if 00 [VGA])
>         Subsystem: Dell Unknown device 01df
>         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR+ FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin A routed to IRQ 5
>         Region 0: Memory at e0000000 (32-bit, prefetchable) [size=128M]
>         Region 1: I/O ports at dc00 [size=256]
>         Region 2: Memory at efaf0000 (32-bit, non-prefetchable) [size=64K]
>         Expansion ROM at efb00000 [disabled] [size=128K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>
> driver: tg3
> version: 3.108
> firmware-version: 5754-v3.12
> bus-info: 0000:04:00.0
> root@fs:~#

