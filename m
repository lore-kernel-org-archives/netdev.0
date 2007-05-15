From: David LAMPARTER <lists-cEeocvCgqOOsTnJN9+BGXg@public.gmane.org>
Subject: Panic in ieee_80211_ibss_add_sta when trying to join ad-hoc network (rt2500pci)
Date: Tue, 15 May 2007 17:28:42 +0200
Message-ID: <20070515152842.GA26481@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NMuMz9nt05w80d4+"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--NMuMz9nt05w80d4+
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello,


while trying to get my wireless to work (a Ralink RT2560, as
sold in a Fujitsu-Siemens Amilo A 1630), I've been hitting the
following Panic twice:

BUG: unable to handle kernel NULL pointer derference at virtual address 00000218
[...]
EIP is at ieee80211_ibss_add_sta+0xae/0x130
[...]
EIP: [<c05773fe>] ieee_80211_ibss_add_sta+0xae/0x130 SS:ESP 0068:f641dc38
Kernel panic - not syncing: Fatal exception in interrupt

The bug seems to be triggered as soon as the stack tries to
join my router's ad-hoc; it happen either directly when
doing "ip l s wlan0 up" as well as when doing
"iwconfig wlan0 essid equinox" (when it did not immediately
find the network).

Kernel version is 2.6.21-ge42d23f4 (git checkout from
git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev,
about a few hours old.)

Full information set available at http://celeste.diac24.net/rtpanic/
(includes pictures of the panics, in case I have a typo somewhere)
Requests for more information / patches welcome, but expect delayed
response.

More information attached.


Greetings,

David Lamparter




--NMuMz9nt05w80d4+
Content-Type: text/plain; charset=utf-8
Content-Description: panic text
Content-Disposition: inline; filename=bugtext

BUG: unable to handle kernel NULL pointer derference at virtual address 00000218
 printing eip:
