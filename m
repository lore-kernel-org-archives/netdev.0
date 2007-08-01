From: "Joachim Deguara" <joachim.deguara@amd.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Wed, 1 Aug 2007 10:01:23 +0200
Message-ID: <200708011001.24384.joachim.deguara@amd.com>
References: <20070731174522.b141178a.akpm@linux-foundation.org>
 <1185954811.5552.7.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"lkml List" <linux-kernel@vger.kernel.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1185954811.5552.7.camel@dell>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 August 2007 09:53:31 Michael Chan wrote:
> On Tue, 2007-07-31 at 17:45 -0700, Andrew Morton wrote:
> > On Tue, 31 Jul 2007 11:28:32 +0200 "Joachim Deguara"
> >
> > <joachim.deguara@amd.com> wrote:
> > > On my Acer Ferrari 1000 the tg3 ethernet no longer is available
> >
> > after a
> >
> > > suspend to ram with the latet 2.6.23-rc1-git9.
>
> It seems to work for me on the same 2.6.23-rc1-git9 kernel with the same
> tg3 hardware.  Can you narrow down the problem some more?  It seems that
> in your case, the chip registers are returning 0xffffffff after resume.
> Can you do lspci -xxxvvv on the tg3 adapter after resume?

Here are the lspci outputs for the tg3

Before

07:00.0 Network controller: Broadcom Corporation Unknown device 4328 (rev 01)
	Subsystem: AMBIT Microsystem Corp. Unknown device 0319
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at d0200000 (64-bit, non-prefetchable) [disabled] [size=16K]
	Region 2: Memory at d8000000 (64-bit, prefetchable) [disabled] [size=1M]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <4us, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
		Link: Latency L0s <4us, L1 <64us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [13c] Virtual Channel
	Capabilities: [15c] Power Budgeting
00: e4 14 28 43 00 00 10 00 01 00 80 02 00 00 00 00
10: 04 00 20 d0 00 00 00 00 0c 00 00 d8 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 68 14 19 03
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
40: 01 58 02 06 00 40 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 05 d0 80 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 10 00 18 00 00 00 00 01 00 00 00 03 00 00 00
90: 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 0f 64 00 00 00 1a 00 11 60 03 00
e0: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


and after s2ram:

07:00.0 Network controller: Broadcom Corporation Unknown device 4328 (rev 01)
	Subsystem: AMBIT Microsystem Corp. Unknown device 0319
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at d0200000 (64-bit, non-prefetchable) [disabled] [size=16K]
	Region 2: Memory at d8000000 (64-bit, prefetchable) [disabled] [size=1M]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <4us, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
		Link: Latency L0s <4us, L1 <64us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [13c] Virtual Channel
	Capabilities: [15c] Power Budgeting
00: e4 14 28 43 00 00 10 00 01 00 80 02 00 00 00 00
10: 04 00 20 d0 00 00 00 00 0c 00 00 d8 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 68 14 19 03
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
40: 01 58 02 06 00 40 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 05 d0 80 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 10 00 18 00 00 00 00 01 00 00 00 03 00 00 00
90: 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 0f 00 00 00 00 11 00 11 60 03 00
e0: 00 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


Using diff I see there are some differences, what they mean I will leave that 
to your expertise ;)

Thanks
-Joachim

Full outputs below



Before
--------


00:00.0 Host bridge: ATI Technologies Inc RS480 Host Bridge (rev 10)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort+ >SERR- <PERR-
	Latency: 64
00: 02 10 50 59 06 00 20 22 10 00 00 06 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 c4 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 42 20 05 00
50: 25 10 0e 01 00 00 00 00 00 00 00 00 00 00 00 00
60: 4f 00 00 00 00 00 00 00 00 00 00 00 2c 00 73 06
70: e0 08 00 00 00 00 00 00 20 4e 00 00 00 00 00 10
80: 10 10 00 02 94 14 00 03 20 00 00 00 22 21 00 10
90: 00 00 00 7c 45 cc 45 ed 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 08 00 80 01 60 20 11 11 d0 00 00 00
d0: 25 05 65 00 02 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 7f 00 00 00 00 00 00 00
f0: 00 00 00 00 00 80 80 00 00 00 00 00 00 00 48 01

