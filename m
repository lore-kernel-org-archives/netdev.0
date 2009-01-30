From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 18:45:25 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901301826490.5027@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop> <20090129184215.GA13459@xw6200.broadcom.net> <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
 <20090129222247.GA13861@xw6200.broadcom.net> <alpine.DEB.2.00.0901291730030.5149@parag-desktop> <20090130184030.GA14933@xw6200.broadcom.net> <alpine.DEB.2.00.0901301743410.4989@parag-desktop> <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:22329 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbZA3Xpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:45:38 -0500
In-Reply-To: <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Linus Torvalds wrote:

> 
> Because we obviously have two people who say that their tg3 suspend/resume 
> works fine, so the tg3 driver is obviously not _totally_ broken. So I'm 
> wondering if there is something funny in between the CPU and the tg3, like 
> a hotplug bridge that needs magic to wake up properly.
> 
> Because clearly the PCI config space addresses are working fine, but the 
> thing is, while PCI config space accesses are routed by the device number 
> (and the bridges notion of secondary bridging), the PCI memory space 
> routing is based on address. So a PCI bridge can easily get one right (in 
> fact, it's really hard to get config space accesses wrong without the 
> bridges being _totally_ screwed up), while not routing the other at all.
> 
> So just do that "lspci -vvxxx" for the whole box, before and after, and 
> send us the "before" and the "diff -u before after" thing, and maybe that 
> shows something interesting. Because some bridge chip being confused would 
> also explain why a total re-init of the whole tg3 chip by a driver unload 
> and reload doesn't seem to help.

Totally worth having this problem from a "getting an opportunity to 
understand" standpoint. This confirms my long standing suspicion that bugs 
in Linux kernel are merely a handiwork of few clever people to get more 
people to understand and contribute :)

Any how  here is the pre-suspend lspci -vvxxx output followed by diff -u -

