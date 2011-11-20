From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] Add ethtool to mii advertisment conversion helpers
Date: Sun, 20 Nov 2011 22:11:37 +0100
Message-ID: <1321823497.4984.4.camel@edumazet-laptop>
References: <1321486057-30968-1-git-send-email-mcarlson@broadcom.com>
	 <20111116.184032.1176336205445892405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47021 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753532Ab1KTVLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 16:11:43 -0500
Received: by wwe5 with SMTP id 5so9159136wwe.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 13:11:41 -0800 (PST)
In-Reply-To: <20111116.184032.1176336205445892405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 novembre 2011 =C3=A0 18:40 -0500, David Miller a =C3=A9c=
rit :
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Wed, 16 Nov 2011 15:27:37 -0800
>=20
> > Translating between ethtool advertisement settings and MII
> > advertisements are common operations for ethernet drivers.  This pa=
tch
> > adds a set of helper functions that implements the conversion.  The
> > patch then modifies a couple of the drivers to use the new function=
s.
> >=20
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
>=20
> Looks better, applied, thanks :)

=46or an unknown reason I had to revert this commit to make my tg3 work=
ing
again on my laptop connected with a cross cable to one IGB NIC.

Before my revert, link was constantly flapping

(Should be running at 1000Mbps, full duplex)

09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5755M Gi=
gabit Ethernet PCI Express (rev 02)
	Subsystem: Dell Device 01f9
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- St=
epping- SERR+ FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast >TAbort- <TAbo=
rt- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 45
	Region 0: Memory at f1ef0000 (64-bit, non-prefetchable) [size=3D64K]
	Expansion ROM at <ignored> [disabled]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA PME(D0-,D1-,D2-,D3hot+,D=
3cold+)
		Status: D0 NoSoftRst+ PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data
		Product Name: Broadcom NetXtreme Gigabit Ethernet Controller
		Read-only fields:
			[PN] Part number: BCM95755m
			[EC] Engineering changes: 01f9.004
			[SN] Serial number: 0123456789
			[MN] Manufacture ID: 31 34 65 34
			[RV] Reserved: checksum good, 28 byte(s) reserved
		Read/write fields:
			[YA] Asset tag: XYZ01234567
			[RW] Read-write area: 107 byte(s) free
		End
	Capabilities: [58] Vendor Specific Information: Len=3D78 <?>
	Capabilities: [e8] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
		Address: 00000000fee0300c  Data: 41b1
	Capabilities: [d0] Express (v1) Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s <4us, L1 unlim=
ited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 4096 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
		LnkCap:	Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <4u=
s, L1 <64us
			ClockPM+ Surprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s Enabled; RCB 64 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWM=
gmt- ABWMgmt-
	Capabilities: [100 v1] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO+ CmpltAbrt- UnxCmplt- RxOF- MalfT=
LP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfT=
LP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ Malf=
TLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout+ NonFatalErr+
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
		AERCap:	First Error Pointer: 0e, GenCap+ CGenEn- ChkCap+ ChkEn-
	Capabilities: [13c v1] Virtual Channel
		Caps:	LPEVC=3D0 RefClk=3D100ns PATEntryBits=3D1
		Arb:	Fixed- WRR32- WRR64- WRR128-
		Ctrl:	ArbSelect=3DFixed
		Status:	InProgress-
		VC0:	Caps:	PATOffset=3D00 MaxTimeSlots=3D1 RejSnoopTrans-
			Arb:	Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
			Ctrl:	Enable+ ID=3D0 ArbSelect=3DFixed TC/VC=3D01
			Status:	NegoPending- InProgress-
	Capabilities: [160 v1] Device Serial Number 00-21-70-ff-fe-b0-e4-89
	Capabilities: [16c v1] Power Budgeting <?>
	Kernel driver in use: tg3
	Kernel modules: tg3


=46or reference, the revert on tg3 :

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index 024ca1d..365cd47 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3594,7 +3594,15 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u=
32 advertise, u32 flowctrl)
 	u32 val, new_adv;
=20
 	new_adv =3D ADVERTISE_CSMA;
-	new_adv |=3D ethtool_adv_to_mii_100bt(advertise);
+	if (advertise & ADVERTISED_10baseT_Half)
+		new_adv |=3D ADVERTISE_10HALF;
+	if (advertise & ADVERTISED_10baseT_Full)
+		new_adv |=3D ADVERTISE_10FULL;
+	if (advertise & ADVERTISED_100baseT_Half)
+		new_adv |=3D ADVERTISE_100HALF;
+	if (advertise & ADVERTISED_100baseT_Full)
+		new_adv |=3D ADVERTISE_100FULL;
+
 	new_adv |=3D tg3_advert_flowctrl_1000T(flowctrl);