00:01.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: d0100000-d01fffff
	Prefetchable memory behind bridge: 00000000d4000000-00000000d7ffffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [44] HyperTransport: MSI Mapping
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
00: 02 10 3f 5a 07 00 30 02 00 00 04 06 00 40 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 40 91 91 20 02
20: 10 d0 10 d0 01 d4 f1 d7 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 00 0c 00
40: 20 00 00 40 08 b0 03 a8 00 00 00 00 25 10 0e 01
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 25 10 0e 01 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:04.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 36 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 02 02 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 02 00 01 11 60 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: a0 00 00 00 ff 00 00 c0 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:05.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=03, subordinate=05, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes Disabled CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 37 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 03 05 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 12 00 01 11 60 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: a0 00 00 00 ff 00 00 c0 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:06.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 38 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 06 06 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 02 00 01 11 60 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: a0 00 00 00 ff 00 00 c0 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:07.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: d0200000-d02fffff
	Prefetchable memory behind bridge: 00000000d8000000-00000000d80fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 25.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 39 5a 06 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 07 07 00 f1 01 00 20
20: 20 d0 20 d0 01 d8 01 d8 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 04 40 00 11 10 e0 0c 00 00
70: c0 03 48 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 10 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: a0 00 00 00 ff 00 00 c0 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:12.0 IDE interface: ATI Technologies Inc 4379 Serial ATA Controller (rev 
80) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 22
	Region 0: I/O ports at 8440 [size=8]
	Region 1: I/O ports at 8430 [size=4]
	Region 2: I/O ports at 8420 [size=8]
	Region 3: I/O ports at 8410 [size=4]
	Region 4: I/O ports at 8400 [size=16]
	Region 5: Memory at d0004000 (32-bit, non-prefetchable) [size=512]
	[virtual] Expansion ROM at 8c000000 [disabled] [size=512K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
00: 02 10 79 43 07 00 b0 02 80 8f 01 01 08 40 00 00
10: 41 84 00 00 31 84 00 00 21 84 00 00 11 84 00 00
20: 01 84 00 00 00 40 00 d0 00 00 00 00 25 10 0e 01
30: 00 00 00 00 60 00 00 00 00 00 00 00 0a 01 00 00
40: 18 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 05 00 00 00 00 00 00 00 00 00 00 00 0e b7 00 00
60: 01 50 22 06 00 40 00 64 02 10 00 00 00 00 00 00
70: 08 00 60 00 00 80 f9 37 00 00 60 00 00 00 00 00
80: 03 00 00 00 22 00 00 00 00 00 01 00 b4 b2 f1 59
90: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
a0: 01 21 15 65 dd 62 dd 62 92 43 92 43 09 40 09 40
b0: 01 21 15 65 dd 62 dd 62 92 43 92 43 09 40 09 40
c0: 00 00 00 00 ff ff ff ff 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.0 USB Controller: ATI Technologies Inc IXP SB400 USB Host Controller 
(rev 80) (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0005000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 74 43 17 00 a0 02 80 10 03 0c 10 40 80 00
10: 00 50 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 40 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.1 USB Controller: ATI Technologies Inc IXP SB400 USB Host Controller 
(rev 80) (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0006000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 75 43 17 00 a0 02 80 10 03 0c 10 40 00 00
10: 00 60 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 40 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.2 USB Controller: ATI Technologies Inc IXP SB400 USB2 Host Controller 
(rev 80) (prog-if 20 [EHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0007000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
00: 02 10 73 43 17 00 b0 02 80 20 03 0c 10 40 00 00
10: 00 70 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 42 28 e0 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 20 00 00 00 20 00 00 00 20 00 00 00 20 00 00
70: 00 20 00 00 00 20 00 00 00 20 00 00 00 20 00 00
80: 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 00 00 01 00 00 08 80 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 7e
e0: 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.0 SMBus: ATI Technologies Inc IXP SB400 SMBus Controller (rev 83)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Region 0: I/O ports at 8450 [size=16]
	Region 1: Memory at d0004400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [b0] HyperTransport: MSI Mapping
00: 02 10 72 43 03 00 30 02 83 00 05 0c 00 00 80 00
10: 51 84 00 00 00 44 00 d0 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 b0 00 00 00 00 00 00 00 00 00 00 00
40: d4 bb 00 00 00 00 00 00 0f ff 00 00 00 00 00 00
50: ff 03 00 00 df 03 e4 00 00 00 00 00 00 00 00 00
60: 01 00 07 00 9f b1 9e 8f 00 90 00 00 20 00 00 00
70: 00 01 00 00 08 00 c0 fe ff 4e 00 00 00 00 00 00
80: 07 01 00 00 00 00 00 00 00 00 00 00 00 b0 0d 7a
90: 51 84 00 00 f9 ce ff 00 00 00 00 00 00 00 00 00
a0: 00 00 ff ff 00 00 00 00 08 37 0a 00 c0 09 00 f9
b0: 08 00 02 a8 00 00 00 00 00 00 00 00 f0 0f 13 01
c0: 7d db b6 ed 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: d8 0c 00 00 00 81 00 00 00 00 00 00 0a 00 38 01

00:14.1 IDE interface: ATI Technologies Inc Standard Dual Channel PCI IDE 
Controller (rev 80) (prog-if 80 [Master])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at 8460 [size=16]
	Capabilities: [70] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
00: 02 10 76 43 15 00 30 02 80 80 01 01 00 40 00 00
10: 81 84 00 00 75 84 00 00 79 84 00 00 71 84 00 00
20: 61 84 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 70 00 00 00 00 00 00 00 0b 01 00 00
40: 99 99 99 99 ff ff ff ff 01 01 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 40 01 1c 2c 46 18 01 00 00 00 ff 03 00 00
70: 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.2 Audio device: ATI Technologies Inc SB450 HDA Audio (rev 01)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin ? routed to IRQ 16
	Region 0: Memory at d0000000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
00: 02 10 7b 43 06 00 10 04 01 00 03 04 08 40 00 00
10: 04 00 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 00 00 00
40: 00 00 02 40 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 60 42 c8 00 00 00 00 00 00 00 00 00 00 00 00
60: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.3 ISA bridge: ATI Technologies Inc IXP SB400 PCI-ISA Bridge (rev 80)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
00: 02 10 77 43 0f 00 20 02 80 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 04 00 00 00 ff 08 00 70 87 ff 20 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 68 00 00 00 0e 00 0f 00 f0 ff ff ff
70: 67 45 23 00 01 00 00 00 00 00 00 00 03 00 00 00
80: 08 00 03 a8 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.4 PCI bridge: ATI Technologies Inc IXP SB400 PCI-PCI Bridge (rev 80) 
(prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=08, subordinate=09, sec-latency=64
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: d0300000-d03fffff
	Prefetchable memory behind bridge: 88000000-8bffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
00: 02 10 71 43 07 00 a0 02 80 01 04 06 00 40 81 00
10: 00 00 00 00 00 00 00 00 00 08 09 40 21 21 80 22
20: 30 d0 30 d0 00 88 f0 8b 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 26 00 30 ff 00 00 00 00 3c 01 3a f1 00 00 00 00
50: 01 00 00 00 08 00 03 a8 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 06
e0: 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=8
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02
00: 22 10 00 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
40: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
50: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
60: 00 00 01 00 e4 00 00 00 20 c8 2f 0f 30 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 08 00 01 21 20 a8 11 11 22 05 35 80 02 00 00 00
90: 5a 11 52 01 00 00 ff 00 07 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
00: 22 10 01 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 03 00 00 00 00 00 7f 00 00 00 00 00 01 00 00 00
50: 00 00 00 00 02 00 00 00 00 00 00 00 03 00 00 00
60: 00 00 00 00 04 00 00 00 00 00 00 00 05 00 00 00
70: 00 00 00 00 06 00 00 00 00 00 00 00 07 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 03 00 d8 00 00 ff df 00 03 00 d4 00 80 ff d7 00
a0: 03 0a 00 00 00 0b 00 00 03 00 f0 00 00 ff ff 00
b0: 03 00 e0 00 80 ff ef 00 03 00 80 00 00 ff d3 00
c0: 00 00 00 00 00 00 00 00 13 10 00 00 00 f0 0f 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 03 00 00 ff 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM 
Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
00: 22 10 02 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 01 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: e0 3e 78 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 46 00 00 00 00 00 00 00
80: 02 00 00 00 00 00 00 00 24 a2 68 5d 20 13 13 00
90: 20 0c 01 00 5a 80 10 67 39 00 00 80 00 00 00 00
a0: ed 06 00 5d 00 00 00 00 00 00 00 00 00 00 00 00
b0: e8 94 b5 24 3a 00 00 00 27 c2 31 c4 f8 ad 80 0f
c0: 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 30 87 14 c1 30 82 50 a8 00 08 4d 88 43 03 40 e0
e0: 20 02 15 8f 61 42 00 c4 60 0a 0e 88 34 05 48 c4
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Capabilities: [f0] #0f [0010]
00: 22 10 03 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 f0 00 00 00 00 00 00 00 00 00 00 00
40: ff 3b 04 00 40 00 10 0a 00 00 00 00 00 00 00 00
50: 10 02 00 00 80 00 00 00 00 00 00 00 00 80 10 52
60: 1d 00 00 00 21 77 1f 00 c0 00 00 00 00 00 00 00
70: 11 01 32 51 21 40 70 50 00 2a 00 08 17 21 00 00
80: 31 33 07 33 13 31 13 31 00 00 00 00 00 00 00 00
90: 00 00 00 00 4f 0a 00 00 10 00 12 21 00 00 00 00
a0: 9e 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 01 a7 0d 00 00 00 10 09 25 25 25 00
e0: 00 00 00 00 20 0e 63 00 01 17 00 00 00 00 00 00
f0: 0f 00 10 00 00 04 00 00 02 00 00 00 82 0f 04 00

01:05.0 VGA compatible controller: ATI Technologies Inc RS485 [Radeon Xpress 
1100 IGP] (prog-if 00 [VGA])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at d4000000 (32-bit, prefetchable) [size=64M]
	Region 1: I/O ports at 9000 [size=256]
	Region 2: Memory at d0100000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at d0120000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 02 10 75 59 07 00 b0 02 00 00 00 03 08 42 00 00
10: 08 00 00 d4 01 90 00 00 00 00 10 d0 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 08 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
50: 01 00 02 06 00 00 00 00 02 50 20 00 30 02 00 4f
60: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

07:00.0 Network controller: Broadcom Corporation Unknown device 4328 (rev 01)
	Subsystem: AMBIT Microsystem Corp. Unknown device 0319
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at d0200000 (64-bit, non-prefetchable) [disabled] [size=16K]
	Region 2: Memory at d8000000 (64-bit, prefetchable) [disabled] [size=1M]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <4us, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
		Link: Latency L0s <4us, L1 <64us
		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [13c] Virtual Channel
	Capabilities: [15c] Power Budgeting
00: e4 14 28 43 00 00 10 00 01 00 80 02 00 00 00 00
10: 04 00 20 d0 00 00 00 00 0c 00 00 d8 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 68 14 19 03
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
40: 01 58 02 06 00 40 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 05 d0 80 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 10 00 18 00 00 00 00 01 00 00 00 03 00 00 00
90: 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 0f 64 00 00 00 1a 00 11 60 03 00
e0: 40 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

08:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788 Gigabit 
Ethernet (rev 03)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0 (16000ns min)
	Interrupt: pin A routed to IRQ 22
	Region 0: Memory at d0300000 (32-bit, non-prefetchable) [size=64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 
Enable-
		Address: ffff6bfe7fffffb8  Data: fec7
00: e4 14 9c 16 06 00 b0 02 03 00 00 02 00 00 00 00
10: 00 00 30 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 07 00 00 00 25 10 0e 01
30: 00 00 ff ff 48 00 00 00 00 00 00 00 0a 01 40 00
40: 00 00 00 00 00 00 00 00 01 50 02 c0 00 20 00 00
50: 03 58 fc 00 6f bf be 7f 05 00 86 00 b8 ff ff 7f
60: fe 6b ff ff c7 fe 00 00 98 00 03 30 00 00 3f 76
70: f6 10 00 00 20 00 00 80 14 04 00 00 00 00 00 00
80: 85 6b d0 36 03 40 00 0c 34 00 13 04 82 90 09 04
90: 09 97 00 01 00 00 00 00 00 00 00 00 eb 01 00 00
a0: 00 00 00 00 23 01 00 00 00 00 00 00 cb 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

08:09.0 CardBus bridge: Texas Instruments PCIxx12 Cardbus Controller
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at d0314000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=08, secondary=09, subordinate=0c, sec-latency=176
	Memory window 0: 88000000-8bfff000 (prefetchable)
	Memory window 1: 90000000-93fff000
	I/O window 0: 00002000-000020ff
	I/O window 1: 00002400-000024ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite-
	16-bit legacy interface ports at 0001
00: 4c 10 39 80 07 00 10 02 00 00 07 06 08 40 82 00
10: 00 40 31 d0 a0 00 00 02 08 09 0c b0 00 00 00 88
20: 00 f0 ff 8b 00 00 00 90 00 f0 ff 93 00 20 00 00
30: fc 20 00 00 00 24 00 00 fc 24 00 00 0b 01 c0 01
40: 25 10 0e 01 01 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 60 d0 44 08 19 00 d4 02 00 00 17 00 22 1b 72 01
90: c0 02 66 60 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 00 12 fe 00 00 c0 00 00 00 00 00 00 00 00 00
b0: 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 36 24 47 50 20 16 00 73 00 00 00 00 00 00 00 00

08:09.1 FireWire (IEEE 1394): Texas Instruments PCIxx12 OHCI Compliant IEEE 
1394 Host Controller (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64 (750ns min, 1000ns max), Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 21
	Region 0: Memory at d0315000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at d0310000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+
00: 4c 10 3a 80 16 00 10 02 00 10 00 0c 08 40 80 00
10: 00 50 31 d0 00 00 31 d0 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 02 03 04
40: 00 00 00 00 01 00 02 7e 00 80 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00
f0: 00 08 00 00 82 10 00 00 25 10 0e 01 00 00 00 00

08:09.2 Mass storage controller: Texas Instruments 5-in-1 Multimedia Card 
Reader (SD/MMC/MS/MS PRO/xD)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64 (1750ns min, 1000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at d0316000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 4c 10 3b 80 06 00 10 02 00 00 80 01 08 40 80 00
10: 00 60 31 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 01 07 04
40: 00 00 00 00 01 00 02 7e 00 00 00 00 00 00 00 00
50: 25 10 0e 01 05 01 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00



After
------


00:00.0 Host bridge: ATI Technologies Inc RS480 Host Bridge (rev 10)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort+ >SERR- <PERR-
	Latency: 64
00: 02 10 50 59 06 00 20 22 10 00 00 06 00 40 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 c4 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 42 20 05 00
50: 25 10 0e 01 00 00 00 00 00 00 00 00 00 00 00 00
60: 87 00 00 00 0b 00 00 00 00 00 00 00 2c 00 73 06
70: e0 08 00 00 00 00 00 00 20 4e 00 00 00 00 00 10
80: 10 10 00 02 94 14 00 03 20 00 00 00 22 21 00 10
90: 00 00 00 7c 45 cc 45 ed 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 08 00 80 01 60 20 11 11 d0 00 00 00
d0: 25 05 65 00 02 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 80 80 00 00 00 00 00 00 00 48 01

00:01.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 00009000-00009fff
	Memory behind bridge: d0100000-d01fffff
	Prefetchable memory behind bridge: 00000000d4000000-00000000d7ffffff
	Secondary status: 66MHz+ FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
	Capabilities: [44] HyperTransport: MSI Mapping
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
00: 02 10 3f 5a 07 00 30 02 00 00 04 06 00 40 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 40 91 91 20 22
20: 10 d0 10 d0 01 d4 f1 d7 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 00 0c 00
40: 20 00 00 40 08 b0 03 a8 00 00 00 00 25 10 0e 01
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 25 10 0e 01 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:04.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 36 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 02 02 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 02 00 01 11 00 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 02 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:05.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=03, subordinate=05, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 37 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 03 05 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 02 00 01 11 60 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 02 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:06.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=06, subordinate=06, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 247
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x16
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 38 5a 04 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 06 06 00 f1 01 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 f7 02 00 01 11 00 00 00 00
70: c0 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 02 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:07.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge (prog-if 00 [Normal 
decode])
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
	Bus: primary=00, secondary=07, subordinate=07, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: d0200000-d02fffff
	Prefetchable memory behind bridge: 00000000d8000000-00000000d80fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express Root Port (Slot+) IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <64ns, L1 <1us
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 4
		Link: Latency L0s <64ns, L1 <1us
		Link: ASPM L1 Enabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
		Slot: Number 0, PowerLimit 0.000000
		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
		Slot: AttnInd Off, PwrInd Off, Power-
		Root: Correctable- Non-Fatal- Fatal- PME-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
	Capabilities: [b0] Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Capabilities: [b8] HyperTransport: MSI Mapping
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [140] Virtual Channel
00: 02 10 39 5a 06 00 10 00 00 00 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 07 07 00 f1 01 00 00
20: 20 d0 20 d0 01 d8 01 d8 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 03 c8 00 00 00 00 10 80 41 01 20 00 00 00
60: 10 08 00 00 11 0c 00 04 02 00 11 10 00 00 00 00
70: c0 03 48 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d b8 00 00 25 10 0e 01 08 00 03 a8 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 02 00 00 00 00 c0 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:12.0 IDE interface: ATI Technologies Inc 4379 Serial ATA Controller (rev 
80) (prog-if 8f [Master SecP SecO PriP PriO])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 22
	Region 0: I/O ports at 8440 [size=8]
	Region 1: I/O ports at 8430 [size=4]
	Region 2: I/O ports at 8420 [size=8]
	Region 3: I/O ports at 8410 [size=4]
	Region 4: I/O ports at 8400 [size=16]
	Region 5: Memory at d0004000 (32-bit, non-prefetchable) [size=512]
	[virtual] Expansion ROM at 8c000000 [disabled] [size=512K]
	Capabilities: [60] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
00: 02 10 79 43 07 00 b0 02 80 8f 01 01 08 40 00 00
10: 41 84 00 00 31 84 00 00 21 84 00 00 11 84 00 00
20: 01 84 00 00 00 40 00 d0 00 00 00 00 25 10 0e 01
30: 00 00 00 00 60 00 00 00 00 00 00 00 0a 01 00 00
40: 18 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 05 00 00 00 00 00 00 00 00 00 00 00 0e b7 00 00
60: 01 50 22 06 00 40 00 64 02 10 00 00 00 00 00 00
70: 08 00 60 00 00 80 f9 37 00 00 60 00 00 00 00 00
80: 03 00 00 00 22 00 00 00 00 00 01 00 b4 b2 f1 59
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 21 15 65 dd 62 dd 62 92 43 92 43 09 40 09 40
b0: 01 21 15 65 dd 62 dd 62 92 43 92 43 09 40 09 40
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.0 USB Controller: ATI Technologies Inc IXP SB400 USB Host Controller 
(rev 80) (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0005000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 74 43 17 00 a0 02 80 10 03 0c 10 40 80 00
10: 00 50 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 40 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.1 USB Controller: ATI Technologies Inc IXP SB400 USB Host Controller 
(rev 80) (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0006000 (32-bit, non-prefetchable) [size=4K]
00: 02 10 75 43 17 00 a0 02 80 10 03 0c 10 40 00 00
10: 00 60 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 40 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:13.2 USB Controller: ATI Technologies Inc IXP SB400 USB2 Host Controller 
(rev 80) (prog-if 20 [EHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at d0007000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+
00: 02 10 73 43 17 00 b0 02 80 20 03 0c 10 40 00 00
10: 00 70 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 dc 00 00 00 00 00 00 00 0b 01 00 00
40: 80 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00
50: 42 28 e0 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 20 20 00 00 00 20 00 00 00 20 00 00 00 20 00 00
70: 00 20 00 00 00 20 00 00 00 20 00 00 00 20 00 00
80: 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 00 01 01 00 20 08 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 7e
e0: 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.0 SMBus: ATI Technologies Inc IXP SB400 SMBus Controller (rev 83)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Region 0: I/O ports at 8450 [size=16]
	Region 1: Memory at d0004400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [b0] HyperTransport: MSI Mapping
00: 02 10 72 43 03 00 30 02 83 00 05 0c 00 00 80 00
10: 51 84 00 00 00 44 00 d0 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 b0 00 00 00 00 00 00 00 00 00 00 00
40: d4 bb 00 00 00 00 00 00 0f ff 00 00 00 00 00 00
50: ff 03 00 00 df 03 e4 00 00 00 00 00 00 00 00 00
60: 01 00 07 00 9f b1 9e cf 00 90 00 00 20 00 00 00
70: 00 01 00 00 08 00 c0 fe ff 4e 00 00 00 00 00 00
80: 07 01 00 00 00 00 00 00 00 00 00 00 00 b0 0d 7a
90: 51 84 00 00 f9 ce ff 00 00 00 00 00 00 00 00 00
a0: 00 00 ff ff ff ff 00 00 08 37 0a 00 c0 29 00 f9
b0: 08 00 02 a8 00 00 00 00 00 00 00 00 f0 0f 13 01
c0: 7d db b6 ed 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: d8 0c 00 00 00 81 00 00 00 00 00 00 0a 00 18 01

00:14.1 IDE interface: ATI Technologies Inc Standard Dual Channel PCI IDE 
Controller (rev 80) (prog-if 82 [Master PriP])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Interrupt: pin A routed to IRQ 16
	Region 0: I/O ports at 01f0 [size=8]
	Region 1: I/O ports at 03f4 [size=1]
	Region 2: I/O ports at 0170 [size=8]
	Region 3: I/O ports at 0374 [size=1]
	Region 4: I/O ports at 8460 [size=16]
	Capabilities: [70] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 
Enable-
		Address: 00000000  Data: 0000
00: 02 10 76 43 15 00 30 02 80 82 01 01 00 40 00 00
10: 81 84 00 00 75 84 00 00 79 84 00 00 71 84 00 00
20: 61 84 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 70 00 00 00 00 00 00 00 0b 01 00 00
40: 99 99 99 99 ff ff ff ff 00 01 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 40 01 10 2c 46 18 01 00 00 00 ff 03 00 00
70: 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.2 Audio device: ATI Technologies Inc SB450 HDA Audio (rev 01)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin ? routed to IRQ 16
	Region 0: Memory at d0000000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
00: 02 10 7b 43 06 00 10 04 01 00 03 04 08 40 00 00
10: 04 00 00 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 00 00 00
40: 00 00 02 40 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 60 42 c8 00 00 00 00 00 00 00 00 00 00 00 00
60: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.3 ISA bridge: ATI Technologies Inc IXP SB400 PCI-ISA Bridge (rev 80)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 0
00: 02 10 77 43 0f 00 20 02 80 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 04 00 00 00 ff 08 00 70 87 ff 20 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 68 00 00 00 0e 00 0f 00 f0 ff ff ff
70: 67 45 23 00 01 00 00 00 00 00 00 00 03 00 00 00
80: 08 00 03 a8 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:14.4 PCI bridge: ATI Technologies Inc IXP SB400 PCI-PCI Bridge (rev 80) 
(prog-if 01 [Subtractive decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=08, subordinate=09, sec-latency=64
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: d0300000-d03fffff
	Prefetchable memory behind bridge: 88000000-8bffffff
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR- NoISA- VGA- MAbort- >Reset- FastB2B-
00: 02 10 71 43 07 00 a0 02 80 01 04 06 00 40 81 00
10: 00 00 00 00 00 00 00 00 00 08 09 40 21 21 80 22
20: 30 d0 30 d0 00 88 f0 8b 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 26 00 30 ff 00 00 00 00 3c 01 3a f1 00 00 00 00
50: 01 00 00 00 08 00 03 a8 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 06
e0: 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
HyperTransport Technology Configuration
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Capabilities: [80] HyperTransport: Host or Secondary Interface
		!!! Possibly incomplete decoding
		Command: WarmRst+ DblEnd-
		Link Control: CFlE- CST- CFE- <LkFail- Init+ EOC- TXO- <CRCErr=8
		Link Config: MLWI=16bit MLWO=16bit LWI=16bit LWO=16bit
		Revision ID: 1.02
00: 22 10 00 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00
40: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
50: 01 01 01 00 01 01 01 00 01 01 01 00 01 01 01 00
60: 00 00 01 00 e4 00 00 00 20 c8 2f 0f 3c 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 08 00 01 21 20 a8 11 11 22 05 35 80 02 00 00 00
90: 5a 11 52 01 00 00 ff 00 07 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Address Map
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
00: 22 10 01 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 03 00 00 00 00 00 7f 00 00 00 00 00 01 00 00 00
50: 00 00 00 00 02 00 00 00 00 00 00 00 03 00 00 00
60: 00 00 00 00 04 00 00 00 00 00 00 00 05 00 00 00
70: 00 00 00 00 06 00 00 00 00 00 00 00 07 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 03 00 d8 00 00 ff df 00 03 00 d4 00 80 ff d7 00
a0: 03 0a 00 00 00 0b 00 00 03 00 f0 00 00 ff ff 00
b0: 03 00 e0 00 80 ff ef 00 03 00 80 00 00 ff d3 00
c0: 00 00 00 00 00 00 00 00 13 10 00 00 00 f0 0f 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 03 00 00 ff 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM 
Controller
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
00: 22 10 02 11 00 00 00 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 01 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: e0 3e 78 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 46 00 00 00 00 00 00 00
80: 02 00 00 00 00 00 00 00 24 a2 68 5d 20 13 13 00
90: 20 0c 01 00 5a 80 10 67 39 00 00 80 00 00 00 00
a0: ed 06 00 5d 00 00 00 00 00 00 00 00 00 00 00 00
b0: 70 44 f9 95 09 00 00 00 27 c2 31 c4 f8 ad 80 0f
c0: 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 30 87 14 c1 30 82 50 a8 00 08 4d 88 43 03 40 e0
e0: 20 02 15 8f 61 42 00 c4 60 0a 0e 88 34 05 48 c4
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] 
Miscellaneous Control
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Capabilities: [f0] #0f [0010]
00: 22 10 03 11 00 00 10 00 00 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 f0 00 00 00 00 00 00 00 00 00 00 00
40: ff 3b 04 00 40 00 10 0a 00 00 00 00 00 00 00 00
50: 10 02 00 00 80 00 00 00 00 00 00 00 00 80 10 52
60: 1d 00 00 00 01 77 1f 00 c0 00 00 00 00 00 00 00
70: 11 01 32 51 21 40 70 50 00 2a 00 08 17 21 00 00
80: 31 33 07 33 13 31 13 31 00 00 00 00 00 00 00 00
90: 00 00 00 00 4f 0a 00 00 10 00 12 21 00 00 00 00
a0: 9e 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 01 a7 0d 00 00 00 10 09 25 25 25 00
e0: 00 00 00 00 20 0e 64 00 01 17 00 00 00 00 00 00
f0: 0f 00 10 00 00 00 00 00 00 00 00 00 82 0f 04 00

01:05.0 VGA compatible controller: ATI Technologies Inc RS485 [Radeon Xpress 
1100 IGP] (prog-if 00 [VGA])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at d4000000 (32-bit, prefetchable) [size=64M]
	Region 1: I/O ports at 9000 [size=256]
	Region 2: Memory at d0100000 (32-bit, non-prefetchable) [size=64K]
	[virtual] Expansion ROM at d0120000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 02 10 75 59 07 00 b0 02 00 00 00 03 08 42 00 00
10: 08 00 00 d4 01 90 00 00 00 00 10 d0 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 50 00 00 00 00 00 00 00 0b 01 08 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
50: 01 00 02 06 00 00 00 00 02 50 20 00 30 02 00 4f
60: 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

07:00.0 Network controller: Broadcom Corporation Unknown device 4328 (rev 01)
	Subsystem: AMBIT Microsystem Corp. Unknown device 0319
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at d0200000 (64-bit, non-prefetchable) [disabled] [size=16K]
	Region 2: Memory at d8000000 (64-bit, prefetchable) [disabled] [size=1M]
	Capabilities: [40] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 
Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [d0] Express Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
		Device: Latency L0s <4us, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
		Link: Latency L0s <4us, L1 <64us
		Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
	Capabilities: [13c] Virtual Channel
	Capabilities: [15c] Power Budgeting
00: e4 14 28 43 00 00 10 00 01 00 80 02 00 00 00 00
10: 04 00 20 d0 00 00 00 00 0c 00 00 d8 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 68 14 19 03
30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
40: 01 58 02 06 00 40 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 05 d0 80 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 10 00 18 00 00 00 00 01 00 00 00 03 00 00 00
90: 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 0f 00 00 00 00 11 00 11 60 03 00
e0: 00 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

08:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788 Gigabit 
Ethernet (rev 03)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Interrupt: pin A routed to IRQ 22
	Region 0: Memory at d0300000 (32-bit, non-prefetchable) [disabled] [size=64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 
Enable-
		Address: ffff6bfe7fffffb8  Data: fec7
00: e4 14 9c 16 00 00 b0 02 03 00 00 02 00 00 00 00
10: 00 00 30 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 07 00 00 00 25 10 0e 01
30: 00 00 ff ff 48 00 00 00 00 00 00 00 0a 01 40 00
40: 00 00 00 00 00 00 00 00 01 50 02 c0 00 21 00 64
50: 03 58 fc 00 6f bf be 7f 05 00 86 00 b8 ff ff 7f
60: fe 6b ff ff c7 fe 00 00 9a 00 03 30 00 00 00 00
70: 76 10 00 00 40 00 00 00 50 00 00 00 00 00 00 00
80: 03 58 fc 00 00 00 00 00 00 00 00 00 fe 90 09 04
90: 01 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

08:09.0 CardBus bridge: Texas Instruments PCIxx12 Cardbus Controller
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at d0314000 (32-bit, non-prefetchable) [size=4K]
	Bus: primary=08, secondary=09, subordinate=0c, sec-latency=176
	Memory window 0: 88000000-8bfff000 (prefetchable)
	Memory window 1: 90000000-93fff000
	I/O window 0: 00002000-000020ff
	I/O window 1: 00002400-000024ff
	BridgeCtl: Parity- SERR- ISA- VGA- MAbort- >Reset+ 16bInt+ PostWrite-
	16-bit legacy interface ports at 0001
00: 4c 10 39 80 07 00 10 02 00 00 07 06 08 40 82 00
10: 00 40 31 d0 a0 00 00 02 08 09 0c b0 00 00 00 88
20: 00 f0 ff 8b 00 00 00 90 00 f0 ff 93 00 20 00 00
30: fc 20 00 00 00 24 00 00 fc 24 00 00 0b 01 c0 01
40: 25 10 0e 01 01 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 60 d0 44 08 19 00 d4 02 00 00 17 00 22 1b 72 01
90: c0 02 66 60 00 00 00 00 00 00 00 00 00 00 00 00
a0: 01 00 12 fe 00 00 c0 00 00 00 00 00 00 00 00 00
b0: 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 36 24 47 50 20 16 00 73 00 00 00 00 00 00 00 00

08:09.1 FireWire (IEEE 1394): Texas Instruments PCIxx12 OHCI Compliant IEEE 
1394 Host Controller (prog-if 10 [OHCI])
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64 (750ns min, 1000ns max), Cache Line Size: 32 bytes
	Interrupt: pin B routed to IRQ 21
	Region 0: Memory at d0315000 (32-bit, non-prefetchable) [size=2K]
	Region 1: Memory at d0310000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME+
00: 4c 10 3a 80 16 00 10 02 00 10 00 0c 08 40 80 00
10: 00 50 31 d0 00 00 31 d0 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 02 03 04
40: 00 00 00 00 01 00 02 7e 00 80 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00
f0: 00 08 00 00 82 10 00 00 25 10 0e 01 00 00 00 00

08:09.2 Mass storage controller: Texas Instruments 5-in-1 Multimedia Card 
Reader (SD/MMC/MS/MS PRO/xD)
	Subsystem: Acer Incorporated [ALI] Unknown device 010e
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- 
<MAbort- >SERR- <PERR-
	Latency: 64 (1750ns min, 1000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 20
	Region 0: Memory at d0316000 (32-bit, non-prefetchable) [size=4K]
	Capabilities: [44] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
00: 4c 10 3b 80 06 00 10 02 00 00 80 01 08 40 80 00
10: 00 60 31 d0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 25 10 0e 01
30: 00 00 00 00 44 00 00 00 00 00 00 00 0b 01 07 04
40: 00 00 00 00 01 00 02 7e 00 00 00 00 00 00 00 00
50: 25 10 0e 01 05 01 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00



