From: rupert THURNER <rupert.thurner@gmail.com>
Subject: Re: linux <=4.9.5, 4.10-rc7 ok, 4.9.6 - 4.9.8 nok with realtek wlan, atom
Date: Sat, 11 Feb 2017 18:42:57 +0100
Message-ID: <CAJs9aZ_Fps=DsGLi5qz=USf1g0meLJGhWOb+-G6Ap9p6oxbx2Q@mail.gmail.com>
References: <CAJs9aZ9FqU-NCj2egBp6J06uD_Qp3Lje=mSSVbV4vNcYGKdumA@mail.gmail.com>
 <20170209194321.GC11905@bhelgaas-glaptop.roam.corp.google.com> <da188e74-3c2b-10ba-9c4e-21b691cc2b31@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Bjorn Helgaas <helgaas@kernel.org>, linux-pci@vger.kernel.org,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <da188e74-3c2b-10ba-9c4e-21b691cc2b31@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 9, 2017 at 9:09 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> On 02/09/2017 01:43 PM, Bjorn Helgaas wrote:
>>
>> [+cc rtl8192ce folks in case they've seen this]
>>
>> On Thu, Feb 09, 2017 at 03:45:01PM +0100, rupert THURNER wrote:
>>>
>>> hi,
>>>
>>> not technical expert enough, i just wanted to give a short user
>>> feedback. for realtek wlan on atom, kernels up to 4.9.5 are ok, and
>>> kernel 4.10.0-rc7-g926af6273fc6 (arch linux-git version numbering) as
>>> well. kernels 4.9.6, 4.9.7, and 4.9.8 fail, i.e. connection to a WLAN
>>> hotspot is possible then drops, or connecting to wlan fails
>>> alltogether.
>>
>>
>> Thanks very much for your report, and sorry for the inconvenience.
>>
>> v4.10-rc7 works, so I guess we don't need to worry about fixing v4.10.
>>
>> But the stable kernels v4.9.6, v4.9.7, and v4.9.8 are broken, so we
>> need to figure out why and make sure we fix the v4.9 stable series.
>>
>> I can't tell yet whether this is PCI-related or not.  If it is,
>> 4922a6a5cfa7 ("PCI: Enumerate switches below PCI-to-PCIe bridges")
>> appeared in v4.9.6, and there is a known issue with that.  The issue
>> should be fixed by 610c2b7ff8f6 ("PCI/ASPM: Handle PCI-to-PCIe bridges
>> as roots of PCIe hierarchies"), which appeared in v4.9.9, so I guess
>> the first thing to do would be to test v4.9.9.
>>
>> If it's not fixed in v4.9.9, can you share the complete dmesg log
>> (output of "dmesg" command) and "lspci -vv" output for v4.9.5 (last
>> known working version) and v4.9.6 (first known broken version)?  On
>> v4.9.6, collect the dmesg output after the failure occurs.
>
> It would be helpful if someone were to bisect this issue. The only issue
> that comes to mind was fixed in commit 52f5631a4c05 ("rtlwifi: rtl8192ce:
> Fix loading of incorrect firmware") which is in 4.10-rc7 and will be
> backported to 4.9.

thanks for the quick and very helpful hints! larry, it matches what
you write - 4.9.9 dropped the connection after a couple of hours.
lspci -vv is the same for 4.9.5 and 4.9.6. dmesg for both below. in
this case with 4.9.6 it did never get a network connection after boot.

$ sudo lspci -vv
00:00.0 Host bridge: Intel Corporation Atom Processor
D4xx/D5xx/N4xx/N5xx DMI Bridge (rev 02)
Subsystem: Intel Corporation Atom Processor D4xx/D5xx/N4xx/N5xx DMI Bridge
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR- INTx-
Latency: 0
Capabilities: [e0] Vendor Specific Information: Len=08 <?>
Kernel modules: intel_agp

00:1b.0 Audio device: Intel Corporation NM10/ICH7 Family High
Definition Audio Controller (rev 02)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 27
Region 0: Memory at fcffc000 (64-bit, non-prefetchable) [size=16K]
Capabilities: [50] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [60] MSI: Enable+ Count=1/1 Maskable- 64bit+
Address: 00000000fee0f00c  Data: 4152
Capabilities: [70] Express (v1) Root Complex Integrated Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0
ExtTag- RBE-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
Capabilities: [100 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed- WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
Status: NegoPending- InProgress-
Capabilities: [130 v1] Root Complex Link
Desc: PortNumber=0f ComponentID=00 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c000
Kernel driver in use: snd_hda_intel
Kernel modules: snd_hda_intel

00:1c.0 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 1 (rev 02) (prog-if 00 [Normal decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 24
Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
I/O behind bridge: 0000c000-0000cfff
Memory behind bridge: fd000000-fe9fffff
Prefetchable memory behind bridge: 00000000ce000000-00000000dfffffff
Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0
ExtTag- RBE-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <4us
ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
Slot #32, PowerLimit 10.000W; Interlock- NoCompl-
SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
Changed: MRL- PresDet+ LinkState+
RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
RootCap: CRSVisible-
RootSta: PME ReqID 0000, PMEStatus- PMEPending-
Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0f00c  Data: 41a1
Capabilities: [90] Subsystem: Holco Enterprise Co, Ltd/Shuttle
Computer Device 2005
Capabilities: [a0] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [100 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed+ WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
Status: NegoPending- InProgress-
Capabilities: [180 v1] Root Complex Link
Desc: PortNumber=01 ComponentID=00 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c001
Kernel driver in use: pcieport
Kernel modules: shpchp

00:1c.1 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 2 (rev 02) (prog-if 00 [Normal decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin B routed to IRQ 25
Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
I/O behind bridge: 0000d000-0000dfff
Memory behind bridge: fea00000-feafffff
Prefetchable memory behind bridge: 0000000080000000-00000000801fffff
Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0
ExtTag- RBE-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #2, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <4us
ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
Slot #33, PowerLimit 10.000W; Interlock- NoCompl-
SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
Changed: MRL- PresDet+ LinkState+
RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
RootCap: CRSVisible-
RootSta: PME ReqID 0000, PMEStatus- PMEPending-
Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0f00c  Data: 41c1
Capabilities: [90] Subsystem: Holco Enterprise Co, Ltd/Shuttle
Computer Device 2005
Capabilities: [a0] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [100 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed+ WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
Status: NegoPending- InProgress-
Capabilities: [180 v1] Root Complex Link
Desc: PortNumber=02 ComponentID=00 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c001
Kernel driver in use: pcieport
Kernel modules: shpchp

00:1c.3 PCI bridge: Intel Corporation NM10/ICH7 Family PCI Express
Port 4 (rev 02) (prog-if 00 [Normal decode])
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin D routed to IRQ 26
Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
I/O behind bridge: 0000e000-0000efff
Memory behind bridge: feb00000-febfffff
Prefetchable memory behind bridge: 0000000080200000-00000000803fffff
Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [40] Express (v1) Root Port (Slot+), MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0
ExtTag- RBE-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #4, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <4us
ClockPM- Surprise- LLActRep+ BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive+
BWMgmt- ABWMgmt-
SltCap: AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug+ Surprise+
Slot #35, PowerLimit 10.000W; Interlock- NoCompl-
SltCtl: Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
Control: AttnInd Unknown, PwrInd Unknown, Power- Interlock-
SltSta: Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
Changed: MRL- PresDet- LinkState+
RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
RootCap: CRSVisible-
RootSta: PME ReqID 0000, PMEStatus- PMEPending-
Capabilities: [80] MSI: Enable+ Count=1/1 Maskable- 64bit-
Address: fee0f00c  Data: 41e1
Capabilities: [90] Subsystem: Holco Enterprise Co, Ltd/Shuttle
Computer Device 2005
Capabilities: [a0] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [100 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed+ WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
VC1: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed+ WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable- ID=0 ArbSelect=Fixed TC/VC=00
Status: NegoPending- InProgress-
Capabilities: [180 v1] Root Complex Link
Desc: PortNumber=04 ComponentID=00 EltType=Config
Link0: Desc: TargetPort=00 TargetComponent=00 AssocRCRB-
LinkType=MemMapped LinkValid+
Addr: 00000000fed1c001
Kernel driver in use: pcieport
Kernel modules: shpchp

00:1d.0 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #1 (rev 02) (prog-if 00 [UHCI])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 23
Region 4: I/O ports at bc00 [size=32]
Kernel driver in use: uhci_hcd
Kernel modules: uhci_hcd

00:1d.1 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #2 (rev 02) (prog-if 00 [UHCI])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 19
Region 4: I/O ports at b880 [size=32]
Kernel driver in use: uhci_hcd
Kernel modules: uhci_hcd

00:1d.2 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #3 (rev 02) (prog-if 00 [UHCI])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin C routed to IRQ 18
Region 4: I/O ports at b800 [size=32]
Kernel driver in use: uhci_hcd
Kernel modules: uhci_hcd

00:1d.3 USB controller: Intel Corporation NM10/ICH7 Family USB UHCI
Controller #4 (rev 02) (prog-if 00 [UHCI])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin D routed to IRQ 16
Region 4: I/O ports at b480 [size=32]
Kernel driver in use: uhci_hcd
Kernel modules: uhci_hcd

00:1d.7 USB controller: Intel Corporation NM10/ICH7 Family USB2 EHCI
Controller (rev 02) (prog-if 20 [EHCI])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin A routed to IRQ 23
Region 0: Memory at fcffbc00 (32-bit, non-prefetchable) [size=1K]
Capabilities: [50] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [58] Debug port: BAR=1 offset=00a0
Kernel driver in use: ehci-pci
Kernel modules: ehci_pci

00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev e2)
(prog-if 01 [Subtractive decode])
Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR+ FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Bus: primary=00, secondary=04, subordinate=04, sec-latency=32
Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort+ <SERR- <PERR-
BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
Capabilities: [50] Subsystem: Holco Enterprise Co, Ltd/Shuttle
Computer Device 2005

00:1f.0 ISA bridge: Intel Corporation NM10 Family LPC Controller (rev 02)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Capabilities: [e0] Vendor Specific Information: Len=0c <?>
Kernel driver in use: lpc_ich
Kernel modules: lpc_ich

00:1f.2 IDE interface: Intel Corporation NM10/ICH7 Family SATA
Controller [IDE mode] (rev 02) (prog-if 8a [Master SecP PriP])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0
Interrupt: pin B routed to IRQ 19
Region 0: I/O ports at 01f0 [size=8]
Region 1: I/O ports at 03f4
Region 2: I/O ports at 0170 [size=8]
Region 3: I/O ports at 0374
Region 4: I/O ports at ff90 [size=16]
Region 5: Memory at 80400000 (32-bit, non-prefetchable) [size=1K]
Capabilities: [70] Power Management version 2
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
Kernel driver in use: ata_piix
Kernel modules: ata_piix, pata_acpi, ata_generic

00:1f.3 SMBus: Intel Corporation NM10/ICH7 Family SMBus Controller (rev 02)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Interrupt: pin B routed to IRQ 19
Region 4: I/O ports at 0400 [size=32]
Kernel driver in use: i801_smbus
Kernel modules: i2c_i801

01:00.0 VGA compatible controller: NVIDIA Corporation GT218 [ION] (rev
a2) (prog-if 00 [VGA controller])
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 4003
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx+
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 28
Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
Region 3: Memory at ce000000 (64-bit, prefetchable) [size=32M]
Region 5: I/O ports at cc00 [size=128]
Expansion ROM at 000c0000 [disabled] [size=128K]
Capabilities: [60] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [68] MSI: Enable+ Count=1/1 Maskable- 64bit+
Address: 00000000fee0f00c  Data: 4162
Capabilities: [78] Express (v2) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 <64us
ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 10.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag+ PhantFunc- AuxPwr- NoSnoop+
MaxPayload 128 bytes, MaxReadReq 512 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <4us
ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
Compliance De-emphasis: -6dB
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
Capabilities: [b4] Vendor Specific Information: Len=14 <?>
Capabilities: [100 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed- WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
Capabilities: [128 v1] Power Budgeting <?>
Capabilities: [600 v1] Vendor Specific Information: ID=0001 Rev=1 Len=024 <?>
Kernel driver in use: nouveau
Kernel modules: nouveau

01:00.1 Audio device: NVIDIA Corporation High Definition Audio
Controller (rev a1)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 4003
Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin B routed to IRQ 17
Region 0: Memory at fe97c000 (32-bit, non-prefetchable) [size=16K]
Capabilities: [60] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [68] MSI: Enable- Count=1/1 Maskable- 64bit+
Address: 0000000000000000  Data: 0000
Capabilities: [78] Express (v2) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 <64us
ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 10.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
MaxPayload 128 bytes, MaxReadReq 512 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
LnkCap: Port #0, Speed 2.5GT/s, Width x16, ASPM L0s L1, Exit Latency
L0s <256ns, L1 <1us
ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM L0s L1 Enabled; RCB 128 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
Kernel driver in use: snd_hda_intel
Kernel modules: snd_hda_intel

02:00.0 System peripheral: JMicron Technology Corp. SD/MMC Host
Controller (rev 80)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin B routed to IRQ 18
Region 0: Memory at feaffc00 (32-bit, non-prefetchable) [size=256]
Capabilities: [a4] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [80] Express (v1) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 0.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s unlimited, L1 unlimited
ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
Address: fffffffc  Data: 0000
Kernel driver in use: sdhci-pci
Kernel modules: sdhci_pci

02:00.2 SD Host controller: JMicron Technology Corp. Standard SD Host
Controller (rev 80) (prog-if 01)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Interrupt: pin B routed to IRQ 18
Region 0: Memory at feaff800 (32-bit, non-prefetchable) [size=256]
Capabilities: [a4] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [80] Express (v1) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 0.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s unlimited, L1 unlimited
ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
Address: fffffffc  Data: 0000
Kernel modules: sdhci_pci

02:00.3 System peripheral: JMicron Technology Corp. MS Host Controller (rev 80)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin B routed to IRQ 18
Region 0: Memory at feaff400 (32-bit, non-prefetchable) [size=256]
Capabilities: [a4] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [80] Express (v1) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 0.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 128 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s unlimited, L1 unlimited
ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
Capabilities: [94] MSI: Enable- Count=1/1 Maskable- 64bit-
Address: fffffffc  Data: 0000
Kernel driver in use: jmb38x_ms
Kernel modules: jmb38x_ms

02:00.5 Ethernet controller: JMicron Technology Corp. JMC250 PCI
Express Gigabit Ethernet Controller (rev 03)
Subsystem: Holco Enterprise Co, Ltd/Shuttle Computer Device 2005
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 17
Region 0: Memory at feaf4000 (32-bit, non-prefetchable) [size=16K]
Region 2: I/O ports at dc00 [size=128]
Region 3: I/O ports at d800 [size=256]
Capabilities: [68] Power Management version 3
Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [50] Express (v1) Legacy Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 512 bytes
DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <64ns, L1 <1us
ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
Capabilities: [40] MSI-X: Enable- Count=8 Masked-
Vector table: BAR=0 offset=00002000
PBA: BAR=0 offset=00003000
Capabilities: [70] MSI: Enable- Count=1/8 Maskable+ 64bit+
Address: 0000000000000000  Data: 0000
Masking: 00000000  Pending: 00000000
Kernel driver in use: jme
Kernel modules: jme

03:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8188CE
802.11b/g/n WiFi Adapter (rev 01)
Subsystem: Realtek Semiconductor Co., Ltd. RTL8188CE 802.11b/g/n WiFi Adapter
Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
Latency: 0, Cache Line Size: 32 bytes
Interrupt: pin A routed to IRQ 19
Region 0: I/O ports at e800 [size=256]
Region 2: Memory at febfc000 (64-bit, non-prefetchable) [size=16K]
Capabilities: [40] Power Management version 3
Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
Address: 0000000000000000  Data: 0000
Capabilities: [70] Express (v2) Endpoint, MSI 00
DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset- SlotPowerLimit 10.000W
DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
MaxPayload 128 bytes, MaxReadReq 512 bytes
DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Exit Latency
L0s <512ns, L1 <64us
ClockPM+ Surprise- LLActRep- BwNot- ASPMOptComp-
LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled- CommClk+
ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
DevCap2: Completion Timeout: Not Supported, TimeoutDis+, LTR-, OBFF
Not Supported
DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+, LTR-, OBFF Disabled
LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
Compliance De-emphasis: -6dB
LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
EqualizationPhase1-
EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
Capabilities: [100 v1] Advanced Error Reporting
UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
MalfTLP- ECRC- UnsupReq- ACSViol-
UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
MalfTLP+ ECRC- UnsupReq- ACSViol-
CESta: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
Capabilities: [140 v1] Virtual Channel
Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
Arb: Fixed- WRR32- WRR64- WRR128-
Ctrl: ArbSelect=Fixed
Status: InProgress-
VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=01
Status: NegoPending- InProgress-
Capabilities: [160 v1] Device Serial Number 02-91-41-ff-af-4c-e0-10
Kernel driver in use: rtl8192ce
Kernel modules: rtl8192ce

$ dmesg
[    0.000000] Linux version 4.9.5-1-ARCH (builduser@tobias) (gcc
version 6.3.1 20170109 (GCC) ) #1 SMP PREEMPT Fri Jan 20 12:11:50 CET
2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-linux
root=UUID=399040bd-474e-4c19-84b5-ae6235771846 rw quiet
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffaffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007ffb0000-0x000000007ffbdfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007ffbe000-0x000000007ffeffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007fff0000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffb00000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Standard XS35/B10IE01, BIOS 080015  06/23/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x7ffb0 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-DFFFF uncachable
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f]
mapped at [ffff8800000ff780]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] BRK [0x01d56000, 0x01d56fff] PGTABLE
[    0.000000] BRK [0x01d57000, 0x01d57fff] PGTABLE
[    0.000000] BRK [0x01d58000, 0x01d58fff] PGTABLE
[    0.000000] BRK [0x01d59000, 0x01d59fff] PGTABLE
[    0.000000] BRK [0x01d5a000, 0x01d5afff] PGTABLE
[    0.000000] RAMDISK: [mem 0x374c2000-0x37a58fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F9ED0 000024 (v02 ACPIAM)
[    0.000000] ACPI: XSDT 0x000000007FFB0100 000054 (v01 Shuttl
Shuttle  20110623 MSFT 00000097)
[    0.000000] ACPI: FACP 0x000000007FFB0290 0000F4 (v04 062311
FACP1651 20110623 MSFT 00000097)
[    0.000000] ACPI: DSDT 0x000000007FFB05C0 006645 (v02 XS35V
XS35V10  00000200 INTL 20051117)
[    0.000000] ACPI: FACS 0x000000007FFBE000 000040
[    0.000000] ACPI: FACS 0x000000007FFBE000 000040
[    0.000000] ACPI: APIC 0x000000007FFB0390 00006C (v02 062311
APIC1651 20110623 MSFT 00000097)
[    0.000000] ACPI: MCFG 0x000000007FFB0400 00003C (v01 062311
OEMMCFG  20110623 MSFT 00000097)
[    0.000000] ACPI: SLIC 0x000000007FFB0440 000176 (v01 Shuttl
Shuttle  20110623 MSFT 00000097)
[    0.000000] ACPI: OEMB 0x000000007FFBE040 000072 (v01 062311
OEMB1651 20110623 MSFT 00000097)
[    0.000000] ACPI: HPET 0x000000007FFBA5C0 000038 (v01 062311
OEMHPET  20110623 MSFT 00000097)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000007ffaffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x7ffab000-0x7ffaffff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffaffff]
[    0.000000]   Normal   empty
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007ffaffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007ffaffff]
[    0.000000] On node 0 totalpages: 524110
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 8127 pages used for memmap
[    0.000000]   DMA32 zone: 520112 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] e820: [mem 0x80000000-0xfedfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff
max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] setup_percpu: NR_CPUS:128 nr_cpumask_bits:128
nr_cpu_ids:4 nr_node_ids:1
[    0.000000] percpu: Embedded 35 pages/cpu @ffff88007fc00000 s103448
r8192 d31720 u524288
[    0.000000] pcpu-alloc: s103448 r8192 d31720 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.
Total pages: 515898
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-linux
root=UUID=399040bd-474e-4c19-84b5-ae6235771846 rw quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 2043544K/2096440K available (6198K kernel code,
1069K rwdata, 1940K rodata, 1276K init, 1032K bss, 52896K reserved, 0K
cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] Build-time adjustment of leaf fanout to 64.
[    0.000000] RCU restricting CPUs from NR_CPUS=128 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:8448 nr_irqs:456 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1795.383 MHz processor
[    0.003353] Calibrating delay loop (skipped), value calculated
using timer frequency.. 3592.38 BogoMIPS (lpj=5984610)
[    0.003360] pid_max: default: 32768 minimum: 301
[    0.003398] ACPI: Core revision 20160831
[    0.019273] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.019367] Security Framework initialized
[    0.019371] Yama: becoming mindful.
[    0.019715] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.021447] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.022254] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.022265] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.022929] CPU: Physical Processor ID: 0
[    0.022933] CPU: Processor Core ID: 0
[    0.022936] mce: CPU supports 5 MCE banks
[    0.022947] CPU0: Thermal monitoring enabled (TM1)
[    0.022954] process: using mwait in idle threads
[    0.022962] Last level iTLB entries: 4KB 32, 2MB 0, 4MB 0
[    0.022964] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 8, 1GB 0
[    0.023519] Freeing SMP alternatives memory: 24K (ffffffff81c4c000
- ffffffff81c52000)
[    0.026683] ftrace: allocating 24600 entries in 97 pages
[    0.043559] smpboot: Max logical packages: 2
[    0.043992] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.079999] smpboot: CPU0: Intel(R) Atom(TM) CPU D525   @ 1.80GHz
(family: 0x6, model: 0x1c, stepping: 0xa)
[    0.079999] Performance Events: PEBS fmt0+, Atom events, 8-deep
LBR, Intel PMU driver.
[    0.079999] ... version:                3
[    0.079999] ... bit width:              40
[    0.079999] ... generic registers:      2
[    0.079999] ... value mask:             000000ffffffffff
[    0.079999] ... max period:             000000007fffffff
[    0.079999] ... fixed-purpose events:   3
[    0.079999] ... event mask:             0000000700000003
[    0.110238] NMI watchdog: enabled on all CPUs, permanently consumes
one hw-PMU counter.
[    0.143383] x86: Booting SMP configuration:
[    0.143387] .... node  #0, CPUs:      #1
[    0.006666] Disabled fast string operations
[    0.253376]  #2
[    0.006666] Disabled fast string operations
[    0.363382]  #3
[    0.006666] Disabled fast string operations
[    0.448688] TSC synchronization [CPU#0 -> CPU#3]:
[    0.448691] Measured 54 cycles TSC warp between CPUs, turning off TSC clock.
[    0.448701] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.448803] x86: Booted up 1 node, 4 CPUs
[    0.448803] smpboot: Total of 4 processors activated (14369.93 BogoMIPS)
[    0.450655] devtmpfs: initialized
[    0.450655] x86/mm: Memory block size: 128MB
[    0.459784] PM: Registering ACPI NVS region [mem
0x7ffbe000-0x7ffeffff] (204800 bytes)
[    0.460105] clocksource: jiffies: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.460219] pinctrl core: initialized pinctrl subsystem
[    0.460315] RTC time: 19:08:56, date: 02/10/17
[    0.460573] NET: Registered protocol family 16
[    0.470016] cpuidle: using governor ladder
[    0.483348] cpuidle: using governor menu
[    0.483411] ACPI: bus type PCI registered
[    0.483415] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.483592] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.483597] PCI: not using MMCONFIG
[    0.483599] PCI: Using configuration type 1 for base access
[    0.483755] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.483757] mtrr: probably your BIOS does not setup all CPUs.
[    0.483758] mtrr: corrected configuration.
[    0.496770] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.496882] ACPI: Added _OSI(Module Device)
[    0.496886] ACPI: Added _OSI(Processor Device)
[    0.496888] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.496891] ACPI: Added _OSI(Processor Aggregator Device)
[    0.497213] ACPI: Executed 1 blocks of module-level executable AML code
[    0.503049] ACPI Error: No handler for Region [ECRM]
(ffff88007d09b360) [EmbeddedControl] (20160831/evregion-166)
[    0.503074] ACPI Error: Region EmbeddedControl (ID=3) has no
handler (20160831/exfldio-299)
[    0.503092] ACPI Error: Method parse/execution failed
[\_SB.PCI0.SBRG.EC0._REG] (Node ffff88007d09d280), AE_NOT_EXIST
(20160831/psparse-543)
[    0.504921] ACPI : EC: EC started
[    0.983443] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as first EC
[    0.983448] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x1d,
EC_CMD/EC_SC=0x66, EC_DATA=0x62
[    0.983452] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to
handle transactions
[    0.983453] ACPI: Interpreter enabled
[    0.983499] ACPI: (supports S0 S3 S4 S5)
[    0.983502] ACPI: Using IOAPIC for interrupt routing
[    0.983589] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.985989] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved
in ACPI motherboard resources
[    0.986033] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and report a bug
[    0.999129] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.999143] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
[    0.999154] acpi PNP0A08:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.999771] PCI host bridge to bus 0000:00
[    0.999778] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.999782] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.999786] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff window]
[    0.999790] pci_bus 0000:00: root bus resource [mem
0x000d0000-0x000dffff window]
[    0.999794] pci_bus 0000:00: root bus resource [mem
0x80000000-0xdfffffff window]
[    0.999798] pci_bus 0000:00: root bus resource [mem
0xf0000000-0xfed8ffff window]
[    0.999802] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.999818] pci 0000:00:00.0: [8086:a000] type 00 class 0x060000
[    1.000097] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    1.000119] pci 0000:00:1b.0: reg 0x10: [mem 0xfcffc000-0xfcffffff 64bit]
[    1.000204] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    1.000328] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    1.000442] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    1.000529] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    1.000644] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    1.000760] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    1.000844] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    1.000960] pci 0000:00:1c.1: System wakeup disabled by ACPI
[    1.001073] pci 0000:00:1c.3: [8086:27d6] type 01 class 0x060400
[    1.001157] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    1.001410] pci 0000:00:1c.3: System wakeup disabled by ACPI
[    1.001526] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    1.001569] pci 0000:00:1d.0: reg 0x20: [io  0xbc00-0xbc1f]
[    1.001747] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    1.001862] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    1.001905] pci 0000:00:1d.1: reg 0x20: [io  0xb880-0xb89f]
[    1.002084] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    1.002196] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    1.002239] pci 0000:00:1d.2: reg 0x20: [io  0xb800-0xb81f]
[    1.002411] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    1.002521] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    1.002564] pci 0000:00:1d.3: reg 0x20: [io  0xb480-0xb49f]
[    1.002741] pci 0000:00:1d.3: System wakeup disabled by ACPI
[    1.002859] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    1.002880] pci 0000:00:1d.7: reg 0x10: [mem 0xfcffbc00-0xfcffbfff]
[    1.002969] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    1.003079] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    1.003190] pci 0000:00:1e.0: [8086:2448] type 01 class 0x060401
[    1.003375] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    1.003493] pci 0000:00:1f.0: [8086:27bc] type 00 class 0x060100
[    1.003579] pci 0000:00:1f.0: [Firmware Bug]: TigerPoint LPC.BM_STS cleared
[    1.003805] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018a
[    1.003821] pci 0000:00:1f.2: reg 0x10: [io  0x0000-0x0007]
[    1.003831] pci 0000:00:1f.2: reg 0x14: [io  0x0000-0x0003]
[    1.003841] pci 0000:00:1f.2: reg 0x18: [io  0x0000-0x0007]
[    1.003850] pci 0000:00:1f.2: reg 0x1c: [io  0x0000-0x0003]
[    1.003860] pci 0000:00:1f.2: reg 0x20: [io  0xff90-0xff9f]
[    1.003870] pci 0000:00:1f.2: reg 0x24: [mem 0x0000fc00-0x0000ffff]
[    1.003883] pci 0000:00:1f.2: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.003886] pci 0000:00:1f.2: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.003890] pci 0000:00:1f.2: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.003893] pci 0000:00:1f.2: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.003926] pci 0000:00:1f.2: PME# supported from D3hot
[    1.004132] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    1.004185] pci 0000:00:1f.3: reg 0x20: [io  0x0400-0x041f]
[    1.004496] pci 0000:01:00.0: [10de:0a6f] type 00 class 0x030000
[    1.004520] pci 0000:01:00.0: reg 0x10: [mem 0xfd000000-0xfdffffff]
[    1.004538] pci 0000:01:00.0: reg 0x14: [mem 0xd0000000-0xdfffffff
64bit pref]
[    1.004557] pci 0000:01:00.0: reg 0x1c: [mem 0xce000000-0xcfffffff
64bit pref]
[    1.004570] pci 0000:01:00.0: reg 0x24: [io  0xcc00-0xcc7f]
[    1.004583] pci 0000:01:00.0: reg 0x30: [mem 0xfe980000-0xfe9fffff pref]
[    1.004785] pci 0000:01:00.1: [10de:0be3] type 00 class 0x040300
[    1.004807] pci 0000:01:00.1: reg 0x10: [mem 0xfe97c000-0xfe97ffff]
[    1.013374] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    1.013380] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    1.013386] pci 0000:00:1c.0:   bridge window [mem 0xfd000000-0xfe9fffff]
[    1.013394] pci 0000:00:1c.0:   bridge window [mem
0xce000000-0xdfffffff 64bit pref]
[    1.013548] pci 0000:02:00.0: [197b:2382] type 00 class 0x088000
[    1.013576] pci 0000:02:00.0: reg 0x10: [mem 0xfeaffc00-0xfeaffcff]
[    1.013879] pci 0000:02:00.2: [197b:2381] type 00 class 0x080501
[    1.013906] pci 0000:02:00.2: reg 0x10: [mem 0xfeaff800-0xfeaff8ff]
[    1.014185] pci 0000:02:00.3: [197b:2383] type 00 class 0x088000
[    1.014212] pci 0000:02:00.3: reg 0x10: [mem 0xfeaff400-0xfeaff4ff]
[    1.014493] pci 0000:02:00.5: [197b:0250] type 00 class 0x020000
[    1.014520] pci 0000:02:00.5: reg 0x10: [mem 0xfeaf4000-0xfeaf7fff]
[    1.014547] pci 0000:02:00.5: reg 0x18: [io  0xdc00-0xdc7f]
[    1.014563] pci 0000:02:00.5: reg 0x1c: [io  0xd800-0xd8ff]
[    1.014687] pci 0000:02:00.5: PME# supported from D0 D3hot D3cold
[    1.014757] pci 0000:02:00.5: System wakeup disabled by ACPI
[    1.023368] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    1.023375] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
[    1.023380] pci 0000:00:1c.1:   bridge window [mem 0xfea00000-0xfeafffff]
[    1.023524] pci 0000:03:00.0: [10ec:8176] type 00 class 0x028000
[    1.023550] pci 0000:03:00.0: reg 0x10: [io  0xe800-0xe8ff]
[    1.023585] pci 0000:03:00.0: reg 0x18: [mem 0xfebfc000-0xfebfffff 64bit]
[    1.023713] pci 0000:03:00.0: supports D1 D2
[    1.023717] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    1.033366] pci 0000:00:1c.3: PCI bridge to [bus 03]
[    1.033372] pci 0000:00:1c.3:   bridge window [io  0xe000-0xefff]
[    1.033378] pci 0000:00:1c.3:   bridge window [mem 0xfeb00000-0xfebfffff]
[    1.033511] pci 0000:00:1e.0: PCI bridge to [bus 04] (subtractive decode)
[    1.033524] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7
window] (subtractive decode)
[    1.033528] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff
window] (subtractive decode)
[    1.033532] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff window] (subtractive decode)
[    1.033536] pci 0000:00:1e.0:   bridge window [mem
0x000d0000-0x000dffff window] (subtractive decode)
[    1.033540] pci 0000:00:1e.0:   bridge window [mem
0x80000000-0xdfffffff window] (subtractive decode)
[    1.033544] pci 0000:00:1e.0:   bridge window [mem
0xf0000000-0xfed8ffff window] (subtractive decode)
[    1.035190] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 *10 11 12 14 15)
[    1.035348] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 *11 12 14 15)
[    1.035516] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 *7 10 11 12 14 15)
[    1.035671] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 7 10 11 12 14 15)
[    1.035825] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.035980] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.036135] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.036290] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 7 10 11 12 14 15)
[    1.036544] ACPI: Enabled 3 GPEs in block 00 to 1F
[    1.036739] ACPI : EC: event unblocked
[    1.036750] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x1d,
EC_CMD/EC_SC=0x66, EC_DATA=0x62
[    1.036754] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to
handle transactions and events
[    1.037063] vgaarb: setting as boot device: PCI:0000:01:00.0
[    1.037063] vgaarb: device added:
PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    1.037063] vgaarb: loaded
[    1.037063] vgaarb: bridge control possible 0000:01:00.0
[    1.037063] PCI: Using ACPI for IRQ routing
[    1.041104] PCI: pci_cache_line_size set to 64 bytes
[    1.041189] pci 0000:00:1f.2: can't claim BAR 5 [mem
0x0000fc00-0x0000ffff]: no compatible bridge window
[    1.041197] e820: reserve RAM buffer [mem 0x0009f800-0x0009ffff]
[    1.041201] e820: reserve RAM buffer [mem 0x7ffb0000-0x7fffffff]
[    1.041506] NetLabel: Initializing
[    1.041508] NetLabel:  domain hash size = 128
[    1.041510] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.041542] NetLabel:  unlabeled traffic allowed by default
[    1.043406] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    1.043412] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    1.043420] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    1.046720] clocksource: Switched to clocksource hpet
[    1.069286] VFS: Disk quotas dquot_6.6.0
[    1.069342] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.069574] pnp: PnP ACPI init
[    1.069778] system 00:00: [mem 0xfed14000-0xfed19fff] has been reserved
[    1.069783] system 00:00: [mem 0xfed90000-0xfed93fff] has been reserved
[    1.069793] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.069977] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.070161] pnp 00:02: Plug and Play ACPI device, IDs PNP0303
PNP030b (active)
[    1.070343] pnp 00:03: Plug and Play ACPI device, IDs PNP0f03
PNP0f13 (active)
[    1.070693] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    1.070698] system 00:04: [io  0x0800-0x087f] has been reserved
[    1.070703] system 00:04: [io  0x0480-0x04bf] has been reserved
[    1.070709] system 00:04: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    1.070713] system 00:04: [mem 0xfed20000-0xfed8ffff] has been reserved
[    1.070722] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.071004] system 00:05: [mem 0xffc00000-0xffefffff] has been reserved
[    1.071012] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.071335] system 00:06: [mem 0xfec00000-0xfec00fff] could not be reserved
[    1.071340] system 00:06: [mem 0xfee00000-0xfee00fff] has been reserved
[    1.071349] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.071528] system 00:07: [mem 0xe0000000-0xefffffff] has been reserved
[    1.071537] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.072026] system 00:08: [mem 0x00000000-0x0009ffff] could not be reserved
[    1.072032] system 00:08: [mem 0x000c0000-0x000cffff] could not be reserved
[    1.072037] system 00:08: [mem 0x000e0000-0x000fffff] could not be reserved
[    1.072041] system 00:08: [mem 0x00100000-0x7fffffff] could not be reserved
[    1.072046] system 00:08: [mem 0xfed90000-0xffffffff] could not be reserved
[    1.072054] system 00:08: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.072404] pnp: PnP ACPI: found 9 devices
[    1.083644] clocksource: acpi_pm: mask: 0xffffff max_cycles:
0xffffff, max_idle_ns: 2085701024 ns
[    1.083695] pci 0000:00:1c.1: bridge window [mem
0x00100000-0x000fffff 64bit pref] to [bus 02] add_size 200000
add_align 100000
[    1.083707] pci 0000:00:1c.3: bridge window [mem
0x00100000-0x000fffff 64bit pref] to [bus 03] add_size 200000
add_align 100000
[    1.083729] pci 0000:00:1c.1: res[15]=[mem 0x00100000-0x000fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.083734] pci 0000:00:1c.1: res[15]=[mem 0x00100000-0x002fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.083739] pci 0000:00:1c.3: res[15]=[mem 0x00100000-0x000fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.083744] pci 0000:00:1c.3: res[15]=[mem 0x00100000-0x002fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.083760] pci 0000:00:1c.1: BAR 15: assigned [mem
0x80000000-0x801fffff 64bit pref]
[    1.085003] pci 0000:00:1c.3: BAR 15: assigned [mem
0x80200000-0x803fffff 64bit pref]
[    1.085009] pci 0000:00:1f.2: BAR 5: assigned [mem 0x80400000-0x804003ff]
[    1.085021] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    1.085026] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    1.085033] pci 0000:00:1c.0:   bridge window [mem 0xfd000000-0xfe9fffff]
[    1.085038] pci 0000:00:1c.0:   bridge window [mem
0xce000000-0xdfffffff 64bit pref]
[    1.085047] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    1.085052] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
[    1.085058] pci 0000:00:1c.1:   bridge window [mem 0xfea00000-0xfeafffff]
[    1.085064] pci 0000:00:1c.1:   bridge window [mem
0x80000000-0x801fffff 64bit pref]
[    1.085071] pci 0000:00:1c.3: PCI bridge to [bus 03]
[    1.085075] pci 0000:00:1c.3:   bridge window [io  0xe000-0xefff]
[    1.085082] pci 0000:00:1c.3:   bridge window [mem 0xfeb00000-0xfebfffff]
[    1.085087] pci 0000:00:1c.3:   bridge window [mem
0x80200000-0x803fffff 64bit pref]
[    1.085096] pci 0000:00:1e.0: PCI bridge to [bus 04]
[    1.085110] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.085114] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    1.085118] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.085122] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff window]
[    1.085126] pci_bus 0000:00: resource 8 [mem 0x80000000-0xdfffffff window]
[    1.085130] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfed8ffff window]
[    1.085134] pci_bus 0000:01: resource 0 [io  0xc000-0xcfff]
[    1.085138] pci_bus 0000:01: resource 1 [mem 0xfd000000-0xfe9fffff]
[    1.085142] pci_bus 0000:01: resource 2 [mem 0xce000000-0xdfffffff
64bit pref]
[    1.085146] pci_bus 0000:02: resource 0 [io  0xd000-0xdfff]
[    1.085150] pci_bus 0000:02: resource 1 [mem 0xfea00000-0xfeafffff]
[    1.085154] pci_bus 0000:02: resource 2 [mem 0x80000000-0x801fffff
64bit pref]
[    1.085158] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    1.085162] pci_bus 0000:03: resource 1 [mem 0xfeb00000-0xfebfffff]
[    1.085166] pci_bus 0000:03: resource 2 [mem 0x80200000-0x803fffff
64bit pref]
[    1.085170] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7 window]
[    1.085174] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff window]
[    1.085178] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.085182] pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000dffff window]
[    1.085186] pci_bus 0000:04: resource 8 [mem 0x80000000-0xdfffffff window]
[    1.085190] pci_bus 0000:04: resource 9 [mem 0xf0000000-0xfed8ffff window]
[    1.085398] NET: Registered protocol family 2
[    1.085824] TCP established hash table entries: 16384 (order: 5,
131072 bytes)
[    1.085951] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
[    1.086083] TCP: Hash tables configured (established 16384 bind 16384)
[    1.086183] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    1.086215] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    1.086381] NET: Registered protocol family 1
[    1.087755] pci 0000:01:00.0: Video device with shadowed ROM at
[mem 0x000c0000-0x000dffff]
[    1.087792] PCI: CLS 32 bytes, default 64
[    1.087949] Unpacking initramfs...
[    1.302264] Freeing initrd memory: 5724K (ffff8800374c2000 -
ffff880037a59000)
[    1.302399] clocksource: tsc: mask: 0xffffffffffffffff max_cycles:
0x19e12014cc1, max_idle_ns: 440795292848 ns
[    1.302543] Scanning for low memory corruption every 60 seconds
[    1.303465] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.304311] Initialise system trusted keyrings
[    1.304581] workingset: timestamp_bits=40 max_order=19 bucket_order=0
[    1.310230] zbud: loaded
[    1.311551] Key type asymmetric registered
[    1.311683] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 249)
[    1.311792] io scheduler noop registered
[    1.311795] io scheduler deadline registered
[    1.311818] io scheduler cfq registered (default)
[    1.313022] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.313039] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.313074] vesafb: mode is 640x480x32, linelength=2560, pages=0
[    1.313076] vesafb: scrolling: redraw
[    1.313080] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    1.313108] vesafb: framebuffer at 0xcf000000, mapped to
0xffffc90000600000, using 1216k, total 1216k
[    1.371153] Console: switching to colour frame buffer device 80x30
[    1.428816] fb0: VESA VGA frame buffer device
[    1.428876] intel_idle: MWAIT substates: 0x10
[    1.428879] intel_idle: v0.4.1 model 0x1C
[    1.429076] intel_idle: lapic_timer_reliable_states 0x2
[    1.429459] GHES: HEST is not enabled!
[    1.429688] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.430970] Linux agpgart interface v0.103
[    1.431895] rtc_cmos 00:01: RTC can wake from S4
[    1.432152] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.432193] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes
nvram, hpet irqs
[    1.432329] ledtrig-cpu: registered to indicate activity on CPUs
[    1.433013] NET: Registered protocol family 10
[    1.433701] NET: Registered protocol family 17
[    1.434306] microcode: sig=0x106ca, pf=0x8, revision=0x107
[    1.434484] microcode: Microcode Update Driver: v2.01
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.434912] registered taskstats version 1
[    1.434935] Loading compiled-in X.509 certificates
[    1.434983] zswap: loaded using pool lzo/zbud
[    1.435870]   Magic number: 5:805:141
[    1.435962] acpi device:12: hash matches
[    1.436057] rtc_cmos 00:01: setting system clock to 2017-02-10
19:08:57 UTC (1486753737)
[    1.436158] PM: Hibernation image not present or could not be loaded.
[    1.439940] Freeing unused kernel memory: 1276K (ffffffff81b0d000 -
ffffffff81c4c000)
[    1.439945] Write protecting the kernel read-only data: 10240k
[    1.441897] Freeing unused kernel memory: 1980K (ffff880001611000 -
ffff880001800000)
[    1.442817] Freeing unused kernel memory: 108K (ffff8800019e5000 -
ffff880001a00000)
[    1.469252] random: systemd-tmpfile: uninitialized urandom read (16
bytes read)
[    1.475758] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.475946] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.478858] random: udevadm: uninitialized urandom read (16 bytes read)
[    1.478930] random: udevadm: uninitialized urandom read (16 bytes read)
[    1.493809] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.493869] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.493896] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.494769] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.494866] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.581507] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M]
at 0x60,0x64 irq 1,12
[    1.584238] i8042: Detected active multiplexing controller, rev 1.0
[    1.585086] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.585266] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.585472] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.585648] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.585657] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.603178] sdhci: Secure Digital Host Controller Interface driver
[    1.603181] sdhci: Copyright(c) Pierre Ossman
[    1.604451] sdhci-pci 0000:02:00.0: SDHCI controller found
[197b:2382] (rev 80)
[    1.609223] mmc0: SDHCI controller on PCI [0000:02:00.0] using ADMA
[    1.609334] sdhci-pci 0000:02:00.2: SDHCI controller found
[197b:2381] (rev 80)
[    1.609514] sdhci-pci 0000:02:00.2: Refusing to bind to secondary interface.
[    1.610615] ACPI: bus type USB registered
[    1.610759] usbcore: registered new interface driver usbfs
[    1.610815] usbcore: registered new interface driver hub
[    1.610930] usbcore: registered new device driver usb
[    1.613153] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.614157] ehci-pci: EHCI PCI platform driver
[    1.614518] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    1.614537] ehci-pci 0000:00:1d.7: new USB bus registered, assigned
bus number 1
[    1.614559] ehci-pci 0000:00:1d.7: debug port 1
[    1.618489] ehci-pci 0000:00:1d.7: cache line size of 32 is not supported
[    1.618531] ehci-pci 0000:00:1d.7: irq 23, io mem 0xfcffbc00
[    1.621710] SCSI subsystem initialized
[    1.627795] libata version 3.00 loaded.
[    1.633408] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.634363] hub 1-0:1.0: USB hub found
[    1.634388] hub 1-0:1.0: 8 ports detected
[    1.635090] ata_piix 0000:00:1f.2: version 2.13
[    1.635107] ata_piix 0000:00:1f.2: enabling device (0005 -> 0007)
[    1.635924] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    1.636592] uhci_hcd: USB Universal Host Controller Interface driver
[    1.639251] scsi host0: ata_piix
[    1.639618] scsi host1: ata_piix
[    1.639787] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xff90 irq 14
[    1.639791] ata2: SATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xff98 irq 15
[    1.640225] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.640254] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 2
[    1.640272] uhci_hcd 0000:00:1d.0: detected 2 ports
[    1.640310] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000bc00
[    1.641127] hub 2-0:1.0: USB hub found
[    1.641167] hub 2-0:1.0: 2 ports detected
[    1.641949] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.641989] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned
bus number 3
[    1.642007] uhci_hcd 0000:00:1d.1: detected 2 ports
[    1.642068] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000b880
[    1.642883] hub 3-0:1.0: USB hub found
[    1.642919] hub 3-0:1.0: 2 ports detected
[    1.643768] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.643795] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned
bus number 4
[    1.643815] uhci_hcd 0000:00:1d.2: detected 2 ports
[    1.643851] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000b800
[    1.644692] hub 4-0:1.0: USB hub found
[    1.644726] hub 4-0:1.0: 2 ports detected
[    1.645511] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    1.645541] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned
bus number 5
[    1.645560] uhci_hcd 0000:00:1d.3: detected 2 ports
[    1.645621] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000b480
[    1.646431] hub 5-0:1.0: USB hub found
[    1.646469] hub 5-0:1.0: 2 ports detected
[    1.695304] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
[    1.802604] ata1.00: ATA-8: HGST HTS721010A9E630, JB0OA3B0, max UDMA/133
[    1.802609] ata1.00: 1953525168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    1.803510] ata2.01: NODEV after polling detection
[    1.807358] ata1.00: configured for UDMA/133
[    1.807815] scsi 0:0:0:0: Direct-Access     ATA      HGST
HTS721010A9 A3B0 PQ: 0 ANSI: 5
[    1.823512] ata2.00: ATAPI: HL-DT-STDVDRAM GT32N, 1.00, max UDMA/100
[    1.846849] ata2.00: configured for UDMA/100
[    1.850212] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT32N
  1.00 PQ: 0 ANSI: 5