=20
 	err =3D tg3_writephy(tp, MII_ADVERTISE, new_adv);
@@ -3604,7 +3612,11 @@ static int tg3_phy_autoneg_cfg(struct tg3 *tp, u=
32 advertise, u32 flowctrl)
 	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
 		goto done;
=20
-	new_adv =3D ethtool_adv_to_mii_1000T(advertise);
+	new_adv =3D 0;
+	if (advertise & ADVERTISED_1000baseT_Half)
+		new_adv |=3D ADVERTISE_1000HALF;
+	if (advertise & ADVERTISED_1000baseT_Full)
+		new_adv |=3D ADVERTISE_1000FULL;
=20
 	if (tp->pci_chip_rev_id =3D=3D CHIPREV_ID_5701_A0 ||
 	    tp->pci_chip_rev_id =3D=3D CHIPREV_ID_5701_B0)
@@ -3778,7 +3790,14 @@ static int tg3_copper_is_advertising_all(struct =
tg3 *tp, u32 mask)
 {
 	u32 adv_reg, all_mask =3D 0;
=20
-	all_mask =3D ethtool_adv_to_mii_100bt(mask);
+	if (mask & ADVERTISED_10baseT_Half)
+		all_mask |=3D ADVERTISE_10HALF;
+	if (mask & ADVERTISED_10baseT_Full)
+		all_mask |=3D ADVERTISE_10FULL;
+	if (mask & ADVERTISED_100baseT_Half)
+		all_mask |=3D ADVERTISE_100HALF;
+	if (mask & ADVERTISED_100baseT_Full)
+		all_mask |=3D ADVERTISE_100FULL;
=20
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
@@ -3789,7 +3808,11 @@ static int tg3_copper_is_advertising_all(struct =
tg3 *tp, u32 mask)
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
 		u32 tg3_ctrl;
=20
-		all_mask =3D ethtool_adv_to_mii_1000T(mask);
+		all_mask =3D 0;
+		if (mask & ADVERTISED_1000baseT_Half)
+			all_mask |=3D ADVERTISE_1000HALF;
+		if (mask & ADVERTISED_1000baseT_Full)
+			all_mask |=3D ADVERTISE_1000FULL;
=20
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
 			return 0;
@@ -4880,19 +4903,23 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *=
tp, int force_reset)
 	    (tp->phy_flags & TG3_PHYFLG_PARALLEL_DETECT)) {
 		/* do nothing, just check for link up at the end */
 	} else if (tp->link_config.autoneg =3D=3D AUTONEG_ENABLE) {
-		u32 adv, newadv;
+		u32 adv, new_adv;
=20
 		err |=3D tg3_readphy(tp, MII_ADVERTISE, &adv);
-		newadv =3D adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
-				 ADVERTISE_1000XPAUSE |
-				 ADVERTISE_1000XPSE_ASYM |
-				 ADVERTISE_SLCT);
+		new_adv =3D adv & ~(ADVERTISE_1000XFULL | ADVERTISE_1000XHALF |
+				  ADVERTISE_1000XPAUSE |
+				  ADVERTISE_1000XPSE_ASYM |
+				  ADVERTISE_SLCT);
+
+		new_adv |=3D tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
=20
-		newadv |=3D tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
-		newadv |=3D ethtool_adv_to_mii_1000X(tp->link_config.advertising);
+		if (tp->link_config.advertising & ADVERTISED_1000baseT_Half)
+			new_adv |=3D ADVERTISE_1000XHALF;
+		if (tp->link_config.advertising & ADVERTISED_1000baseT_Full)
+			new_adv |=3D ADVERTISE_1000XFULL;
=20
-		if ((newadv !=3D adv) || !(bmcr & BMCR_ANENABLE)) {
-			tg3_writephy(tp, MII_ADVERTISE, newadv);
+		if ((new_adv !=3D adv) || !(bmcr & BMCR_ANENABLE)) {
+			tg3_writephy(tp, MII_ADVERTISE, new_adv);
 			bmcr |=3D BMCR_ANENABLE | BMCR_ANRESTART;
 			tg3_writephy(tp, MII_BMCR, bmcr);
=20
