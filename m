From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Mon, 16 Mar 2009 20:04:28 -0700
Message-ID: <20090316200428.908245dc.akpm@linux-foundation.org>
References: <bug-12886-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	tomimo@ncircle.nullnet.fi,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42294 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755276AbZCQDKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 23:10:03 -0400
In-Reply-To: <bug-12886-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 16 Mar 2009 14:49:44 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12886
> 
>            Summary: skge wake on lan
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.28.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: tomimo@ncircle.nullnet.fi
> 
> 
> Latest working kernel version:  -
> Earliest failing kernel version: commit
> 5177b3240a6608fc0c9c05cc32f4855c6540f8d5

That's

commit 5177b3240a6608fc0c9c05cc32f4855c6540f8d5
Author:     Rafael J. Wysocki <rjw@sisk.pl>
AuthorDate: Wed Oct 29 14:22:14 2008 -0700
Commit:     Jeff Garzik <jgarzik@redhat.com>
CommitDate: Fri Oct 31 00:52:17 2008 -0400

    skge: adapt skge to use reworked PCI PM
    
    Adapt the skge driver to the reworked PCI PM
    
    * Use device_set_wakeup_enable() and friends as needed
    * Remove an open-coded reference to the standard PCI PM registers
    * Use pci_prepare_to_sleep() and pci_back_from_sleep() in the
      ->suspend() and ->resume() callbacks
    * Use the observation that it is sufficient to call pci_enable_wake()
      once, unless it fails
    
    Tested on Asus L5D (Yukon-Lite rev 7).