00:00.0 Host bridge: Intel Corporation 5400 Chipset Memory Controller Hub (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 255
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit- Queue=0/1 Enable-
		Address: fee00000  Data: 0000
	Capabilities: [6c] Express (v2) Root Port (Slot-), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise+ LLActRep+ BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [100] Advanced Error Reporting <?>
00: 86 80 03 40 04 01 10 00 20 00 00 06 10 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 01 00 00
40: 00 00 00 00 00 00 00 00 84 14 00 00 82 01 00 00
50: 01 58 03 c8 08 00 00 00 05 6c 02 00 00 00 e0 fe
60: 00 00 00 00 00 00 00 00 23 02 63 00 10 00 42 00
70: 01 80 00 00 0f 00 00 00 41 4c 19 00 40 00 41 30
80: 80 0c 00 00 c0 03 40 01 00 00 00 00 00 00 00 00
90: 17 00 00 00 0a 00 00 00 00 00 00 00 41 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 01 00 71 fe 0c 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 ff 07 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 03 41 00 00 60 00 00 00 00 21 11 00
e0: 01 02 01 02 f9 32 3a 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:01.0 PCI bridge: Intel Corporation 5400 Chipset PCI Express Port 1 (rev 20)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=80, subordinate=80, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit- Queue=0/1 Enable+
		Address: fee0f00c  Data: 4171
	Capabilities: [6c] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #4, Speed 5GT/s, Width x16, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise+ LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 150.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Off, PwrInd Off, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet- Interlock-
			Changed: MRL- PresDet+ LinkState-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [b0] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 21 40 07 05 10 00 20 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 00 80 80 00 f0 00 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 01 06 00
40: 00 00 00 00 00 00 00 00 84 14 00 00 02 03 00 00
50: 01 58 03 c8 08 00 00 00 05 6c 03 00 0c f0 e0 fe
60: 71 41 00 00 00 00 00 00 00 00 00 00 10 b0 42 01
70: 01 80 00 00 0f 00 00 00 02 4d 39 04 40 00 01 10
80: 00 4b 00 00 c0 03 08 00 00 00 00 00 00 00 00 00
90: 17 00 00 00 0a 00 00 00 00 00 00 00 42 00 01 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:05.0 PCI bridge: Intel Corporation 5400 Chipset PCI Express Port 5 (rev 20)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=60, subordinate=60, sec-latency=0
	I/O behind bridge: 00001000-00001fff
	Memory behind bridge: f0000000-f00fffff
	Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit- Queue=0/1 Enable+
		Address: fee0f00c  Data: 4179
	Capabilities: [6c] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #8, Speed 5GT/s, Width x16, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise+ LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 150.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Off, PwrInd Off, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet+ LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [b0] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 25 40 07 05 10 00 20 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 00 60 60 00 10 10 00 00
20: 00 f0 00 f0 01 d0 f1 df 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 01 0a 00
40: 00 00 00 00 00 00 00 00 84 14 00 00 02 03 00 00
50: 01 58 03 c8 08 00 00 00 05 6c 03 00 0c f0 e0 fe
60: 79 41 00 00 00 00 00 00 00 00 00 00 10 b0 42 01
70: 01 80 00 00 0f 00 00 00 02 4d 39 08 40 00 01 31
80: 00 4b 00 00 c0 03 48 01 00 00 00 00 00 00 00 00
90: 17 00 00 00 0a 00 00 00 00 00 00 00 42 00 01 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:09.0 PCI bridge: Intel Corporation 5400 Chipset PCI Express Port 9 (rev 20)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=10, subordinate=40, sec-latency=0
	Memory behind bridge: f0300000-f03fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit- Queue=0/1 Enable+
		Address: fee0f00c  Data: 4181
	Capabilities: [6c] Express (v2) Root Port (Slot+), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE+ FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #12, Speed 5GT/s, Width x4, ASPM L0s L1, Latency L0 <1us, L1 <4us
			ClockPM- Suprise+ LLActRep+ BwNot+
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive+ BWMgmt- ABWMgmt-
		SltCap:	AttnBtn- PwrCtrl- MRL- AttnInd- PwrInd- HotPlug- Surpise-
			Slot #  0, PowerLimit 25.000000; Interlock- NoCompl-
		SltCtl:	Enable: AttnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq- LinkChg-
			Control: AttnInd Off, PwrInd Off, Power- Interlock-
		SltSta:	Status: AttnBtn- PowerFlt- MRL- CmdCplt- PresDet+ Interlock-
			Changed: MRL- PresDet- LinkState+
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [b0] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 29 40 07 05 10 00 20 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 00 10 40 00 f0 00 00 00
20: 30 f0 30 f0 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 01 06 00
40: 00 00 00 00 00 00 00 00 84 14 00 00 02 03 00 00
50: 01 58 03 c8 08 00 00 00 05 6c 03 00 0c f0 e0 fe
60: 81 41 00 00 00 00 00 00 00 00 00 00 10 b0 42 01
70: 01 80 00 00 0f 00 00 00 42 4c 39 0c 40 00 41 30
80: 80 0c 00 00 c0 03 40 01 00 00 00 00 00 00 00 00
90: 17 00 00 00 0a 00 00 00 00 00 00 00 01 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:10.0 Host bridge: Intel Corporation 5400 Chipset FSB Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel modules: i5k_amb
00: 86 80 30 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 ff 00 00 08 00 08 00 00 00 fe 00 00 00 00
50: 00 00 02 00 00 00 04 08 00 10 11 11 11 11 11 33
60: 00 12 88 01 01 e0 00 00 ff ff ff ff 00 00 00 00
70: 09 c0 e2 3f 00 00 00 00 09 c0 e2 3f 00 00 00 00
80: 01 00 80 00 02 02 80 00 00 00 00 00 00 00 00 00
90: 04 01 80 00 08 03 80 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 ff fb eb bf 10 01 00 00
e0: 76 06 00 00 00 00 00 00 00 00 00 00 20 00 00 00
f0: 58 7f 38 00 00 00 58 00 08 09 28 64 80 a2 fc 12

00:10.1 Host bridge: Intel Corporation 5400 Chipset FSB Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel modules: i5k_amb
00: 86 80 30 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: e0 01 70 46 03 00 00 00 cd 0a 55 35 32 59 02 00
50: 55 a1 ae c6 c8 00 09 00 16 1a b2 fd 07 00 00 00
60: 00 00 eb 01 08 00 00 00 00 00 00 00 00 d0 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 03 01 00 00 82 02 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 20 00 00 00 00
a0: 00 00 00 20 00 00 00 00 60 06 26 08 60 f6 bf 1f
b0: fb ff ff 1f fb ff ff 1f fb ff ff 1f 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:10.2 Host bridge: Intel Corporation 5400 Chipset FSB Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel modules: i5k_amb
00: 86 80 30 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 af ff 03 b0 07 2c 03 ff af ff 03 ff af ff 03
e0: ff af ff 03 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 1f 00 1f 00 1f 00 1f 00 1f 00

00:10.3 Host bridge: Intel Corporation 5400 Chipset FSB Registers (rev 20)
	Subsystem: Intel Corporation Device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel modules: i5k_amb
00: 86 80 30 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 86 80
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 0d 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
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

00:10.4 Host bridge: Intel Corporation 5400 Chipset FSB Registers (rev 20)
	Subsystem: Intel Corporation Device 8086
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel modules: i5k_amb
00: 86 80 30 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 86 80
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 2d 00 a8 dc 00 1c 07 07 b4 00 c8 00
f0: 00 00 00 7f 00 00 00 00 48 00 00 00 00 00 c8 00

00:11.0 Host bridge: Intel Corporation 5400 Chipset CE/SF Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 86 80 31 40 00 00 00 00 20 00 00 06 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 03 1a 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 01 00 01 00 10 00 10 00 01 00 01 00 10 00 10 00
d0: 00 c0 ff 03 0a 40 c0 03 90 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:15.0 Host bridge: Intel Corporation 5400 Chipset FBD Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 86 80 35 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30
50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40
60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00
70: 00 00 00 00 6b e0 6b e0 00 00 0b a9 00 00 0b a9
80: 24 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 01 01 08 00 01 01 08 00 01 01 08 00 01 01 08 00
a0: 01 01 08 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 10 3b 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 06 06 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:15.1 Host bridge: Intel Corporation 5400 Chipset FBD Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 86 80 35 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
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

00:16.0 Host bridge: Intel Corporation 5400 Chipset FBD Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 86 80 36 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30
50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40
60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00
70: 00 00 00 00 69 e0 69 e0 00 00 0b a9 00 00 0b a9
80: 65 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 01 01 20 00 01 01 20 00 01 01 20 00 01 01 20 00
a0: 01 01 20 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 c4 0e 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 06 06 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

00:16.1 Host bridge: Intel Corporation 5400 Chipset FBD Registers (rev 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
00: 86 80 36 40 00 00 00 00 20 00 00 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
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

00:1b.0 Audio device: Intel Corporation 631xESB/632xESB High Definition Audio Controller (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 21
	Region 0: Memory at f0200000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
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
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [130] Root Complex Link <?>
	Kernel driver in use: HDA Intel
	Kernel modules: snd-hda-intel
00: 86 80 9a 26 06 00 10 00 09 00 03 04 10 00 00 00
10: 04 00 20 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00
40: 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 60 42 c8 00 00 00 00 00 00 00 00 00 00 00 00
60: 05 70 80 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 10 00 91 00 00 00 00 00 00 08 10 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	Memory behind bridge: f0100000-f01fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [40] Express (v1) Root Port (Slot-), MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag+ RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 <4us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		RootCtl: ErrCorrectable- ErrNon-Fatal- ErrFatal- PMEIntEna- CRSVisible-
		RootCap: CRSVisible-
		RootSta: PME ReqID 0000, PMEStatus- PMEPending-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
		Address: fee0f00c  Data: 4189
	Capabilities: [90] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [a0] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [100] Virtual Channel <?>
	Capabilities: [180] Root Complex Link <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 90 26 07 05 10 00 09 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 00 0e 0e 00 f0 00 00 00
20: 10 f0 10 f0 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 40 00 00 00 00 00 00 00 03 01 06 00
40: 10 80 41 00 e0 0f 00 00 00 00 10 00 11 2c 01 01
50: 40 00 11 10 60 00 00 00 00 00 48 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 90 01 00 0c f0 e0 fe 89 41 00 00 00 00 00 00
90: 0d a0 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
a0: 01 00 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 11 80 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1d.0 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #1 (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 4: I/O ports at 2000 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd
00: 86 80 88 26 05 00 80 02 09 00 03 0c 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 01 20 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 03 01 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 2f 00 00 03 00 00 00 00 00 01 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1d.1 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #2 (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 4: I/O ports at 2020 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd
00: 86 80 89 26 05 00 80 02 09 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 21 20 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 05 02 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 2f 00 00 03 00 00 00 00 00 01 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1d.2 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #3 (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin C routed to IRQ 18
	Region 4: I/O ports at 2040 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd
00: 86 80 8a 26 05 00 80 02 09 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 41 20 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 07 03 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 2f 00 00 03 00 00 00 00 00 01 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1d.3 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset UHCI USB Controller #4 (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin D routed to IRQ 22
	Region 4: I/O ports at 2060 [size=32]
	Kernel driver in use: uhci_hcd
	Kernel modules: uhci-hcd
00: 86 80 8b 26 05 00 80 02 09 00 03 0c 00 00 00 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 61 20 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 0a 04 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 2f 00 00 03 00 00 00 00 00 01 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1d.7 USB Controller: Intel Corporation 631xESB/632xESB/3100 Chipset EHCI USB2 Controller (rev 09) (prog-if 20)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f0204000 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Debug port: BAR=1 offset=00a0
	Kernel driver in use: ehci_hcd
	Kernel modules: ehci-hcd
00: 86 80 8c 26 06 01 90 02 09 20 03 0c 00 00 00 00
10: 00 40 20 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 c2 c9 00 00 00 00 0a 00 a0 20 00 00 00 00
60: 20 20 ff 01 00 00 00 00 01 00 00 00 00 00 08 80
70: 00 00 df 3f 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 aa ff 00 ff ff ff 00 20 00 00 08
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 80 00 09 88 8c 40 00 80 0f 01 00 86 17 00 20

00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9) (prog-if 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [50] Subsystem: Hewlett-Packard Company Device 1307
00: 86 80 4e 24 07 01 10 00 d9 01 04 06 00 00 01 00
10: 00 00 00 00 00 00 00 00 00 01 01 20 f0 00 80 22
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 06 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

00:1f.0 ISA bridge: Intel Corporation 631xESB/632xESB/3100 Chipset LPC Interface Controller (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Kernel modules: intel-rng, iTCO_wdt
00: 86 80 70 26 07 01 00 02 09 00 01 06 00 00 80 00
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
40: 01 f8 00 00 80 00 00 00 01 fa 00 00 10 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 83 85 87 85 d0 00 00 00 80 83 8a 80 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 10 00 09 14 01 04 00 00 81 04 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 10 06 00 00 01 00 00 00 00 00 00 00 00 13 00 00
b0: 00 00 00 00 00 00 00 00 00 10 00 04 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 33 22 11 00 67 45 00 00 c0 c0 00 00 02 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 01 c0 d1 fe 00 00 00 00 80 0f 01 00 00 00 00 00

00:1f.2 RAID bus controller: Intel Corporation 631xESB/632xESB SATA RAID Controller (rev 09)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin B routed to IRQ 19
	Region 0: I/O ports at 20c0 [size=8]
	Region 1: I/O ports at 20d0 [size=4]
	Region 2: I/O ports at 20c8 [size=8]
	Region 3: I/O ports at 20d4 [size=4]
	Region 4: I/O ports at 2080 [size=32]
	Region 5: Memory at f0204400 (32-bit, non-prefetchable) [size=1K]
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [a8] SATA HBA <?>
	Kernel driver in use: ahci
	Kernel modules: ahci
00: 86 80 82 26 07 00 b0 02 09 00 04 01 00 00 00 00
10: c1 20 00 00 d1 20 00 00 c9 20 00 00 d5 20 00 00
20: 81 20 00 00 00 44 20 f0 00 00 00 00 3c 10 07 13
30: 00 00 00 00 70 00 00 00 00 00 00 00 05 02 00 00
40: 22 c0 22 c0 00 00 00 00 00 00 00 00 00 00 00 00
50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 01 a8 02 40 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 70 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 80 03 ff 00 80 03 40 00 00 00 00 00 00 00 00 00
a0: a0 00 00 00 aa 2a 49 2d 12 00 10 00 48 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00

0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755 Gigabit Ethernet PCI Express (rev 02)
	Subsystem: Hewlett-Packard Company Device 1307
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 54
	Region 0: Memory at f0100000 (64-bit, non-prefetchable) [size=64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [58] Vendor Specific Information <?>
	Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0f00c  Data: 41c1
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <4us, L1 <64us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [13c] Virtual Channel <?>
	Capabilities: [160] Device Serial Number 67-ee-00-fe-ff-29-1f-00
	Capabilities: [16c] Power Budgeting <?>
	Kernel driver in use: tg3
	Kernel modules: tg3
00: e4 14 7b 16 06 04 10 00 02 00 00 02 10 00 00 00
10: 04 00 10 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
30: 00 00 04 20 48 00 00 00 00 00 00 00 03 01 00 00
40: 00 00 00 00 00 00 00 00 01 50 03 c0 08 20 00 64
50: 03 58 fc 00 00 00 00 78 09 e8 78 00 95 ef 08 88
60: 00 00 00 00 00 00 00 00 98 02 02 a0 00 00 18 76
70: f2 10 00 00 c0 00 00 00 20 70 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 34 00 13 04 82 70 08 fc
90: 19 be 00 01 00 00 00 00 00 00 00 00 94 01 00 00
a0: 00 00 00 00 cc 00 00 00 00 00 00 00 29 01 00 00
b0: 00 00 00 00 00 00 00 8e 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 0e 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 8f 00 00 00 50 10 00 11 64 03 00
e0: 40 00 11 10 00 00 00 00 05 d0 81 00 0c f0 e0 fe
f0: 00 00 00 00 c1 41 00 00 00 00 00 00 00 00 00 00

10:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstream Port (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=10, secondary=1e, subordinate=40, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) Upstream Port, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-SlotPowerLimit 0.000000W
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 00 35 07 01 10 00 01 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 10 1e 40 00 f0 00 00 20
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 01 06 00
40: 00 28 02 10 10 70 51 00 01 00 00 00 0f 50 0a 00
50: 81 f4 03 00 00 00 41 10 00 00 00 00 00 00 00 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 00

10:00.3 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express to PCI-X Bridge (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=10, secondary=11, subordinate=1d, sec-latency=32
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk- DLActive- BWMgmt- ABWMgmt-
	Capabilities: [6c] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [d8] PCI-X bridge device
		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=133MHz
		Status: Dev=00:00.3 64bit- 133MHz- SCD- USC- SCO- SRD-
		Upstream: Capacity=65535 CommitmentLimit=65535
		Downstream: Capacity=65535 CommitmentLimit=65535
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel modules: shpchp
00: 86 80 0c 35 07 01 10 00 01 00 04 06 10 00 81 00
10: 00 00 00 00 00 00 00 00 10 11 1d 20 f0 00 a0 22
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 00 00 06 00
40: 80 6e 00 ff 10 6c 71 00 01 00 00 00 00 20 0a 00
50: 81 f4 03 00 00 00 41 00 00 00 00 00 05 6c 80 00
60: 00 00 00 00 00 00 00 00 00 00 00 00 01 80 02 c8
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 0d d8 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 07 00 c3 00 03 00 00 00
e0: ff ff ff ff ff ff ff ff 01 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00

1e:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E1 (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=1e, secondary=20, subordinate=20, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) Downstream Port (Slot-), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain+ CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0f00c  Data: 4191
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 10 35 07 05 10 00 01 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 1e 20 20 00 f0 00 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 91 41 00 00
70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 15 00 10 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

1e:01.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Downstream Port E2 (rev 01)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=1e, secondary=40, subordinate=40, sec-latency=0
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: [44] Express (v1) Downstream Port (Slot-), MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 <1us
			ExtTag- RBE- FLReset-
		DevCtl:	Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 unlimited, L1 unlimited
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; Disabled- Retrain+ CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x0, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0f00c  Data: 4199
	Capabilities: [70] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
	Capabilities: [100] Advanced Error Reporting <?>
	Kernel driver in use: pcieport-driver
	Kernel modules: shpchp
00: 86 80 14 35 07 05 10 00 01 00 04 06 10 00 01 00
10: 00 00 00 00 00 00 00 00 1e 40 40 00 f0 00 00 00
20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 99 41 00 00
70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 15 00 10 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

60:00.0 VGA compatible controller: ATI Technologies Inc RV535 [Radeon X1650 Series] (rev 9e)
	Subsystem: Diamond Multimedia Systems Device 0672
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 28
	Region 0: Memory at d0000000 (64-bit, prefetchable) [size=256M]
	Region 2: Memory at f0000000 (64-bit, non-prefetchable) [size=64K]
	Region 4: I/O ports at 1000 [size=256]
	[virtual] Expansion ROM at f0020000 [disabled] [size=128K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #8, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
00: 02 10 c7 71 07 00 10 00 9e 00 00 03 10 00 80 00
10: 0c 00 00 d0 00 00 00 00 04 00 00 f0 00 00 00 00
20: 01 10 00 00 00 00 00 00 00 00 00 00 92 10 72 06
30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 92 10 72 06
50: 01 58 02 06 00 00 00 00 10 80 01 00 a0 0f 58 02
60: 14 08 00 00 01 0d 00 08 40 00 01 11 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 05 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

60:00.1 Display controller: ATI Technologies Inc RV535 [Radeon X1650 Series] (rev 9e)
	Subsystem: Diamond Multimedia Systems Device 0673
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Region 0: Memory at f0010000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [58] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal+ Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 128 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
		LnkCap:	Port #8, Speed 2.5GT/s, Width x16, ASPM L0s L1, Latency L0 <64ns, L1 <1us
			ClockPM- Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x16, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
00: 02 10 e7 71 07 00 10 00 9e 00 80 03 10 00 00 00
10: 04 00 01 f0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 92 10 73 06
30: 00 00 00 00 50 00 00 00 00 00 00 00 ff 00 00 00
40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
50: 01 58 02 06 00 00 00 00 10 00 01 00 80 0f 00 00
60: 04 00 00 00 01 0d 00 08 00 00 01 11 00 00 00 00
70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

----------------
diff -u lspci-pre-suspend lspci-post-suspend

--- lspci-pre-suspend	2009-01-30 18:19:50.752275695 -0500
+++ lspci-post-suspend	2009-01-30 18:20:52.629779008 -0500
@@ -228,7 +228,7 @@
 90: 04 01 80 00 08 03 80 00 00 00 00 00 00 00 00 00
 a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
-c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+c0: 01 00 00 00 01 00 00 00 a5 a5 a5 a5 a5 a5 a5 a5
 d0: 00 00 00 00 00 00 00 00 ff fb eb bf 10 01 00 00
 e0: 76 06 00 00 00 00 00 00 00 00 00 00 20 00 00 00
 f0: 58 7f 38 00 00 00 58 00 08 09 28 64 80 a2 fc 12
@@ -286,9 +286,9 @@
 10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 86 80
 30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
-40: 00 00 00 00 00 00 0d 00 00 00 00 00 00 00 00 00
+40: 00 00 00 00 00 00 0f 00 00 00 00 00 00 00 00 00
 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
-60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+60: 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00
 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
@@ -353,7 +353,7 @@
 40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30
 50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40
 60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00
-70: 00 00 00 00 6b e0 6b e0 00 00 0b a9 00 00 0b a9
+70: 00 00 00 00 00 c0 00 c0 01 1b 4c b8 01 1b 4c b8
 80: 24 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 90: 01 01 08 00 01 01 08 00 01 01 08 00 01 01 08 00
 a0: 01 01 08 00 00 00 00 00 00 00 00 00 00 00 00 00
@@ -395,7 +395,7 @@
 40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30
 50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40
 60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00
-70: 00 00 00 00 69 e0 69 e0 00 00 0b a9 00 00 0b a9
+70: 00 00 00 00 00 40 00 40 01 1b 4c b8 01 1b 4c b8
 80: 65 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 90: 01 01 20 00 01 01 20 00 01 01 20 00 01 01 20 00
 a0: 01 01 20 00 00 00 00 00 00 00 00 00 00 00 00 00
@@ -472,7 +472,7 @@
 f0: 00 00 00 00 00 00 00 00 80 0f 01 00 00 00 00 00
 
 00:1c.0 PCI bridge: Intel Corporation 631xESB/632xESB/3100 Chipset PCI Express Root Port 1 (rev 09)
-	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
+	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
 	Latency: 0, Cache Line Size: 64 bytes
 	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
@@ -505,7 +505,7 @@
 	Capabilities: [180] Root Complex Link <?>
 	Kernel driver in use: pcieport-driver
 	Kernel modules: shpchp
-00: 86 80 90 26 07 05 10 00 09 00 04 06 10 00 81 00
+00: 86 80 90 26 04 05 10 00 09 00 04 06 10 00 81 00
 10: 00 00 00 00 00 00 00 00 00 0e 0e 00 f0 00 00 00
 20: 10 f0 10 f0 f1 ff 01 00 00 00 00 00 00 00 00 00
 30: 00 00 00 00 40 00 00 00 00 00 00 00 03 01 06 00
@@ -645,8 +645,8 @@
 30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00
 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 50: 01 58 c2 c9 00 00 00 00 0a 00 a0 20 00 00 00 00
-60: 20 20 ff 01 00 00 00 00 01 00 00 00 00 00 08 80
-70: 00 00 df 3f 00 00 00 00 00 00 00 00 00 00 00 00
+60: 20 20 ff 01 00 00 00 00 01 00 00 00 00 00 08 c0
+70: 00 00 dd 3f 00 00 00 00 00 00 00 00 00 00 00 00
 80: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00
 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
@@ -698,7 +698,7 @@
 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 80: 10 00 09 14 01 04 00 00 81 04 00 00 00 00 00 00
 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
-a0: 10 06 00 00 01 00 00 00 00 00 00 00 00 13 00 00
+a0: 10 06 00 00 00 00 00 00 00 00 00 00 00 13 00 00
 b0: 00 00 00 00 00 00 00 00 00 10 00 04 00 00 00 00
 c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 d0: 33 22 11 00 67 45 00 00 c0 c0 00 00 02 00 00 00
@@ -754,7 +754,7 @@
 	Capabilities: [50] Vital Product Data <?>
 	Capabilities: [58] Vendor Specific Information <?>
 	Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
-		Address: 00000000fee0f00c  Data: 41c1
+		Address: 00000000fee0f00c  Data: 41c9
 	Capabilities: [d0] Express (v1) Endpoint, MSI 00
 		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
 			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
@@ -778,24 +778,24 @@
 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
 30: 00 00 04 20 48 00 00 00 00 00 00 00 03 01 00 00
 40: 00 00 00 00 00 00 00 00 01 50 03 c0 08 20 00 64
-50: 03 58 fc 00 00 00 00 78 09 e8 78 00 95 ef 08 88
-60: 00 00 00 00 00 00 00 00 98 02 02 a0 00 00 18 76
-70: f2 10 00 00 c0 00 00 00 20 70 00 00 00 00 00 00
-80: 00 00 00 00 00 00 00 00 34 00 13 04 82 70 08 fc
-90: 19 be 00 01 00 00 00 00 00 00 00 00 94 01 00 00
-a0: 00 00 00 00 cc 00 00 00 00 00 00 00 29 01 00 00
-b0: 00 00 00 00 00 00 00 8e 00 00 00 00 00 00 00 00
+50: 03 58 fc 00 00 00 00 78 09 e8 78 00 96 f1 08 b8
+60: 00 00 00 00 00 00 00 00 9a 02 02 a0 00 00 00 10
+70: 72 10 00 00 c0 00 00 00 20 70 00 00 00 00 00 00
+80: 00 00 00 00 00 00 00 00 00 00 00 00 fe 70 08 fc
+90: 11 be 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 c0: 00 00 00 00 00 00 00 00 0e 00 00 00 00 00 00 00
 d0: 10 00 01 00 a0 8f 00 00 00 50 10 00 11 64 03 00
 e0: 40 00 11 10 00 00 00 00 05 d0 81 00 0c f0 e0 fe
-f0: 00 00 00 00 c1 41 00 00 00 00 00 00 00 00 00 00
+f0: 00 00 00 00 c9 41 00 00 00 00 00 00 00 00 00 00
 
 10:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express Upstream Port (rev 01)
 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
 	Latency: 0, Cache Line Size: 64 bytes
 	Bus: primary=10, secondary=1e, subordinate=40, sec-latency=0
-	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
+	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
 	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 	Capabilities: [44] Express (v1) Upstream Port, MSI 00
@@ -818,7 +818,7 @@
 	Kernel driver in use: pcieport-driver
 	Kernel modules: shpchp
 00: 86 80 00 35 07 01 10 00 01 00 04 06 10 00 81 00
-10: 00 00 00 00 00 00 00 00 10 1e 40 00 f0 00 00 20
+10: 00 00 00 00 00 00 00 00 10 1e 40 00 f0 00 00 00
 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
 30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 01 06 00
 40: 00 28 02 10 10 70 51 00 01 00 00 00 0f 50 0a 00
@@ -839,7 +839,7 @@
 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
 	Latency: 0, Cache Line Size: 64 bytes
 	Bus: primary=10, secondary=11, subordinate=1d, sec-latency=32
-	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
+	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- <SERR- <PERR-
 	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
 		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
 	Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00
@@ -848,7 +848,7 @@
 		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
 			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- BrConfRtry-
 			MaxPayload 128 bytes, MaxReadReq 512 bytes
-		DevSta:	CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- TransPend-
+		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
 		LnkCap:	Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, Latency L0 unlimited, L1 unlimited
 			ClockPM- Suprise- LLActRep- BwNot-
 		LnkCtl:	ASPM Disabled; Disabled- Retrain- CommClk-
@@ -857,7 +857,7 @@
 	Capabilities: [6c] Power Management version 2
 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
-	Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
+	Capabilities: [80] Subsystem: Gammagraphx, Inc. Device 0000
 	Capabilities: [d8] PCI-X bridge device
 		Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- Freq=133MHz
 		Status: Dev=00:00.3 64bit- 133MHz- SCD- USC- SCO- SRD-
@@ -866,14 +866,14 @@
 	Capabilities: [100] Advanced Error Reporting <?>
 	Kernel modules: shpchp
 00: 86 80 0c 35 07 01 10 00 01 00 04 06 10 00 81 00
-10: 00 00 00 00 00 00 00 00 10 11 1d 20 f0 00 a0 22
+10: 00 00 00 00 00 00 00 00 10 11 1d 20 f0 00 a0 02
 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
 30: 00 00 00 00 44 00 00 00 00 00 00 00 00 00 06 00
-40: 80 6e 00 ff 10 6c 71 00 01 00 00 00 00 20 0a 00
+40: 80 6e 00 ff 10 6c 71 00 01 00 00 00 00 20 00 00
 50: 81 f4 03 00 00 00 41 00 00 00 00 00 05 6c 80 00
 60: 00 00 00 00 00 00 00 00 00 00 00 00 01 80 02 c8
 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
-80: 0d d8 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
+80: 0d d8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
@@ -916,7 +916,7 @@
 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
 30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
 40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
-50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
+50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 58 00
 60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 91 41 00 00
 70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
 80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
@@ -962,7 +962,7 @@
 20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
 30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
 40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
-50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
+50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 58 00
 60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 99 41 00 00
 70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
 80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