[    1.871953] sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks:
(1.00 TB/932 GiB)
[    1.871962] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    1.872299] sd 0:0:0:0: [sda] Write Protect is off
[    1.872308] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.872418] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    1.886316] sr 1:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer
dvd-ram cd/rw xa/form2 cdda tray
[    1.886321] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.887031] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.944130]  sda: sda1 sda2 sda3 sda4
[    1.945761] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.150035] usb 5-2: new full-speed USB device number 2 using uhci_hcd
[    2.351049] hidraw: raw HID events driver (C) Jiri Kosina
[    2.359889] usbcore: registered new interface driver usbhid
[    2.359892] usbhid: USB HID core driver
[    2.362730] random: fast init done
[    2.366335] logitech-djreceiver 0003:046D:C52B.0003:
hiddev0,hidraw0: USB HID v1.11 Device [Logitech USB Receiver] on
usb-0000:00:1d.3-2/input2
[    2.733502] EXT4-fs (sda1): mounted filesystem with ordered data
mode. Opts: (null)
[    2.870056] input: Logitech K400 as
/devices/pci0000:00/0000:00:1d.3/usb5/5-2/5-2:1.2/0003:046D:C52B.0003/0003:046D:400E.0004/input/input5
[    2.870205] logitech-hidpp-device 0003:046D:400E.0004:
input,hidraw1: USB HID v1.11 Keyboard [Logitech K400] on
usb-0000:00:1d.3-2:1
[    3.789505] ip_tables: (C) 2000-2006 Netfilter Core Team
[    3.805779] systemd[1]: systemd 232 running in system mode. (+PAM
-AUDIT -SELINUX -IMA -APPARMOR +SMACK -SYSVINIT +UTMP +LIBCRYPTSETUP
+GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
[    3.806261] systemd[1]: Detected architecture x86-64.
[    3.813099] systemd[1]: Set hostname to <stube>.
[    4.276962] random: crng init done
[    4.722249] systemd[1]: Created slice System Slice.
[    4.722971] systemd[1]: Created slice system-systemd\x2dfsck.slice.
[    4.723139] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[    4.723737] systemd[1]: Created slice User and Session Slice.
[    4.765971] systemd[1]: Mounting POSIX Message Queue File System...
[    4.766642] systemd[1]: Set up automount Arbitrary Executable File
Formats File System Automount Point.
[    4.766881] systemd[1]: Reached target Slices.
[    5.022975] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    5.023096] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    5.314742] EXT4-fs (sda1): re-mounted. Opts: data=ordered
[    6.574332] systemd-journald[141]: Received request to flush
runtime journal from PID 1
[    7.583508] input: Sleep Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input6
[    7.583518] ACPI: Sleep Button [SLPB]
[    7.583738] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input7
[    7.583745] ACPI: Power Button [PWRB]
[    7.583945] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input8
[    7.583952] ACPI: Power Button [PWRF]
[    7.608859] wmi: Mapper loaded
[    8.010852] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    8.185412] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    8.235898] ACPI Warning: SystemIO range
0x0000000000000828-0x000000000000082F conflicts with OpRegion
0x0000000000000800-0x000000000000083F (\PMS0) (20160831/utaddress-247)
[    8.235914] ACPI Warning: SystemIO range
0x0000000000000828-0x000000000000082F conflicts with OpRegion
0x0000000000000800-0x000000000000087F (\_SB.PCI0.SBRG.EC0.PMIO)
(20160831/utaddress-247)
[    8.235924] ACPI: If an ACPI driver is available for this device,
you should use it instead of the native driver
[    8.236002] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    8.270253] thermal LNXTHERM:00: registered as thermal_zone0
[    8.270259] ACPI: Thermal Zone [TZ00] (61 C)
[    8.361327] FUJITSU Extended Socket Network Device Driver - version
1.1 - Copyright (c) 2015 FUJITSU LIMITED
[    8.479031] input: PC Speaker as /devices/platform/pcspkr/input/input13
[    8.579305] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    8.579374] jme 0000:02:00.5: can't disable ASPM; OS doesn't have
ASPM control
[    8.580804] jme 0000:02:00.5 eth0: JMC250 Gigabit Ethernet
chiprev:23 pcirev:3 macaddr:80:ee:73:1f:ec:4a
[    9.035897] iTCO_vendor_support: vendor-support=0
[    9.041109] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    9.041213] iTCO_wdt: Found a NM10 TCO device (Version=2, TCOBASE=0x0860)
[    9.041584] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    9.166142] intel_powerclamp: No package C-state available
[    9.210946] intel_powerclamp: No package C-state available
[    9.218659] gpio_ich: GPIO from 462 to 511 on gpio_ich
[    9.308343] asus_wmi: Asus Management GUID not found
[    9.319552] snd_hda_intel 0000:01:00.1: Disabling MSI
[    9.319565] snd_hda_intel 0000:01:00.1: Handle vga_switcheroo audio client
[    9.530612] jme 0000:02:00.5 enp2s0f5: renamed from eth0
[    9.632884] mousedev: PS/2 mouse device common for all mice
[    9.665305] [drm] Initialized
[    9.935590] rtl8192ce: Using firmware rtlwifi/rtl8192cfwU.bin
[   10.220647] checking generic (cf000000 130000) vs hw (d0000000 10000000)
[   10.220652] checking generic (cf000000 130000) vs hw (ce000000 2000000)
[   10.220654] fb: switching to nouveaufb from VESA VGA
[   10.220728] Console: switching to colour dummy device 80x25
[   10.222037] nouveau 0000:01:00.0: NVIDIA GT218 (0a8780b1)
[   10.323932] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   10.324598] rtlwifi: rtlwifi: wireless switch is on
[   10.332311] snd_hda_codec_idt hdaudioC0D0: autoconfig for
92HD81B1X5: line_outs=1 (0xd/0x0/0x0/0x0/0x0) type:speaker
[   10.332318] snd_hda_codec_idt hdaudioC0D0:    speaker_outs=0
(0x0/0x0/0x0/0x0/0x0)
[   10.332322] snd_hda_codec_idt hdaudioC0D0:    hp_outs=1 (0xb/0x0/0x0/0x0/0x0)
[   10.332326] snd_hda_codec_idt hdaudioC0D0:    mono: mono_out=0x0
[   10.332328] snd_hda_codec_idt hdaudioC0D0:    inputs:
[   10.332333] snd_hda_codec_idt hdaudioC0D0:      Internal Mic=0xc
[   10.332337] snd_hda_codec_idt hdaudioC0D0:      Mic=0xa
[   10.372366] nouveau 0000:01:00.0: bios: version 70.18.64.00.0e
[   10.374341] nouveau 0000:01:00.0: fb: 512 MiB DDR3
[   10.428486] [TTM] Zone  kernel: Available graphics memory: 1026328 kiB
[   10.428489] [TTM] Initializing pool allocator
[   10.428503] [TTM] Initializing DMA pool allocator
[   10.428549] nouveau 0000:01:00.0: DRM: VRAM: 512 MiB
[   10.428553] nouveau 0000:01:00.0: DRM: GART: 1048576 MiB
[   10.428561] nouveau 0000:01:00.0: DRM: TMDS table version 2.0
[   10.428565] nouveau 0000:01:00.0: DRM: DCB version 4.0
[   10.428570] nouveau 0000:01:00.0: DRM: DCB outp 01: 02011300 00000000
[   10.428575] nouveau 0000:01:00.0: DRM: DCB outp 02: 02022362 00020010
[   10.428580] nouveau 0000:01:00.0: DRM: DCB conn 01: 00000100
[   10.428583] nouveau 0000:01:00.0: DRM: DCB conn 02: 00001261
[   10.456148] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   10.456152] [drm] Driver supports precise vblank timestamp query.
[   10.484389] rtl8192ce 0000:03:00.0 wlp3s0: renamed from wlan0
[   10.515448] nouveau 0000:01:00.0: DRM: MM: using COPY for buffer copies
[   10.623104] nouveau 0000:01:00.0: DRM: allocated 1920x1080 fb:
0x70000, bo ffff880076137800
[   10.623430] fbcon: nouveaufb (fb0) is primary device
[   10.691367] Console: switching to colour frame buffer device 240x67
[   10.693917] nouveau 0000:01:00.0: fb0: nouveaufb frame buffer device
[   10.720037] [drm] Initialized nouveau 1.3.1 20120801 for
0000:01:00.0 on minor 0
[   11.378440] input: HDA Digital PCBeep as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input17
[   11.379790] input: HDA Intel Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input18
[   11.380186] input: HDA Intel Front Headphone as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input19
[   11.633372] snd_hda_codec_hdmi hdaudioC1D1: HDMI: audio coding type
0 not expected
[   11.684797] EXT4-fs (sda3): mounted filesystem with ordered data
mode. Opts: data=ordered
[   11.738837] input: HDA NVidia HDMI/DP,pcm=3 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input14
[   11.739181] input: HDA NVidia HDMI/DP,pcm=7 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input15
[   11.739522] input: HDA NVidia HDMI/DP,pcm=8 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input16
[   11.739865] input: HDA NVidia HDMI/DP,pcm=9 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input20
[   12.960048] snd_hda_codec_hdmi hdaudioC1D1: HDMI: audio coding type
0 not expected
[   13.227036] IPv6: ADDRCONF(NETDEV_UP): wlp3s0: link is not ready
[   14.674263] wlp3s0: authenticate with 08:96:d7:7a:7f:0e
[   14.693808] wlp3s0: send auth to 08:96:d7:7a:7f:0e (try 1/3)
[   14.697978] wlp3s0: authenticated
[   14.700066] wlp3s0: associate with 08:96:d7:7a:7f:0e (try 1/3)
[   14.708938] wlp3s0: RX AssocResp from 08:96:d7:7a:7f:0e
(capab=0x431 status=0 aid=3)
[   14.709202] wlp3s0: associated
[   14.709220] IPv6: ADDRCONF(NETDEV_CHANGE): wlp3s0: link becomes ready