c05773fe
*pde = 00000000
Oops: 0000 [#1]
PREEMPT
Modules linked in: rt2500pci rt2x00pci rt2x00lib radeon drm
CPU:    0
EIP:    0060:[<c05773fe>]    Not tainted VLI
EFLAGS: 0010286    (2.6.21-ge42d23f3 #8)
EIP is at ieee80211_ibss_add_sta+0xae/0x130
eax: f76292c0   ebx: f78c381c   ecx: 00000000   edx: 00000102
esi: f6a091a0   edi: f76292c0   ebp: f6bb8000   esp: f641dc38
ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
Process ip (pid: 1621, ti=f641c000 task=f78f8c30 task.ti=f641c000)
Stack: 00000020 f782f800 00000000 00000001 000000e3 0000000f 000000ae 000000eb
       f6bb8000 f6a091a0 c193e8c0 f78c3822 f6bb83a0 00000002 f78c3812 c0569b8a
       f78c381c df82f5ea f7e90458 f7cfea10 00000001 f7cfea28 00000018 00000000
Call Trace:
 [<c0569b8a>] __ieee80211_rx+0xa5a/0xc10
 [<c0180b5a>] dentry_iput+0xda/0x120
 [<c056c34f>] ieee80211_tasklet_handler+0xaf/0xe0
 [<c02f3c9f>] _atomic_dec_and_loc+0x2f/0x50
 [<c0121c43>] tasklet_action+0x33/0x70
 [<c0121b72>] __do_softirq+0x52/0xa0
 [<c0121c05>] do_softirq+0x45/0x50
 [<c0122023>] local_bh_enable+0x53/0xa0
 [<c047f74b>] dev_mc_upload+0x3b/0x50
 [<c047d16c>] dev_open+0x5c/0x80
 [<c056d017>] ieee80211_open+0x317/0x420
 [<c0121b86>] __do_softirq+0x66/0xa0
 [<c047d149>] dev_open+0x39/0x80
 [<c047b8cc>] dev_change_flags+0x5c/0x140
 [<c04c3613>] devinet_ioctl+0x563/0x6e0
 [<c0472310>] sock_ioctl+0x0/0x1c0
 [<c04723bf>] sock_ioctl+0xaf/0x1c0
 [<c0472310>] sock_ioctl+0x0/0x1c0
 [<c017b81b>] do_ioctl+0x2b/0x90
 [<c017b8dc>] vfs_ioctl+0x5c/0x2b0
 [<c017bb6d>] sys_ioctl+0x3d/0x70
 [<c010406e>] sysenter_past_esp+0x5f/0x85
 =======================
Code: 00 00 00 c7 04 24 5c 09 6d c0 89 44 24 04 e8 fa 5f ba ff 89 d9 89 ea 89 f0 c7 04 24 20 00 00 00 e8 48 d1 ff ff 85 c0 89 c7 74 95 <a1> 18 02 00 00 8b 97 8c 00 00 00 89 f1 89 47 64 8b 87 88 00 00
EIP: [<c05773fe>] ieee_80211_ibss_add_sta+0xae/0x130 SS:ESP 0068:f641dc38
Kernel panic - not syncing: Fatal exception in interrupt


--NMuMz9nt05w80d4+
Content-Type: text/plain; charset=utf-8
Content-Description: kernel version
Content-Disposition: inline; filename=proc_version

Linux version 2.6.21-ge42d23f4 (root@neptune) (gcc version 4.1.2) #8 PREEMPT Tue May 15 14:08:04 CEST 2007

--NMuMz9nt05w80d4+
Content-Type: text/plain; charset=utf-8
Content-Description: lspci output
Content-Disposition: attachment; filename=lspci

00:00.0 Host bridge: Silicon Integrated Systems [SiS] 755 Host (rev 01)
	Subsystem: Silicon Integrated Systems [SiS] 755 Host
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32
	Region 0: Memory at e0000000 (32-bit, non-prefetchable) [size=128M]
	Capabilities: [a0] AGP version 3.0
		Status: RQ=32 Iso- ArqSz=2 Cal=3 SBA+ ITACoh- GART64- HTrans- 64bit- FW- AGP3+ Rate=x4,x8
		Command: RQ=1 ArqSz=0 Cal=0 SBA+ AGP+ GART64- 64bit- FW- Rate=x8
	Capabilities: [d0] HyperTransport: Slave or Primary Interface
		!!! Possibly incomplete decoding
		Command: BaseUnitID=0 UnitCnt=9 MastHost- DefDir-
		Link Control 0: CFlE- CST- CFE- <LkFail- Init+ EOC+ TXO- <CRCErr=0
		Link Config 0: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Link Control 1: CFlE- CST- CFE- <LkFail+ Init- EOC+ TXO+ <CRCErr=0
		Link Config 1: MLWI=N/C MLWO=N/C LWI=N/C LWO=N/C
		Revision ID: 1.02
	Capabilities: [f0] HyperTransport: Interrupt Discovery and Configuration

00:01.0 PCI bridge: Silicon Integrated Systems [SiS] SG86C202 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: fea00000-feafffff
	Prefetchable memory behind bridge: ee900000-fe8fffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-

00:02.0 ISA bridge: Silicon Integrated Systems [SiS] SiS963 [MuTIOL Media IO] (rev 25)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:02.1 SMBus: Silicon Integrated Systems [SiS] SiS961/2 SMBus Controller
	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 0
	Region 4: I/O ports at 0c00 [size=32]

00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE] (prog-if 80 [Master])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 128
	Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [disabled] [size=1]
	Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [disabled] [size=8]
	Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [disabled] [size=1]
	Region 4: I/O ports at ffa0 [size=16]

00:02.6 Modem: Silicon Integrated Systems [SiS] AC'97 Modem Controller (rev a0) (prog-if 00 [Generic])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (13000ns min, 2750ns max)
	Interrupt: pin C routed to IRQ 22
	Region 0: I/O ports at e400 [size=256]
	Region 1: I/O ports at e000 [size=128]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=55mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:02.7 Multimedia audio controller: Silicon Integrated Systems [SiS] AC'97 Sound Controller (rev a0)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (13000ns min, 2750ns max)
	Interrupt: pin C routed to IRQ 22
	Region 0: I/O ports at e800 [size=256]
	Region 1: I/O ports at ec00 [size=128]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=55mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:03.0 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 Controller (rev 0f) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (20000ns max)
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at febfd000 (32-bit, non-prefetchable) [size=4K]

00:03.1 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 Controller (rev 0f) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (20000ns max)
	Interrupt: pin B routed to IRQ 21
	Region 0: Memory at febfe000 (32-bit, non-prefetchable) [size=4K]

00:03.3 USB Controller: Silicon Integrated Systems [SiS] USB 2.0 Controller (prog-if 20 [EHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (20000ns max)
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at febff000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI Fast Ethernet (rev 91)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (13000ns min, 2750ns max)
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at d800 [size=256]
	Region 1: Memory at febfc000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at febc0000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:06.0 FireWire (IEEE 1394): Texas Instruments TSB43AB22/A IEEE-1394a-2000 Controller (PHY/Link) (prog-if 10 [OHCI])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (500ns min, 1000ns max), Cache Line Size 10
	Interrupt: pin A routed to IRQ 5
	Region 0: Memory at febfb800 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at febf4000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:09.0 CardBus bridge: O2 Micro, Inc. OZ711M1/MC1 4-in-1 MemoryCardBus Controller (rev 20)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 168, Cache Line Size 10
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at 60000000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=00, secondary=02, subordinate=05, sec-latency=176
	Memory window 0: 50000000-53fff000 (prefetchable)
	Memory window 1: 54000000-57fff000
	I/O window 0: 00001000-000010ff
	I/O window 1: 00001400-000014ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
	16-bit legacy interface ports at 0001

00:09.1 CardBus bridge: O2 Micro, Inc. OZ711M1/MC1 4-in-1 MemoryCardBus Controller (rev 20)
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 168, Cache Line Size 10
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at 60001000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=00, secondary=06, subordinate=09, sec-latency=176
	Memory window 0: 58000000-5bfff000 (prefetchable)
	Memory window 1: 5c000000-5ffff000
	I/O window 0: 00001800-000018ff
	I/O window 1: 00001c00-00001cff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset- 16bInt+ PostWrite+
	16-bit legacy interface ports at 0001

00:09.2 System peripheral: O2 Micro, Inc. OZ711Mx 4-in-1 MemoryCardBus Accelerator
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at febfa000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:0b.0 Network controller: RaLink RT2500 802.11g Cardbus/mini-PCI (rev 01)
	Subsystem: Micro-Star International Co., Ltd. Unknown device 6833
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 10
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at febf8000 (32-bit, non-prefetchable) [size=8K]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=0
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

01:00.0 VGA compatible controller: ATI Technologies Inc RV350 [Mobility Radeon 9600 M10] (prog-if 00 [VGA])
	Subsystem: Fujitsu Siemens Computer GmbH Unknown device 105f
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (2000ns min), Cache Line Size 10
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
	Region 1: I/O ports at c800 [size=256]
	Region 2: Memory at feaf0000 (32-bit, non-prefetchable) [size=64K]
	Expansion ROM at feac0000 [disabled] [size=128K]
	Capabilities: [58] AGP version 3.0
		Status: RQ=256 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW+ AGP3+ Rate=x4,x8
		Command: RQ=32 ArqSz=2 Cal=0 SBA+ AGP+ GART64- 64bit- FW- Rate=x8
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-


--NMuMz9nt05w80d4+
Content-Type: application/x-gunzip
Content-Description: config.gz
Content-Disposition: attachment; filename="proc_config.gz"
Content-Transfer-Encoding: base64

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

--NMuMz9nt05w80d4+
Content-Type: text/plain; charset=utf-8
Content-Description: relevant .config
Content-Disposition: inline; filename=relevant_config

CONFIG_CFG80211=y
CONFIG_NL80211=y
CONFIG_MAC80211=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUG is not set
# CONFIG_IEEE80211 is not set
# CONFIG_WLAN_PRE80211 is not set
CONFIG_WLAN_80211=y
# CONFIG_BCM43XX_MAC80211 is not set
CONFIG_RT2X00=m
CONFIG_RT2X00_LIB=m
CONFIG_RT2X00_LIB_PCI=m
# CONFIG_RT2400PCI is not set
CONFIG_RT2500PCI=m
# CONFIG_RT2500USB is not set
# CONFIG_RT2X00_DEBUG is not set
# CONFIG_ZD1211RW_MAC80211 is not set

--NMuMz9nt05w80d4+--
