From: Adrian George Sav <adi_sav@yahoo.com>
Subject: Kernel driver r8169 not working for Realtek 8111E onboard network card
Date: Sat, 22 Oct 2011 08:22:21 -0700 (PDT)
Message-ID: <1319296941.68390.YahooMailNeo@web161905.mail.bf1.yahoo.com>
Reply-To: Adrian George Sav <adi_sav@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm37-vm7.bullet.mail.bf1.yahoo.com ([72.30.238.207]:24073 "HELO
	nm37-vm7.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753147Ab1JVP3E convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Oct 2011 11:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I am having trouble with the r8169 kernel driver for Realtek 8111E netw=
ork card.
The NIC works intermittently and horribly with this driver. Unusable.

Below is my config. I am happy to provide any and every other necessary=
 information to help in solving this.

Thank you.

Motherboard: ASUS P8P67(REV 3.1)

Kernel: up to 2.6.39

lspci -vv:
-----------------------------------------------------------------------=
-------------------------------------

07:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/81=
68B PCI Express Gigabit Ethernet controller (rev 06)
=A0=A0=A0=A0=A0=A0=A0 Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Mot=
herboard [Realtek RTL8111E]
=A0=A0=A0=A0=A0=A0=A0 Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV-=
 VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
=A0=A0=A0=A0=A0=A0=A0 Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3D=
fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
=A0=A0=A0=A0=A0=A0=A0 Latency: 0, Cache Line Size: 64 bytes
=A0=A0=A0=A0=A0=A0=A0 Interrupt: pin A routed to IRQ 66
=A0=A0=A0=A0=A0=A0=A0 Region 0: I/O ports at d000 [size=3D256]
=A0=A0=A0=A0=A0=A0=A0 Region 2: Memory at d0004000 (64-bit, prefetchabl=
e) [size=3D4K]
=A0=A0=A0=A0=A0=A0=A0 Region 4: Memory at d0000000 (64-bit, prefetchabl=
e) [size=3D16K]
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [40] Power Management version 3
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Flags: PMEClk- DSI- D1+ D=
2+ AuxCurrent=3D375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Status: D0 NoSoftRst+ PME=
-Enable- DSel=3D0 DScale=3D0 PME-
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [50] MSI: Enable+ Count=3D1/1 Maska=
ble- 64bit+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Address: 00000000feeff00c=
=A0 Data: 417a
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [70] Express (v2) Endpoint, MSI 01
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCap: MaxPayload 128 by=
tes, PhantFunc 0, Latency L0s <512ns, L1 <64us
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 E=
xtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCtl: Report errors: Co=
rrectable- Non-Fatal- Fatal- Unsupported-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 R=
lxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 M=
axPayload 128 bytes, MaxReadReq 4096 bytes
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevSta: CorrErr+ UncorrEr=
r- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkCap: Port #0, Speed 2.=
5GT/s, Width x1, ASPM L0s L1, Latency L0 unlimited, L1 <64us
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 C=
lockPM+ Surprise- LLActRep- BwNot-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkCtl: ASPM Disabled; RC=
B 64 bytes Disabled- Retrain- CommClk+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 E=
xtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkSta: Speed 2.5GT/s, Wi=
dth x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCap2: Completion Timeo=
ut: Range ABCD, TimeoutDis+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 DevCtl2: Completion Timeo=
ut: 50us to 50ms, TimeoutDis-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkCtl2: Target Link Spee=
d: 2.5GT/s, EnterCompliance- SpeedDis-, Selectable De-emphasis: -6dB
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- Comp=
lianceSOS-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 Compliance De-emphasis: -6dB
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 LnkSta2: Current De-empha=
sis Level: -6dB
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [b0] MSI-X: Enable- Count=3D4 Maske=
d-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Vector table: BAR=3D4 off=
set=3D00000000
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 PBA: BAR=3D4 offset=3D000=
00800
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [d0] Vital Product Data
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Unknown small resource ty=
pe 00, will not decode more.
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [100 v1] Advanced Error Reporting
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 UESta:=A0 DLP- SDES- TLP-=
 FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSV=
iol-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 UEMsk:=A0 DLP- SDES- TLP-=
 FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSV=
iol-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 UESvrt: DLP+ SDES+ TLP- F=
CP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSVio=
l-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 CESta:=A0 RxErr- BadTLP- =
BadDLLP- Rollover- Timeout- NonFatalErr+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 CEMsk:=A0 RxErr- BadTLP- =
BadDLLP- Rollover- Timeout- NonFatalErr+
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 AERCap: First Error Point=
er: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [140 v1] Virtual Channel
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Caps:=A0=A0 LPEVC=3D0 Ref=
Clk=3D100ns PATEntryBits=3D1
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Arb:=A0=A0=A0 Fixed- WRR3=
2- WRR64- WRR128-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Ctrl:=A0=A0 ArbSelect=3DF=
ixed
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Status: InProgress-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 VC0:=A0=A0=A0 Caps:=A0=A0=
 PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 A=
rb:=A0=A0=A0 Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 C=
trl:=A0=A0 Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 S=
tatus: NegoPending- InProgress-
=A0=A0=A0=A0=A0=A0=A0 Capabilities: [160 v1] Device Serial Number 01-00=
-00-00-68-4c-e0-00
=A0=A0=A0=A0=A0=A0=A0 Kernel driver in use: r8169
=A0=A0=A0=A0=A0=A0=A0 Kernel modules: r8169
-----------------------------------------------------------------------=
-------------------------------------