[    0.000000] Linux version 4.9.6-1-ARCH (builduser@tobias) (gcc
version 6.3.1 20170109 (GCC) ) #1 SMP PREEMPT Thu Jan 26 09:22:26 CET
2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-linux
root=UUID=399040bd-474e-4c19-84b5-ae6235771846 rw quiet
[    0.000000] x86/fpu: Legacy x87 FPU detected.
[    0.000000] x86/fpu: Using 'eager' FPU context switches.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffaffff] usable
[    0.000000] BIOS-e820: [mem 0x000000007ffb0000-0x000000007ffbdfff] ACPI data
[    0.000000] BIOS-e820: [mem 0x000000007ffbe000-0x000000007ffeffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007fff0000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffb00000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.6 present.
[    0.000000] DMI: Standard XS35/B10IE01, BIOS 080015  06/23/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x7ffb0 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-D3FFF write-protect
[    0.000000]   D4000-DFFFF uncachable
[    0.000000]   E0000-EFFFF write-through
[    0.000000]   F0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f]
mapped at [ffff8800000ff780]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] BRK [0x01d57000, 0x01d57fff] PGTABLE
[    0.000000] BRK [0x01d58000, 0x01d58fff] PGTABLE
[    0.000000] BRK [0x01d59000, 0x01d59fff] PGTABLE
[    0.000000] BRK [0x01d5a000, 0x01d5afff] PGTABLE
[    0.000000] BRK [0x01d5b000, 0x01d5bfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x374c2000-0x37a58fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F9ED0 000024 (v02 ACPIAM)
[    0.000000] ACPI: XSDT 0x000000007FFB0100 000054 (v01 Shuttl
Shuttle  20110623 MSFT 00000097)
[    0.000000] ACPI: FACP 0x000000007FFB0290 0000F4 (v04 062311
FACP1651 20110623 MSFT 00000097)
[    0.000000] ACPI: DSDT 0x000000007FFB05C0 006645 (v02 XS35V
XS35V10  00000200 INTL 20051117)
[    0.000000] ACPI: FACS 0x000000007FFBE000 000040
[    0.000000] ACPI: FACS 0x000000007FFBE000 000040
[    0.000000] ACPI: APIC 0x000000007FFB0390 00006C (v02 062311
APIC1651 20110623 MSFT 00000097)
[    0.000000] ACPI: MCFG 0x000000007FFB0400 00003C (v01 062311
OEMMCFG  20110623 MSFT 00000097)
[    0.000000] ACPI: SLIC 0x000000007FFB0440 000176 (v01 Shuttl
Shuttle  20110623 MSFT 00000097)
[    0.000000] ACPI: OEMB 0x000000007FFBE040 000072 (v01 062311
OEMB1651 20110623 MSFT 00000097)
[    0.000000] ACPI: HPET 0x000000007FFBA5C0 000038 (v01 062311
OEMHPET  20110623 MSFT 00000097)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000007ffaffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x7ffab000-0x7ffaffff]
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007ffaffff]
[    0.000000]   Normal   empty
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000007ffaffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007ffaffff]
[    0.000000] On node 0 totalpages: 524110
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 8127 pages used for memmap
[    0.000000]   DMA32 zone: 520112 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] e820: [mem 0x80000000-0xfedfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff
max_cycles: 0xffffffff, max_idle_ns: 6370452778343963 ns
[    0.000000] setup_percpu: NR_CPUS:128 nr_cpumask_bits:128
nr_cpu_ids:4 nr_node_ids:1
[    0.000000] percpu: Embedded 35 pages/cpu @ffff88007fc00000 s103512
r8192 d31656 u524288
[    0.000000] pcpu-alloc: s103512 r8192 d31656 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.
Total pages: 515898
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-linux
root=UUID=399040bd-474e-4c19-84b5-ae6235771846 rw quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 2043540K/2096440K available (6205K kernel code,
1071K rwdata, 1940K rodata, 1280K init, 1032K bss, 52900K reserved, 0K
cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] Build-time adjustment of leaf fanout to 64.
[    0.000000] RCU restricting CPUs from NR_CPUS=128 to nr_cpu_ids=4.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=64, nr_cpu_ids=4
[    0.000000] NR_IRQS:8448 nr_irqs:456 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 1795.514 MHz processor
[    0.003352] Calibrating delay loop (skipped), value calculated
using timer frequency.. 3592.65 BogoMIPS (lpj=5985046)
[    0.003359] pid_max: default: 32768 minimum: 301
[    0.003398] ACPI: Core revision 20160831
[    0.020066] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.020163] Security Framework initialized
[    0.020166] Yama: becoming mindful.
[    0.020520] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.022230] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.023039] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.023050] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.023754] CPU: Physical Processor ID: 0
[    0.023758] CPU: Processor Core ID: 0
[    0.023761] mce: CPU supports 5 MCE banks
[    0.023772] CPU0: Thermal monitoring enabled (TM1)
[    0.023780] process: using mwait in idle threads
[    0.023787] Last level iTLB entries: 4KB 32, 2MB 0, 4MB 0
[    0.023790] Last level dTLB entries: 4KB 64, 2MB 0, 4MB 8, 1GB 0
[    0.024323] Freeing SMP alternatives memory: 24K (ffffffff81c4d000
- ffffffff81c53000)
[    0.026684] ftrace: allocating 24613 entries in 97 pages
[    0.043561] smpboot: Max logical packages: 2
[    0.043996] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.079999] smpboot: CPU0: Intel(R) Atom(TM) CPU D525   @ 1.80GHz
(family: 0x6, model: 0x1c, stepping: 0xa)
[    0.079999] Performance Events: PEBS fmt0+, Atom events, 8-deep
LBR, Intel PMU driver.
[    0.079999] ... version:                3
[    0.079999] ... bit width:              40
[    0.079999] ... generic registers:      2
[    0.079999] ... value mask:             000000ffffffffff
[    0.079999] ... max period:             000000007fffffff
[    0.079999] ... fixed-purpose events:   3
[    0.079999] ... event mask:             0000000700000003
[    0.110239] NMI watchdog: enabled on all CPUs, permanently consumes
one hw-PMU counter.
[    0.143383] x86: Booting SMP configuration:
[    0.143387] .... node  #0, CPUs:      #1
[    0.006666] Disabled fast string operations
[    0.253377]  #2
[    0.006666] Disabled fast string operations
[    0.363384]  #3
[    0.006666] Disabled fast string operations
[    0.448712] x86: Booted up 1 node, 4 CPUs
[    0.448712] smpboot: Total of 4 processors activated (14369.18 BogoMIPS)
[    0.450641] devtmpfs: initialized
[    0.450641] x86/mm: Memory block size: 128MB
[    0.459458] PM: Registering ACPI NVS region [mem
0x7ffbe000-0x7ffeffff] (204800 bytes)
[    0.459458] clocksource: jiffies: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 6370867519511994 ns
[    0.459458] pinctrl core: initialized pinctrl subsystem
[    0.459458] RTC time: 13:42:16, date: 02/11/17
[    0.460241] NET: Registered protocol family 16
[    0.470017] cpuidle: using governor ladder
[    0.483349] cpuidle: using governor menu
[    0.483412] ACPI: bus type PCI registered
[    0.483416] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.483595] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.483599] PCI: not using MMCONFIG
[    0.483602] PCI: Using configuration type 1 for base access
[    0.483758] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.483760] mtrr: probably your BIOS does not setup all CPUs.
[    0.483761] mtrr: corrected configuration.
[    0.496769] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    0.496882] ACPI: Added _OSI(Module Device)
[    0.496886] ACPI: Added _OSI(Processor Device)
[    0.496888] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.496890] ACPI: Added _OSI(Processor Aggregator Device)
[    0.497211] ACPI: Executed 1 blocks of module-level executable AML code
[    0.503017] ACPI Error: No handler for Region [ECRM]
(ffff88007d09bee8) [EmbeddedControl] (20160831/evregion-166)
[    0.503041] ACPI Error: Region EmbeddedControl (ID=3) has no
handler (20160831/exfldio-299)
[    0.503059] ACPI Error: Method parse/execution failed
[\_SB.PCI0.SBRG.EC0._REG] (Node ffff88007d09da00), AE_NOT_EXIST
(20160831/psparse-543)
[    0.504864] ACPI : EC: EC started
[    0.983441] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as first EC
[    0.983446] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x1d,
EC_CMD/EC_SC=0x66, EC_DATA=0x62
[    0.983450] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to
handle transactions
[    0.983451] ACPI: Interpreter enabled
[    0.983498] ACPI: (supports S0 S3 S4 S5)
[    0.983501] ACPI: Using IOAPIC for interrupt routing
[    0.983589] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem
0xe0000000-0xefffffff] (base 0xe0000000)
[    0.985979] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved
in ACPI motherboard resources
[    0.986021] PCI: Using host bridge windows from ACPI; if necessary,
use "pci=nocrs" and report a bug
[    0.999228] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.999242] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM
ClockPM Segments MSI]
[    0.999254] acpi PNP0A08:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.999877] PCI host bridge to bus 0000:00
[    0.999884] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.999888] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.999892] pci_bus 0000:00: root bus resource [mem
0x000a0000-0x000bffff window]
[    0.999896] pci_bus 0000:00: root bus resource [mem
0x000d0000-0x000dffff window]
[    0.999900] pci_bus 0000:00: root bus resource [mem
0x80000000-0xdfffffff window]
[    0.999904] pci_bus 0000:00: root bus resource [mem
0xf0000000-0xfed8ffff window]
[    0.999909] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.999925] pci 0000:00:00.0: [8086:a000] type 00 class 0x060000
[    1.000199] pci 0000:00:1b.0: [8086:27d8] type 00 class 0x040300
[    1.000222] pci 0000:00:1b.0: reg 0x10: [mem 0xfcffc000-0xfcffffff 64bit]
[    1.000307] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    1.000430] pci 0000:00:1b.0: System wakeup disabled by ACPI
[    1.000542] pci 0000:00:1c.0: [8086:27d0] type 01 class 0x060400
[    1.000628] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    1.000742] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    1.000863] pci 0000:00:1c.1: [8086:27d2] type 01 class 0x060400
[    1.000949] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    1.001064] pci 0000:00:1c.1: System wakeup disabled by ACPI
[    1.001175] pci 0000:00:1c.3: [8086:27d6] type 01 class 0x060400
[    1.001260] pci 0000:00:1c.3: PME# supported from D0 D3hot D3cold
[    1.001510] pci 0000:00:1c.3: System wakeup disabled by ACPI
[    1.001624] pci 0000:00:1d.0: [8086:27c8] type 00 class 0x0c0300
[    1.001668] pci 0000:00:1d.0: reg 0x20: [io  0xbc00-0xbc1f]
[    1.001847] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    1.001961] pci 0000:00:1d.1: [8086:27c9] type 00 class 0x0c0300
[    1.002004] pci 0000:00:1d.1: reg 0x20: [io  0xb880-0xb89f]
[    1.002182] pci 0000:00:1d.1: System wakeup disabled by ACPI
[    1.002292] pci 0000:00:1d.2: [8086:27ca] type 00 class 0x0c0300
[    1.002335] pci 0000:00:1d.2: reg 0x20: [io  0xb800-0xb81f]
[    1.003464] pci 0000:00:1d.2: System wakeup disabled by ACPI
[    1.003576] pci 0000:00:1d.3: [8086:27cb] type 00 class 0x0c0300
[    1.003619] pci 0000:00:1d.3: reg 0x20: [io  0xb480-0xb49f]
[    1.003801] pci 0000:00:1d.3: System wakeup disabled by ACPI
[    1.003917] pci 0000:00:1d.7: [8086:27cc] type 00 class 0x0c0320
[    1.003938] pci 0000:00:1d.7: reg 0x10: [mem 0xfcffbc00-0xfcffbfff]
[    1.004028] pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
[    1.004137] pci 0000:00:1d.7: System wakeup disabled by ACPI
[    1.004247] pci 0000:00:1e.0: [8086:2448] type 01 class 0x060401
[    1.004403] pci 0000:00:1e.0: System wakeup disabled by ACPI
[    1.004519] pci 0000:00:1f.0: [8086:27bc] type 00 class 0x060100
[    1.004605] pci 0000:00:1f.0: [Firmware Bug]: TigerPoint LPC.BM_STS cleared
[    1.004830] pci 0000:00:1f.2: [8086:27c0] type 00 class 0x01018a
[    1.004847] pci 0000:00:1f.2: reg 0x10: [io  0x0000-0x0007]
[    1.004857] pci 0000:00:1f.2: reg 0x14: [io  0x0000-0x0003]
[    1.004867] pci 0000:00:1f.2: reg 0x18: [io  0x0000-0x0007]
[    1.004876] pci 0000:00:1f.2: reg 0x1c: [io  0x0000-0x0003]
[    1.004886] pci 0000:00:1f.2: reg 0x20: [io  0xff90-0xff9f]
[    1.004897] pci 0000:00:1f.2: reg 0x24: [mem 0x0000fc00-0x0000ffff]
[    1.004909] pci 0000:00:1f.2: legacy IDE quirk: reg 0x10: [io  0x01f0-0x01f7]
[    1.004913] pci 0000:00:1f.2: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.004917] pci 0000:00:1f.2: legacy IDE quirk: reg 0x18: [io  0x0170-0x0177]
[    1.004920] pci 0000:00:1f.2: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.004952] pci 0000:00:1f.2: PME# supported from D3hot
[    1.005166] pci 0000:00:1f.3: [8086:27da] type 00 class 0x0c0500
[    1.005220] pci 0000:00:1f.3: reg 0x20: [io  0x0400-0x041f]
[    1.005532] pci 0000:01:00.0: [10de:0a6f] type 00 class 0x030000
[    1.005555] pci 0000:01:00.0: reg 0x10: [mem 0xfd000000-0xfdffffff]
[    1.005574] pci 0000:01:00.0: reg 0x14: [mem 0xd0000000-0xdfffffff
64bit pref]
[    1.005592] pci 0000:01:00.0: reg 0x1c: [mem 0xce000000-0xcfffffff
64bit pref]
[    1.005605] pci 0000:01:00.0: reg 0x24: [io  0xcc00-0xcc7f]
[    1.005619] pci 0000:01:00.0: reg 0x30: [mem 0xfe980000-0xfe9fffff pref]
[    1.005819] pci 0000:01:00.1: [10de:0be3] type 00 class 0x040300
[    1.005841] pci 0000:01:00.1: reg 0x10: [mem 0xfe97c000-0xfe97ffff]
[    1.013375] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    1.013382] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    1.013388] pci 0000:00:1c.0:   bridge window [mem 0xfd000000-0xfe9fffff]
[    1.013395] pci 0000:00:1c.0:   bridge window [mem
0xce000000-0xdfffffff 64bit pref]
[    1.013551] pci 0000:02:00.0: [197b:2382] type 00 class 0x088000
[    1.013578] pci 0000:02:00.0: reg 0x10: [mem 0xfeaffc00-0xfeaffcff]
[    1.013878] pci 0000:02:00.2: [197b:2381] type 00 class 0x080501
[    1.013905] pci 0000:02:00.2: reg 0x10: [mem 0xfeaff800-0xfeaff8ff]
[    1.014185] pci 0000:02:00.3: [197b:2383] type 00 class 0x088000
[    1.014212] pci 0000:02:00.3: reg 0x10: [mem 0xfeaff400-0xfeaff4ff]
[    1.014492] pci 0000:02:00.5: [197b:0250] type 00 class 0x020000
[    1.014519] pci 0000:02:00.5: reg 0x10: [mem 0xfeaf4000-0xfeaf7fff]
[    1.014547] pci 0000:02:00.5: reg 0x18: [io  0xdc00-0xdc7f]
[    1.014562] pci 0000:02:00.5: reg 0x1c: [io  0xd800-0xd8ff]
[    1.014686] pci 0000:02:00.5: PME# supported from D0 D3hot D3cold
[    1.014757] pci 0000:02:00.5: System wakeup disabled by ACPI
[    1.023368] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    1.023374] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
[    1.023380] pci 0000:00:1c.1:   bridge window [mem 0xfea00000-0xfeafffff]
[    1.023523] pci 0000:03:00.0: [10ec:8176] type 00 class 0x028000
[    1.023550] pci 0000:03:00.0: reg 0x10: [io  0xe800-0xe8ff]
[    1.023584] pci 0000:03:00.0: reg 0x18: [mem 0xfebfc000-0xfebfffff 64bit]
[    1.023711] pci 0000:03:00.0: supports D1 D2
[    1.023715] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    1.033366] pci 0000:00:1c.3: PCI bridge to [bus 03]
[    1.033372] pci 0000:00:1c.3:   bridge window [io  0xe000-0xefff]
[    1.033378] pci 0000:00:1c.3:   bridge window [mem 0xfeb00000-0xfebfffff]
[    1.033503] pci 0000:00:1e.0: PCI bridge to [bus 04] (subtractive decode)
[    1.033516] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7
window] (subtractive decode)
[    1.033520] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff
window] (subtractive decode)
[    1.033524] pci 0000:00:1e.0:   bridge window [mem
0x000a0000-0x000bffff window] (subtractive decode)
[    1.033528] pci 0000:00:1e.0:   bridge window [mem
0x000d0000-0x000dffff window] (subtractive decode)
[    1.033532] pci 0000:00:1e.0:   bridge window [mem
0x80000000-0xdfffffff window] (subtractive decode)
[    1.033536] pci 0000:00:1e.0:   bridge window [mem
0xf0000000-0xfed8ffff window] (subtractive decode)
[    1.035188] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 *10 11 12 14 15)
[    1.035350] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 *11 12 14 15)
[    1.035518] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 *7 10 11 12 14 15)
[    1.035677] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 *5 7 10 11 12 14 15)
[    1.035834] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.035993] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.036152] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 10 11 12
14 15) *0, disabled.
[    1.036311] ACPI: PCI Interrupt Link [LNKH] (IRQs *3 4 5 7 10 11 12 14 15)
[    1.036567] ACPI: Enabled 3 GPEs in block 00 to 1F
[    1.036764] ACPI : EC: event unblocked
[    1.036776] ACPI: \_SB_.PCI0.SBRG.EC0_: GPE=0x1d,
EC_CMD/EC_SC=0x66, EC_DATA=0x62
[    1.036780] ACPI: \_SB_.PCI0.SBRG.EC0_: Used as boot DSDT EC to
handle transactions and events
[    1.037091] vgaarb: setting as boot device: PCI:0000:01:00.0
[    1.037091] vgaarb: device added:
PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    1.037091] vgaarb: loaded
[    1.037091] vgaarb: bridge control possible 0000:01:00.0
[    1.037091] PCI: Using ACPI for IRQ routing
[    1.041208] PCI: pci_cache_line_size set to 64 bytes
[    1.041293] pci 0000:00:1f.2: can't claim BAR 5 [mem
0x0000fc00-0x0000ffff]: no compatible bridge window
[    1.041308] e820: reserve RAM buffer [mem 0x0009f800-0x0009ffff]
[    1.041312] e820: reserve RAM buffer [mem 0x7ffb0000-0x7fffffff]
[    1.041646] NetLabel: Initializing
[    1.041649] NetLabel:  domain hash size = 128
[    1.041650] NetLabel:  protocols = UNLABELED CIPSOv4
[    1.041683] NetLabel:  unlabeled traffic allowed by default
[    1.043409] HPET: 3 timers in total, 0 timers will be used for per-cpu timer
[    1.043416] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    1.043424] hpet0: 3 comparators, 64-bit 14.318180 MHz counter
[    1.046718] clocksource: Switched to clocksource hpet
[    1.068040] VFS: Disk quotas dquot_6.6.0
[    1.068098] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.068344] pnp: PnP ACPI init
[    1.068553] system 00:00: [mem 0xfed14000-0xfed19fff] has been reserved
[    1.068559] system 00:00: [mem 0xfed90000-0xfed93fff] has been reserved
[    1.068569] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.068746] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.068896] pnp 00:02: Plug and Play ACPI device, IDs PNP0303
PNP030b (active)
[    1.069070] pnp 00:03: Plug and Play ACPI device, IDs PNP0f03
PNP0f13 (active)
[    1.069412] system 00:04: [io  0x04d0-0x04d1] has been reserved
[    1.069418] system 00:04: [io  0x0800-0x087f] has been reserved
[    1.069422] system 00:04: [io  0x0480-0x04bf] has been reserved
[    1.069428] system 00:04: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    1.069433] system 00:04: [mem 0xfed20000-0xfed8ffff] has been reserved
[    1.069441] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.069718] system 00:05: [mem 0xffc00000-0xffefffff] has been reserved
[    1.069727] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.070090] system 00:06: [mem 0xfec00000-0xfec00fff] could not be reserved
[    1.070096] system 00:06: [mem 0xfee00000-0xfee00fff] has been reserved
[    1.070105] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.070294] system 00:07: [mem 0xe0000000-0xefffffff] has been reserved
[    1.070303] system 00:07: Plug and Play ACPI device, IDs PNP0c02 (active)
[    1.070781] system 00:08: [mem 0x00000000-0x0009ffff] could not be reserved
[    1.070788] system 00:08: [mem 0x000c0000-0x000cffff] could not be reserved
[    1.070792] system 00:08: [mem 0x000e0000-0x000fffff] could not be reserved
[    1.070797] system 00:08: [mem 0x00100000-0x7fffffff] could not be reserved
[    1.070802] system 00:08: [mem 0xfed90000-0xffffffff] could not be reserved
[    1.070810] system 00:08: Plug and Play ACPI device, IDs PNP0c01 (active)
[    1.071159] pnp: PnP ACPI: found 9 devices
[    1.082436] clocksource: acpi_pm: mask: 0xffffff max_cycles:
0xffffff, max_idle_ns: 2085701024 ns
[    1.082488] pci 0000:00:1c.1: bridge window [mem
0x00100000-0x000fffff 64bit pref] to [bus 02] add_size 200000
add_align 100000
[    1.082501] pci 0000:00:1c.3: bridge window [mem
0x00100000-0x000fffff 64bit pref] to [bus 03] add_size 200000
add_align 100000
[    1.082523] pci 0000:00:1c.1: res[15]=[mem 0x00100000-0x000fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.082528] pci 0000:00:1c.1: res[15]=[mem 0x00100000-0x002fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.082533] pci 0000:00:1c.3: res[15]=[mem 0x00100000-0x000fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.082537] pci 0000:00:1c.3: res[15]=[mem 0x00100000-0x002fffff
64bit pref] res_to_dev_res add_size 200000 min_align 100000
[    1.082554] pci 0000:00:1c.1: BAR 15: assigned [mem
0x80000000-0x801fffff 64bit pref]
[    1.082564] pci 0000:00:1c.3: BAR 15: assigned [mem
0x80200000-0x803fffff 64bit pref]
[    1.082570] pci 0000:00:1f.2: BAR 5: assigned [mem 0x80400000-0x804003ff]
[    1.082581] pci 0000:00:1c.0: PCI bridge to [bus 01]
[    1.082586] pci 0000:00:1c.0:   bridge window [io  0xc000-0xcfff]
[    1.082593] pci 0000:00:1c.0:   bridge window [mem 0xfd000000-0xfe9fffff]
[    1.082599] pci 0000:00:1c.0:   bridge window [mem
0xce000000-0xdfffffff 64bit pref]
[    1.082608] pci 0000:00:1c.1: PCI bridge to [bus 02]
[    1.082613] pci 0000:00:1c.1:   bridge window [io  0xd000-0xdfff]
[    1.082619] pci 0000:00:1c.1:   bridge window [mem 0xfea00000-0xfeafffff]
[    1.082625] pci 0000:00:1c.1:   bridge window [mem
0x80000000-0x801fffff 64bit pref]
[    1.082632] pci 0000:00:1c.3: PCI bridge to [bus 03]
[    1.082637] pci 0000:00:1c.3:   bridge window [io  0xe000-0xefff]
[    1.082643] pci 0000:00:1c.3:   bridge window [mem 0xfeb00000-0xfebfffff]
[    1.082649] pci 0000:00:1c.3:   bridge window [mem
0x80200000-0x803fffff 64bit pref]
[    1.082657] pci 0000:00:1e.0: PCI bridge to [bus 04]
[    1.082671] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.082675] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    1.082679] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.082683] pci_bus 0000:00: resource 7 [mem 0x000d0000-0x000dffff window]
[    1.082687] pci_bus 0000:00: resource 8 [mem 0x80000000-0xdfffffff window]
[    1.082691] pci_bus 0000:00: resource 9 [mem 0xf0000000-0xfed8ffff window]
[    1.082695] pci_bus 0000:01: resource 0 [io  0xc000-0xcfff]
[    1.082699] pci_bus 0000:01: resource 1 [mem 0xfd000000-0xfe9fffff]
[    1.082703] pci_bus 0000:01: resource 2 [mem 0xce000000-0xdfffffff
64bit pref]
[    1.082707] pci_bus 0000:02: resource 0 [io  0xd000-0xdfff]
[    1.082711] pci_bus 0000:02: resource 1 [mem 0xfea00000-0xfeafffff]
[    1.082715] pci_bus 0000:02: resource 2 [mem 0x80000000-0x801fffff
64bit pref]
[    1.082719] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    1.082723] pci_bus 0000:03: resource 1 [mem 0xfeb00000-0xfebfffff]
[    1.082727] pci_bus 0000:03: resource 2 [mem 0x80200000-0x803fffff
64bit pref]
[    1.082731] pci_bus 0000:04: resource 4 [io  0x0000-0x0cf7 window]
[    1.082735] pci_bus 0000:04: resource 5 [io  0x0d00-0xffff window]
[    1.082739] pci_bus 0000:04: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.082743] pci_bus 0000:04: resource 7 [mem 0x000d0000-0x000dffff window]
[    1.082747] pci_bus 0000:04: resource 8 [mem 0x80000000-0xdfffffff window]
[    1.082751] pci_bus 0000:04: resource 9 [mem 0xf0000000-0xfed8ffff window]
[    1.082956] NET: Registered protocol family 2
[    1.083393] TCP established hash table entries: 16384 (order: 5,
131072 bytes)
[    1.083517] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
[    1.083648] TCP: Hash tables configured (established 16384 bind 16384)
[    1.083748] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    1.083781] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    1.083939] NET: Registered protocol family 1
[    1.085289] pci 0000:01:00.0: Video device with shadowed ROM at
[mem 0x000c0000-0x000dffff]
[    1.085328] PCI: CLS 32 bytes, default 64
[    1.085481] Unpacking initramfs...
[    1.301116] Freeing initrd memory: 5724K (ffff8800374c2000 -
ffff880037a59000)
[    1.301375] Scanning for low memory corruption every 60 seconds
[    1.302263] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    1.303104] Initialise system trusted keyrings
[    1.303414] workingset: timestamp_bits=40 max_order=19 bucket_order=0
[    1.308826] zbud: loaded
[    1.310211] Key type asymmetric registered
[    1.310336] Block layer SCSI generic (bsg) driver version 0.4
loaded (major 249)
[    1.310437] io scheduler noop registered
[    1.310440] io scheduler deadline registered
[    1.310463] io scheduler cfq registered (default)
[    1.311684] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.311707] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.311743] vesafb: mode is 640x480x32, linelength=2560, pages=0
[    1.311744] vesafb: scrolling: redraw
[    1.311748] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    1.311775] vesafb: framebuffer at 0xcf000000, mapped to
0xffffc90000600000, using 1216k, total 1216k
[    1.369776] Console: switching to colour frame buffer device 80x30
[    1.427452] fb0: VESA VGA frame buffer device
[    1.427504] intel_idle: MWAIT substates: 0x10
[    1.427507] intel_idle: v0.4.1 model 0x1C
[    1.427700] intel_idle: lapic_timer_reliable_states 0x2
[    1.428076] GHES: HEST is not enabled!
[    1.428344] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.429603] Linux agpgart interface v0.103
[    1.430540] rtc_cmos 00:01: RTC can wake from S4
[    1.430802] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.430842] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes
nvram, hpet irqs
[    1.430978] ledtrig-cpu: registered to indicate activity on CPUs
[    1.431656] NET: Registered protocol family 10
[    1.432312] NET: Registered protocol family 17
[    1.432914] microcode: sig=0x106ca, pf=0x8, revision=0x107
[    1.433071] microcode: Microcode Update Driver: v2.01
<tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.433519] registered taskstats version 1
[    1.433540] Loading compiled-in X.509 certificates
[    1.433607] zswap: loaded using pool lzo/zbud
[    1.434469]   Magic number: 5:862:735
[    1.434652] rtc_cmos 00:01: setting system clock to 2017-02-11
13:42:17 UTC (1486820537)
[    1.434756] PM: Hibernation image not present or could not be loaded.
[    1.438535] Freeing unused kernel memory: 1280K (ffffffff81b0d000 -
ffffffff81c4d000)
[    1.438540] Write protecting the kernel read-only data: 10240k
[    1.440500] Freeing unused kernel memory: 1972K (ffff880001613000 -
ffff880001800000)
[    1.441425] Freeing unused kernel memory: 108K (ffff8800019e5000 -
ffff880001a00000)
[    1.467935] random: systemd-tmpfile: uninitialized urandom read (16
bytes read)
[    1.474416] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.474612] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.478163] random: udevadm: uninitialized urandom read (16 bytes read)
[    1.478259] random: udevadm: uninitialized urandom read (16 bytes read)
[    1.493269] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.493382] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.493418] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.494489] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.494587] random: systemd-udevd: uninitialized urandom read (16 bytes read)
[    1.581498] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M]
at 0x60,0x64 irq 1,12
[    1.584360] i8042: Detected active multiplexing controller, rev 1.0
[    1.585186] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.585418] serio: i8042 AUX0 port at 0x60,0x64 irq 12
[    1.585600] serio: i8042 AUX1 port at 0x60,0x64 irq 12
[    1.585787] serio: i8042 AUX2 port at 0x60,0x64 irq 12
[    1.586021] serio: i8042 AUX3 port at 0x60,0x64 irq 12
[    1.607369] sdhci: Secure Digital Host Controller Interface driver
[    1.607372] sdhci: Copyright(c) Pierre Ossman
[    1.608445] sdhci-pci 0000:02:00.0: SDHCI controller found
[197b:2382] (rev 80)
[    1.610906] mmc0: SDHCI controller on PCI [0000:02:00.0] using ADMA
[    1.611073] sdhci-pci 0000:02:00.2: SDHCI controller found
[197b:2381] (rev 80)
[    1.611402] sdhci-pci 0000:02:00.2: Refusing to bind to secondary interface.
[    1.617929] ACPI: bus type USB registered
[    1.618047] usbcore: registered new interface driver usbfs
[    1.618116] usbcore: registered new interface driver hub
[    1.618252] usbcore: registered new device driver usb
[    1.620506] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.621355] ehci-pci: EHCI PCI platform driver
[    1.621778] ehci-pci 0000:00:1d.7: EHCI Host Controller
[    1.621808] ehci-pci 0000:00:1d.7: new USB bus registered, assigned
bus number 1
[    1.621835] ehci-pci 0000:00:1d.7: debug port 1
[    1.625770] ehci-pci 0000:00:1d.7: cache line size of 32 is not supported
[    1.625822] ehci-pci 0000:00:1d.7: irq 23, io mem 0xfcffbc00
[    1.627408] SCSI subsystem initialized
[    1.632658] libata version 3.00 loaded.
[    1.636768] ehci-pci 0000:00:1d.7: USB 2.0 started, EHCI 1.00
[    1.637496] hub 1-0:1.0: USB hub found
[    1.637542] hub 1-0:1.0: 8 ports detected
[    1.638309] ata_piix 0000:00:1f.2: version 2.13
[    1.638326] ata_piix 0000:00:1f.2: enabling device (0005 -> 0007)
[    1.639581] uhci_hcd: USB Universal Host Controller Interface driver
[    1.639595] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    1.642662] scsi host0: ata_piix
[    1.643029] scsi host1: ata_piix
[    1.643193] ata1: SATA max UDMA/133 cmd 0x1f0 ctl 0x3f6 bmdma 0xff90 irq 14
[    1.643197] ata2: SATA max UDMA/133 cmd 0x170 ctl 0x376 bmdma 0xff98 irq 15
[    1.643639] uhci_hcd 0000:00:1d.0: UHCI Host Controller
[    1.643671] uhci_hcd 0000:00:1d.0: new USB bus registered, assigned
bus number 2
[    1.643691] uhci_hcd 0000:00:1d.0: detected 2 ports
[    1.643731] uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000bc00
[    1.644537] hub 2-0:1.0: USB hub found
[    1.644574] hub 2-0:1.0: 2 ports detected
[    1.645351] uhci_hcd 0000:00:1d.1: UHCI Host Controller
[    1.645380] uhci_hcd 0000:00:1d.1: new USB bus registered, assigned
bus number 3
[    1.645399] uhci_hcd 0000:00:1d.1: detected 2 ports
[    1.645461] uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000b880
[    1.646291] hub 3-0:1.0: USB hub found
[    1.646331] hub 3-0:1.0: 2 ports detected
[    1.647087] uhci_hcd 0000:00:1d.2: UHCI Host Controller
[    1.647110] uhci_hcd 0000:00:1d.2: new USB bus registered, assigned
bus number 4
[    1.647127] uhci_hcd 0000:00:1d.2: detected 2 ports
[    1.647164] uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000b800
[    1.647992] hub 4-0:1.0: USB hub found
[    1.648032] hub 4-0:1.0: 2 ports detected
[    1.648822] uhci_hcd 0000:00:1d.3: UHCI Host Controller
[    1.648850] uhci_hcd 0000:00:1d.3: new USB bus registered, assigned
bus number 5
[    1.648870] uhci_hcd 0000:00:1d.3: detected 2 ports
[    1.648935] uhci_hcd 0000:00:1d.3: irq 16, io base 0x0000b480
[    1.649763] hub 5-0:1.0: USB hub found
[    1.649802] hub 5-0:1.0: 2 ports detected
[    1.685985] input: AT Translated Set 2 keyboard as
/devices/platform/i8042/serio0/input/input0
[    1.800340] ata2.01: NODEV after polling detection
[    1.802685] ata1.00: ATA-8: HGST HTS721010A9E630, JB0OA3B0, max UDMA/133
[    1.802690] ata1.00: 1953525168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    1.807430] ata1.00: configured for UDMA/133
[    1.807892] scsi 0:0:0:0: Direct-Access     ATA      HGST
HTS721010A9 A3B0 PQ: 0 ANSI: 5
[    1.820173] ata2.00: ATAPI: HL-DT-STDVDRAM GT32N, 1.00, max UDMA/100
[    1.824714] ata2.00: configured for UDMA/100
[    1.866059] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT32N
  1.00 PQ: 0 ANSI: 5
