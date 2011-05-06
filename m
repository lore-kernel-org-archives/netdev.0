From: Tom Goetz <tom.goetz@virtualcomputer.com>
Subject: For the netdev list
Date: Fri, 6 May 2011 12:57:47 -0400
Message-ID: <14130884-5927-4B8D-A52E-56C245D8225B@virtualcomputer.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: multipart/mixed; boundary=Apple-Mail-149--23646641
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server514d.exghost.com ([72.32.253.69]:2093 "EHLO
	server514.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932126Ab1EFRH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 13:07:57 -0400
Received: from [72.32.253.140] (HELO FE01.exg4.exghost.com)
  by server514.appriver.com (CommuniGate Pro SMTP 5.3.2)
  with ESMTP id 159231756 for netdev@vger.kernel.org; Fri, 06 May 2011 11:57:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-149--23646641
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

We recently obtained a new a Lenovo Edge 0578-CTO. The r8169 driver =
causes instability in the system on this machine. The problem is that in =
rtl8169_rx_interrupt (status & 0x00001FFF) returns values less than four =
on this machine. This results in this line:

int pkt_size =3D (status & 0x00001FFF) - 4;

giving a huge packet size which causes problem when the packet is =
copied. For a work around we've added a patch to drop packets when we =
see this condition. I have attached lspci -vvv for this device and a =
patch for the work around we're using.

-Tom Goetz



--Apple-Mail-149--23646641
Content-Disposition: attachment;
	filename=r8168_lspci.log
Content-Type: application/octet-stream;
	name="r8168_lspci.log"
Content-Transfer-Encoding: 7bit

09:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 03)
	Subsystem: Lenovo Device 2131
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 299
	Region 0: I/O ports at 4000 [size=256]
	Region 2: Memory at f0904000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at f0900000 (64-bit, prefetchable) [size=16K]
	[virtual] Expansion ROM at f0920000 [disabled] [size=128K]
	Capabilities: [40] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee0200c  Data: 41c8
	Capabilities: [70] Express (v2) Endpoint, MSI 01
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <512ns, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
		LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance De-emphasis: -6dB
		LnkSta2: Current De-emphasis Level: -6dB
	Capabilities: [ac] MSI-X: Enable- Count=4 Masked-
		Vector table: BAR=4 offset=00000000
		PBA: BAR=4 offset=00000800
	Capabilities: [cc] Vital Product Data
		Unknown small resource type 00, will not decode more.
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [140 v1] Virtual Channel
		Caps:	LPEVC=0 RefClk=100ns PATEntryBits=1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=Fixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number d4-00-00-00-68-4c-e0-00
	Kernel driver in use: r8169
	Kernel modules: r8169


--Apple-Mail-149--23646641
Content-Disposition: attachment;
	filename=rtl8169.patch
Content-Type: application/octet-stream;
	name="rtl8169.patch"
Content-Transfer-Encoding: 7bit

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7ffdb80..4c8ad2a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4579,6 +4579,14 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
 
+			if ((status & 0x00001FFF) < 4) {
+				dev->stats.rx_dropped++;
+				dev->stats.rx_length_errors++;
+				rtl8169_mark_to_asic(desc, rx_buf_sz);
+				printk("%s: bad packet length!\n", __FUNCTION__);
+				continue;
+			}
+
 			/*
 			 * The driver does not support incoming fragmented
 			 * frames. They are seen as a symptom of over-mtu

--Apple-Mail-149--23646641--