> Distribution: Fedora (with standard mainline kernel)
> Hardware Environment: Asus A7V880-motherboard
> Software Environment: Fedora 9
> Problem Description: The skge-drivers commit from last october seems to have
> broken the wake-on-lan feature from my machine. Reverting the above mentioned
> commit fixes the problem again ie. WOL is working again without problems.
> The broken patch did not produce any errors or such, only symptom was that WOL
> did not work anymore. The loading of the nvidia module did not change the
> situation at all (for the record).
> 
> valen#root>lspci -vv
> 00:00.0 Host bridge: VIA Technologies, Inc. KT880 Host Bridge (rev 80)
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR- INTx-
>         Latency: 96
>         Region 0: Memory at e0000000 (32-bit, prefetchable) [size=256M]
>         Capabilities: [80] AGP version 3.5
>                 Status: RQ=32 Iso- ArqSz=0 Cal=2 SBA+ ITACoh- GART64- HTrans-
> 64bit- FW+ AGP3+ Rate=x8
>                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
> Rate=<none>
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:00.1 Host bridge: VIA Technologies, Inc. KT880 Host Bridge
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:00.2 Host bridge: VIA Technologies, Inc. KT880 Host Bridge
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:00.3 Host bridge: VIA Technologies, Inc. KT880 Host Bridge
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:00.4 Host bridge: VIA Technologies, Inc. KT880 Host Bridge
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:00.7 Host bridge: VIA Technologies, Inc. KT880 Host Bridge
>         Subsystem: ASUSTeK Computer Inc. Unknown device 8122
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
> 
> 00:01.0 PCI bridge: VIA Technologies, Inc. VT8237/VX700 PCI Bridge (prog-if 00
> [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         Memory behind bridge: fc100000-fe2fffff
>         Prefetchable memory behind bridge: 9ff00000-afefffff
>         Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort+ <SERR- <PERR+
>         BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>         Capabilities: [70] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 00:09.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit
> Ethernet Controller (rev 13)
>         Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit Ethernet
> Controller (Asus)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96 (5750ns min, 7750ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 18
>         Region 0: Memory at fe400000 (32-bit, non-prefetchable) [size=16K]
>         Region 1: I/O ports at e000 [size=256]
>         Expansion ROM at fe300000 [disabled] [size=128K]
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data <?>
>         Kernel driver in use: skge
> 
> 00:0f.0 RAID bus controller: VIA Technologies, Inc. VIA VT6420 SATA RAID
> Controller (rev 80)
>         Subsystem: ASUSTeK Computer Inc. A7V600/K8V Deluxe/K8V-X/A8V Deluxe
> motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96
>         Interrupt: pin B routed to IRQ 20
>         Region 0: I/O ports at eff0 [size=8]
>         Region 1: I/O ports at efe4 [size=4]
>         Region 2: I/O ports at efa8 [size=8]
>         Region 3: I/O ports at efe0 [size=4]
>         Region 4: I/O ports at ef90 [size=16]
>         Region 5: I/O ports at e800 [size=256]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: sata_via
> 
> 00:0f.1 IDE interface: VIA Technologies, Inc.
> VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06) (prog-if 8a
> [Master SecP PriP])
>         Subsystem: ASUSTeK Computer Inc. A7V600/K8V-X/A8V Deluxe motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 32
>         Interrupt: pin A routed to IRQ 20
>         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)
> [size=8]
>         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
> [size=1]
>         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)
> [size=8]
>         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
> [size=1]
>         Region 4: I/O ports at fc00 [size=16]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: pata_via
> 
> 00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> Controller (rev 81) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 21
>         Region 4: I/O ports at eec0 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci-hcd
> 
> 00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> Controller (rev 81) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 21
>         Region 4: I/O ports at ef00 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci-hcd
> 
> 00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> Controller (rev 81) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96, Cache Line Size: 32 bytes
>         Interrupt: pin B routed to IRQ 21
>         Region 4: I/O ports at ef20 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci-hcd
> 
> 00:10.3 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1
> Controller (rev 81) (prog-if 00 [UHCI])
>         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96, Cache Line Size: 32 bytes
>         Interrupt: pin B routed to IRQ 21
>         Region 4: I/O ports at ef40 [size=32]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: uhci_hcd
>         Kernel modules: uhci-hcd
> 
> 00:10.4 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 86) (prog-if 20
> [EHCI])
>         Subsystem: VIA Technologies, Inc. USB 2.0
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 96, Cache Line Size: 64 bytes
>         Interrupt: pin C routed to IRQ 21
>         Region 0: Memory at fe900000 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [80] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: ehci_hcd
>         Kernel modules: ehci-hcd
> 
> 00:11.0 ISA bridge: VIA Technologies, Inc. VT8237 ISA bridge
> [KT600/K8T800/K8T890 South]
>         Subsystem: ASUSTeK Computer Inc. A7V600/K8V-X/A8V Deluxe motherboard
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel modules: i2c-viapro
> 
> 00:11.5 Multimedia audio controller: VIA Technologies, Inc. VT8233/A/8235/8237
> AC97 Audio Controller (rev 60)
>         Subsystem: ASUSTeK Computer Inc. Asus P5VD1-X (AD1888 codec [SoundMax])
>         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin C routed to IRQ 22
>         Region 0: I/O ports at e400 [size=256]
>         Capabilities: [c0] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: VIA 82xx Audio
>         Kernel modules: snd-via82xx
> 
> 00:11.6 Communication controller: VIA Technologies, Inc. AC'97 Modem Controller
> (rev 80)
>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Interrupt: pin C routed to IRQ 0
>         Region 0: I/O ports at 1000 [disabled] [size=256]
>         Capabilities: [d0] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> 
> 01:00.0 VGA compatible controller: nVidia Corporation NV34 [GeForce FX 5200]
> (rev a1) (prog-if 00 [VGA controller])
>         Subsystem: XFX Pine Group Inc. Unknown device 1280
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 248 (1250ns min, 250ns max)
>         Interrupt: pin A routed to IRQ 16
>         Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
>         Region 1: Memory at a0000000 (32-bit, prefetchable) [size=128M]
>         [virtual] Expansion ROM at fe200000 [disabled] [size=128K]
>         Capabilities: [60] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [44] AGP version 3.0
>                 Status: RQ=32 Iso- ArqSz=0 Cal=3 SBA+ ITACoh- GART64- HTrans-
> 64bit- FW+ AGP3+ Rate=x4,x8
>                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW-
> Rate=<none>
>         Kernel driver in use: nvidia
>         Kernel modules: nvidia
> 
> 

