From: Satanand Burla <Satanand_Burla@phoenix.com>
Subject: tg3 does not recognize BCM57788
Date: Fri, 8 Jan 2010 13:11:42 -0800
Message-ID: <6D80BDFB1A1FA74DA476417C24C452A1025C06AF5B@scl-exch2k7.phoenix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "mcarlson@broadcom.com" <mcarlson@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scl-exch2k.phoenix.com ([134.122.225.253]:24579 "EHLO
	scl-exch2k.phoenix.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab0AHV0x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 16:26:53 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    I am trying to get BCM57788 (14e4:1691) device to work on an Intel board. I get the following error in my dmesg. I am trying with the latest tg3 driver from  net-next (http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git).

[56902.029119] tg3.c:v3.105 (December 2, 2009)
[56902.029128] tg3 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
[56902.029137] tg3 0000:01:00.0: setting latency timer to 64
[56902.032038] tg3 0000:01:00.0: PME# disabled
[56902.033051] tg3 mdio bus: probed
[56902.033052] eth%d: No PHY devices
[56902.033295] tg3: Problem fetching invariants of chip, aborting.
[56902.033381] tg3 0000:01:00.0: PCI INT A disable

It seems to be the same problem as reported here  https://bugzilla.redhat.com/show_bug.cgi?id=525966
Except that it is BCM57788. I tried to load the broadcom.ko module before tg3 but I still get the same error.

And here is the complete lspci -vvxxx of my Broadcom device


01:00.0 Ethernet controller: Broadcom Corporation Device 1691 (rev 01)
	Subsystem: Intel Corporation Device d620
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at e0600000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [60] Vendor Specific Information <?>
	Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Count=1/1 Enable-
		Address: 7b816074f6923efc  Data: 78c1
	Capabilities: [cc] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <1us, L1 <32us
			ClockPM+ Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [100] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSVoil-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVoil-
		CESta:	RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c] Virtual Channel <?>
	Capabilities: [160] Device Serial Number f3-2a-cc-fe-ff-c0-1c-00
	Capabilities: [16c] Power Budgeting <?>
	Kernel modules: tg3
00: e4 14 91 16 02 00 10 00 01 00 00 02 10 00 00 00
10: 04 00 60 e0 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 20 d6
30: 00 00 00 00 48 00 00 00 00 00 00 00 0b 01 00 00
40: 00 00 00 00 00 00 00 00 01 60 03 c0 08 20 00 08
50: 05 cc 80 00 fc 3e 92 f6 74 60 81 7b c1 78 00 00
60: 09 50 6c 00 2c e1 af ff 9a 00 01 f0 00 00 18 76
70: 72 10 00 00 00 00 00 00 20 70 00 00 00 00 00 00
80: 00 00 00 00 70 a4 b6 40 34 00 12 00 fe 50 08 20
90: 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 78 57
c0: 00 00 00 00 e4 14 91 16 0e 00 00 00 10 00 02 00
d0: a0 8f 00 00 00 50 10 00 11 cc 06 00 40 00 11 10
e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
f0: 1f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


Please let me know if any other info is needed or if there is anything I am missing or  any patches to try. I am not subscribed to netdev, so please be considerate to CC or mail the reply.

Regards,
Satanand.