[    1.885104] sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks:
(1.00 TB/932 GiB)
[    1.885113] sd 0:0:0:0: [sda] 4096-byte physical blocks
[    1.885402] sd 0:0:0:0: [sda] Write Protect is off
[    1.885411] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.885530] sd 0:0:0:0: [sda] Write cache: enabled, read cache:
enabled, doesn't support DPO or FUA
[    1.907146] sr 1:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer
dvd-ram cd/rw xa/form2 cdda tray
[    1.907151] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.907708] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.954957]  sda: sda1 sda2 sda3 sda4
[    1.956186] sd 0:0:0:0: [sda] Attached SCSI disk
[    2.153396] usb 5-2: new full-speed USB device number 2 using uhci_hcd
[    2.320046] tsc: Refined TSC clocksource calibration: 1795.499 MHz
[    2.320061] clocksource: tsc: mask: 0xffffffffffffffff max_cycles:
0x19e18da41a2, max_idle_ns: 440795250832 ns
[    2.354439] hidraw: raw HID events driver (C) Jiri Kosina
[    2.363227] usbcore: registered new interface driver usbhid
[    2.363230] usbhid: USB HID core driver
[    2.364064] random: fast init done
[    2.371419] logitech-djreceiver 0003:046D:C52B.0003:
hiddev0,hidraw0: USB HID v1.11 Device [Logitech USB Receiver] on
usb-0000:00:1d.3-2/input2
[    2.719332] EXT4-fs (sda1): mounted filesystem with ordered data
mode. Opts: (null)
[    2.755373] input: Logitech K400 as
/devices/pci0000:00/0000:00:1d.3/usb5/5-2/5-2:1.2/0003:046D:C52B.0003/0003:046D:400E.0004/input/input5
[    2.755508] logitech-hidpp-device 0003:046D:400E.0004:
input,hidraw1: USB HID v1.11 Keyboard [Logitech K400] on
usb-0000:00:1d.3-2:1
[    3.333558] clocksource: Switched to clocksource tsc
[    3.652932] ip_tables: (C) 2000-2006 Netfilter Core Team
[    3.666611] systemd[1]: systemd 232 running in system mode. (+PAM
-AUDIT -SELINUX -IMA -APPARMOR +SMACK -SYSVINIT +UTMP +LIBCRYPTSETUP
+GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
[    3.667117] systemd[1]: Detected architecture x86-64.
[    3.673923] systemd[1]: Set hostname to <stube>.
[    4.383658] random: crng init done
[    4.531697] systemd[1]: Listening on Journal Socket (/dev/log).
[    4.531872] systemd[1]: Reached target Remote File Systems.
[    4.533229] systemd[1]: Created slice System Slice.
[    4.533873] systemd[1]: Created slice User and Session Slice.
[    4.534030] systemd[1]: Listening on Device-mapper event daemon FIFOs.
[    4.536850] systemd[1]: Listening on Process Core Dump Socket.
[    4.537043] systemd[1]: Listening on udev Control Socket.
[    4.707588] EXT4-fs (sda1): re-mounted. Opts: data=ordered
[    4.973933] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    4.974065] sr 1:0:0:0: Attached scsi generic sg1 type 5
[    7.470645] systemd-journald[153]: Received request to flush
runtime journal from PID 1
[    7.685018] input: Sleep Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input6
[    7.685028] ACPI: Sleep Button [SLPB]
[    7.685198] input: Power Button as
/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input7
[    7.685203] ACPI: Power Button [PWRB]
[    7.685358] input: Power Button as
/devices/LNXSYSTM:00/LNXPWRBN:00/input/input8
[    7.685363] ACPI: Power Button [PWRF]
[    7.753394] wmi: Mapper loaded
[    8.355540] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    8.370249] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    8.378647] ACPI Warning: SystemIO range
0x0000000000000828-0x000000000000082F conflicts with OpRegion
0x0000000000000800-0x000000000000083F (\PMS0) (20160831/utaddress-247)
[    8.378668] ACPI Warning: SystemIO range
0x0000000000000828-0x000000000000082F conflicts with OpRegion
0x0000000000000800-0x000000000000087F (\_SB.PCI0.SBRG.EC0.PMIO)
(20160831/utaddress-247)
[    8.378682] ACPI: If an ACPI driver is available for this device,
you should use it instead of the native driver
[    8.378801] lpc_ich: Resource conflict(s) found affecting gpio_ich
[    8.410080] FUJITSU Extended Socket Network Device Driver - version
1.1 - Copyright (c) 2015 FUJITSU LIMITED
[    8.460276] thermal LNXTHERM:00: registered as thermal_zone0
[    8.460282] ACPI: Thermal Zone [TZ00] (64 C)
[    8.610606] input: PC Speaker as /devices/platform/pcspkr/input/input9
[    8.948744] snd_hda_intel 0000:01:00.1: Disabling MSI
[    8.948757] snd_hda_intel 0000:01:00.1: Handle vga_switcheroo audio client
[    9.174637] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    9.174718] jme 0000:02:00.5: can't disable ASPM; OS doesn't have
ASPM control
[    9.176270] jme 0000:02:00.5 eth0: JMC250 Gigabit Ethernet
chiprev:23 pcirev:3 macaddr:80:ee:73:1f:ec:4a
[    9.202546] intel_powerclamp: No package C-state available
[    9.206721] iTCO_vendor_support: vendor-support=0
[    9.208801] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    9.208931] iTCO_wdt: Found a NM10 TCO device (Version=2, TCOBASE=0x0860)
[    9.210454] iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
[    9.322629] snd_hda_codec_idt hdaudioC0D0: autoconfig for
92HD81B1X5: line_outs=1 (0xd/0x0/0x0/0x0/0x0) type:speaker
[    9.322636] snd_hda_codec_idt hdaudioC0D0:    speaker_outs=0
(0x0/0x0/0x0/0x0/0x0)
[    9.322640] snd_hda_codec_idt hdaudioC0D0:    hp_outs=1 (0xb/0x0/0x0/0x0/0x0)
[    9.322644] snd_hda_codec_idt hdaudioC0D0:    mono: mono_out=0x0
[    9.322646] snd_hda_codec_idt hdaudioC0D0:    inputs:
[    9.322651] snd_hda_codec_idt hdaudioC0D0:      Internal Mic=0xc
[    9.322654] snd_hda_codec_idt hdaudioC0D0:      Mic=0xa
[    9.361697] input: HDA Digital PCBeep as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input14
[    9.362939] input: HDA Intel Mic as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input15
[    9.363249] input: HDA Intel Front Headphone as
/devices/pci0000:00/0000:00:1b.0/sound/card0/input16
[    9.436577] gpio_ich: GPIO from 462 to 511 on gpio_ich
[    9.499684] jme 0000:02:00.5 enp2s0f5: renamed from eth0
[    9.662371] asus_wmi: Asus Management GUID not found
[    9.684667] rtl8192ce: Using firmware rtlwifi/rtl8192cfwU.bin
[    9.732261] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[    9.732920] rtlwifi: rtlwifi: wireless switch is on
[   10.025730] mousedev: PS/2 mouse device common for all mice
[   10.184505] rtl8192ce 0000:03:00.0 wlp3s0: renamed from wlan0
[   10.565634] [drm] Initialized
[   10.661629] input: HDA NVidia HDMI/DP,pcm=3 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input17
[   10.661862] input: HDA NVidia HDMI/DP,pcm=7 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input18
[   10.662080] input: HDA NVidia HDMI/DP,pcm=8 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input19
[   10.662299] input: HDA NVidia HDMI/DP,pcm=9 as
/devices/pci0000:00/0000:00:1c.0/0000:01:00.1/sound/card1/input20
[   11.539671] checking generic (cf000000 130000) vs hw (d0000000 10000000)
[   11.539677] checking generic (cf000000 130000) vs hw (ce000000 2000000)
[   11.539680] fb: switching to nouveaufb from VESA VGA
[   11.539768] Console: switching to colour dummy device 80x25
[   11.540381] nouveau 0000:01:00.0: NVIDIA GT218 (0a8780b1)
[   11.685702] nouveau 0000:01:00.0: bios: version 70.18.64.00.0e
[   11.688334] nouveau 0000:01:00.0: fb: 512 MiB DDR3
[   11.742110] [TTM] Zone  kernel: Available graphics memory: 1026324 kiB
[   11.742113] [TTM] Initializing pool allocator
[   11.742127] [TTM] Initializing DMA pool allocator
[   11.742171] nouveau 0000:01:00.0: DRM: VRAM: 512 MiB
[   11.742175] nouveau 0000:01:00.0: DRM: GART: 1048576 MiB
[   11.742183] nouveau 0000:01:00.0: DRM: TMDS table version 2.0
[   11.742187] nouveau 0000:01:00.0: DRM: DCB version 4.0
[   11.742192] nouveau 0000:01:00.0: DRM: DCB outp 01: 02011300 00000000
[   11.742197] nouveau 0000:01:00.0: DRM: DCB outp 02: 02022362 00020010
[   11.742202] nouveau 0000:01:00.0: DRM: DCB conn 01: 00000100
[   11.742205] nouveau 0000:01:00.0: DRM: DCB conn 02: 00001261
[   11.768840] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[   11.768845] [drm] Driver supports precise vblank timestamp query.
[   11.826828] nouveau 0000:01:00.0: DRM: MM: using COPY for buffer copies
[   11.943203] nouveau 0000:01:00.0: DRM: allocated 1920x1080 fb:
0x70000, bo ffff880074f27c00
[   11.943495] fbcon: nouveaufb (fb0) is primary device
[   12.017175] Console: switching to colour frame buffer device 240x67
[   12.019733] nouveau 0000:01:00.0: fb0: nouveaufb frame buffer device
[   12.033400] [drm] Initialized nouveau 1.3.1 20120801 for
0000:01:00.0 on minor 0
[   12.510479] EXT4-fs (sda3): mounted filesystem with ordered data
mode. Opts: data=ordered
[   12.933367] snd_hda_codec_hdmi hdaudioC1D1: HDMI: audio coding type
0 not expected
[   15.078250] IPv6: ADDRCONF(NETDEV_UP): wlp3s0: link is not ready
[   16.524370] wlp3s0: authenticate with 08:96:d7:7a:7f:0e
[   16.543819] wlp3s0: send auth to 08:96:d7:7a:7f:0e (try 1/3)
[   16.547448] wlp3s0: authenticated
[   16.550045] wlp3s0: associate with 08:96:d7:7a:7f:0e (try 1/3)
[   16.559965] wlp3s0: RX AssocResp from 08:96:d7:7a:7f:0e
(capab=0x431 status=0 aid=3)
[   16.560230] wlp3s0: associated
[   16.560248] IPv6: ADDRCONF(NETDEV_CHANGE): wlp3s0: link becomes ready

best,
rupert
