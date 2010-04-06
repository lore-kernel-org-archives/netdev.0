From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next] via-velocity: remove private #define
Date: Tue, 6 Apr 2010 22:58:10 +0200
Message-ID: <20100406205810.GA8077@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Simon Kagstrom <simon.kagstrom@netinsight.net>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	=?iso-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:57836 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753744Ab0DFU7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 16:59:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Registers and their bits from mii.h. Courtesy from ed.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/via-velocity.c |  114 ++++++++++++++++++++++----------------------
 drivers/net/via-velocity.h |   77 +----------------------------
 2 files changed, 60 insertions(+), 131 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 91f3b84..078903f 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -719,30 +719,30 @@ static u32 mii_check_media_mode(struct mac_regs __iomem *regs)
 	u32 status = 0;
 	u16 ANAR;
 
-	if (!MII_REG_BITS_IS_ON(BMSR_LNK, MII_REG_BMSR, regs))
+	if (!MII_REG_BITS_IS_ON(BMSR_LSTATUS, MII_BMSR, regs))
 		status |= VELOCITY_LINK_FAIL;
 
-	if (MII_REG_BITS_IS_ON(G1000CR_1000FD, MII_REG_G1000CR, regs))
+	if (MII_REG_BITS_IS_ON(ADVERTISE_1000FULL, MII_CTRL1000, regs))
 		status |= VELOCITY_SPEED_1000 | VELOCITY_DUPLEX_FULL;
-	else if (MII_REG_BITS_IS_ON(G1000CR_1000, MII_REG_G1000CR, regs))
+	else if (MII_REG_BITS_IS_ON(ADVERTISE_1000HALF, MII_CTRL1000, regs))
 		status |= (VELOCITY_SPEED_1000);
 	else {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if (ANAR & ANAR_TXFD)
+		velocity_mii_read(regs, MII_ADVERTISE, &ANAR);
+		if (ANAR & ADVERTISE_100FULL)
 			status |= (VELOCITY_SPEED_100 | VELOCITY_DUPLEX_FULL);
-		else if (ANAR & ANAR_TX)
+		else if (ANAR & ADVERTISE_100HALF)
 			status |= VELOCITY_SPEED_100;
-		else if (ANAR & ANAR_10FD)
+		else if (ANAR & ADVERTISE_10FULL)
 			status |= (VELOCITY_SPEED_10 | VELOCITY_DUPLEX_FULL);
 		else
 			status |= (VELOCITY_SPEED_10);
 	}
 
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
-		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
-			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
+	if (MII_REG_BITS_IS_ON(BMCR_ANENABLE, MII_BMCR, regs)) {
+		velocity_mii_read(regs, MII_ADVERTISE, &ANAR);
+		if ((ANAR & (ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF))
+		    == (ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF)) {
+			if (MII_REG_BITS_IS_ON(ADVERTISE_1000HALF | ADVERTISE_1000FULL, MII_CTRL1000, regs))
 				status |= VELOCITY_AUTONEG_ENABLE;
 		}
 	}
@@ -801,23 +801,23 @@ static void set_mii_flow_control(struct velocity_info *vptr)
 	/*Enable or Disable PAUSE in ANAR */
 	switch (vptr->options.flow_cntl) {
 	case FLOW_CNTL_TX:
-		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ADVERTISE_PAUSE_CAP, MII_ADVERTISE, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
 		break;
 
 	case FLOW_CNTL_RX:
-		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_PAUSE_CAP, MII_ADVERTISE, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
 		break;
 
 	case FLOW_CNTL_TX_RX:
-		MII_REG_BITS_ON(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_PAUSE_CAP, MII_ADVERTISE, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
 		break;
 
 	case FLOW_CNTL_DISABLE:
-		MII_REG_BITS_OFF(ANAR_PAUSE, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_OFF(ANAR_ASMDIR, MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ADVERTISE_PAUSE_CAP, MII_ADVERTISE, vptr->mac_regs);
+		MII_REG_BITS_OFF(ADVERTISE_PAUSE_ASYM, MII_ADVERTISE, vptr->mac_regs);
 		break;
 	default:
 		break;
@@ -832,10 +832,10 @@ static void set_mii_flow_control(struct velocity_info *vptr)
  */
 static void mii_set_auto_on(struct velocity_info *vptr)
 {
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs))
-		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
+	if (MII_REG_BITS_IS_ON(BMCR_ANENABLE, MII_BMCR, vptr->mac_regs))
+		MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
 	else
-		MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs);
+		MII_REG_BITS_ON(BMCR_ANENABLE, MII_BMCR, vptr->mac_regs);
 }
 
 static u32 check_connection_type(struct mac_regs __iomem *regs)
@@ -860,11 +860,11 @@ static u32 check_connection_type(struct mac_regs __iomem *regs)
 	else
 		status |= VELOCITY_SPEED_100;
 
-	if (MII_REG_BITS_IS_ON(BMCR_AUTO, MII_REG_BMCR, regs)) {
-		velocity_mii_read(regs, MII_REG_ANAR, &ANAR);
-		if ((ANAR & (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10))
-		    == (ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10)) {
-			if (MII_REG_BITS_IS_ON(G1000CR_1000 | G1000CR_1000FD, MII_REG_G1000CR, regs))
+	if (MII_REG_BITS_IS_ON(BMCR_ANENABLE, MII_BMCR, regs)) {
+		velocity_mii_read(regs, MII_ADVERTISE, &ANAR);
+		if ((ANAR & (ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF))
+		    == (ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF)) {
+			if (MII_REG_BITS_IS_ON(ADVERTISE_1000HALF | ADVERTISE_1000FULL, MII_CTRL1000, regs))
 				status |= VELOCITY_AUTONEG_ENABLE;
 		}
 	}
@@ -905,7 +905,7 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 	 */
 
 	if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-		MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
+		MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
 
 	/*
 	 *	If connection type is AUTO
@@ -915,9 +915,9 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 		/* clear force MAC mode bit */
 		BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
 		/* set duplex mode of MAC according to duplex mode of MII */
-		MII_REG_BITS_ON(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10, MII_REG_ANAR, vptr->mac_regs);
-		MII_REG_BITS_ON(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
-		MII_REG_BITS_ON(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF, MII_ADVERTISE, vptr->mac_regs);
+		MII_REG_BITS_ON(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
+		MII_REG_BITS_ON(BMCR_SPEED1000, MII_BMCR, vptr->mac_regs);
 
 		/* enable AUTO-NEGO mode */
 		mii_set_auto_on(vptr);
@@ -952,31 +952,31 @@ static int velocity_set_media_mode(struct velocity_info *vptr, u32 mii_status)
 				BYTE_REG_BITS_ON(TCR_TB2BDIS, &regs->TCR);
 		}
 
-		MII_REG_BITS_OFF(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
 
 		if (!(mii_status & VELOCITY_DUPLEX_FULL) && (mii_status & VELOCITY_SPEED_10))
 			BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
 		else
 			BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
 
-		/* MII_REG_BITS_OFF(BMCR_SPEED1G, MII_REG_BMCR, vptr->mac_regs); */
-		velocity_mii_read(vptr->mac_regs, MII_REG_ANAR, &ANAR);
-		ANAR &= (~(ANAR_TXFD | ANAR_TX | ANAR_10FD | ANAR_10));
+		/* MII_REG_BITS_OFF(BMCR_SPEED1000, MII_BMCR, vptr->mac_regs); */
+		velocity_mii_read(vptr->mac_regs, MII_ADVERTISE, &ANAR);
+		ANAR &= (~(ADVERTISE_100FULL | ADVERTISE_100HALF | ADVERTISE_10FULL | ADVERTISE_10HALF));
 		if (mii_status & VELOCITY_SPEED_100) {
 			if (mii_status & VELOCITY_DUPLEX_FULL)
-				ANAR |= ANAR_TXFD;
+				ANAR |= ADVERTISE_100FULL;
 			else
-				ANAR |= ANAR_TX;
+				ANAR |= ADVERTISE_100HALF;
 		} else {
 			if (mii_status & VELOCITY_DUPLEX_FULL)
-				ANAR |= ANAR_10FD;
+				ANAR |= ADVERTISE_10FULL;
 			else
-				ANAR |= ANAR_10;
+				ANAR |= ADVERTISE_10HALF;
 		}
-		velocity_mii_write(vptr->mac_regs, MII_REG_ANAR, ANAR);
+		velocity_mii_write(vptr->mac_regs, MII_ADVERTISE, ANAR);
 		/* enable AUTO-NEGO mode */
 		mii_set_auto_on(vptr);
-		/* MII_REG_BITS_ON(BMCR_AUTO, MII_REG_BMCR, vptr->mac_regs); */
+		/* MII_REG_BITS_ON(BMCR_ANENABLE, MII_BMCR, vptr->mac_regs); */
 	}
 	/* vptr->mii_status=mii_check_media_mode(vptr->mac_regs); */
 	/* vptr->mii_status=check_connection_type(vptr->mac_regs); */
@@ -1178,36 +1178,36 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 		/*
 		 *	Reset to hardware default
 		 */
-		MII_REG_BITS_OFF((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_OFF((ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP), MII_ADVERTISE, vptr->mac_regs);
 		/*
 		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
 		 *	off it in NWay-forced half mode for NWay-forced v.s.
 		 *	legacy-forced issue.
 		 */
 		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
-			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
 		else
-			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
 		/*
 		 *	Turn on Link/Activity LED enable bit for CIS8201
 		 */
-		MII_REG_BITS_ON(PLED_LALBE, MII_REG_PLED, vptr->mac_regs);
+		MII_REG_BITS_ON(PLED_LALBE, MII_TPISTATUS, vptr->mac_regs);
 		break;
 	case PHYID_VT3216_32BIT:
 	case PHYID_VT3216_64BIT:
 		/*
 		 *	Reset to hardware default
 		 */
-		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON((ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP), MII_ADVERTISE, vptr->mac_regs);
 		/*
 		 *	Turn on ECHODIS bit in NWay-forced full mode and turn it
 		 *	off it in NWay-forced half mode for NWay-forced v.s.
 		 *	legacy-forced issue
 		 */
 		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
-			MII_REG_BITS_ON(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
 		else
-			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_REG_TCSR, vptr->mac_regs);
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
 		break;
 
 	case PHYID_MARVELL_1000:
@@ -1219,15 +1219,15 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 		/*
 		 *	Reset to hardware default
 		 */
-		MII_REG_BITS_ON((ANAR_ASMDIR | ANAR_PAUSE), MII_REG_ANAR, vptr->mac_regs);
+		MII_REG_BITS_ON((ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP), MII_ADVERTISE, vptr->mac_regs);
 		break;
 	default:
 		;
 	}
-	velocity_mii_read(vptr->mac_regs, MII_REG_BMCR, &BMCR);
-	if (BMCR & BMCR_ISO) {
-		BMCR &= ~BMCR_ISO;
-		velocity_mii_write(vptr->mac_regs, MII_REG_BMCR, BMCR);
+	velocity_mii_read(vptr->mac_regs, MII_BMCR, &BMCR);
+	if (BMCR & BMCR_ISOLATE) {
+		BMCR &= ~BMCR_ISOLATE;
+		velocity_mii_write(vptr->mac_regs, MII_BMCR, BMCR);
 	}
 }
 
@@ -2953,13 +2953,13 @@ static int velocity_set_wol(struct velocity_info *vptr)
 
 	if (vptr->mii_status & VELOCITY_AUTONEG_ENABLE) {
 		if (PHYID_GET_PHY_ID(vptr->phy_id) == PHYID_CICADA_CS8201)
-			MII_REG_BITS_ON(AUXCR_MDPPS, MII_REG_AUXCR, vptr->mac_regs);
+			MII_REG_BITS_ON(AUXCR_MDPPS, MII_NCONFIG, vptr->mac_regs);
 
-		MII_REG_BITS_OFF(G1000CR_1000FD | G1000CR_1000, MII_REG_G1000CR, vptr->mac_regs);
+		MII_REG_BITS_OFF(ADVERTISE_1000FULL | ADVERTISE_1000HALF, MII_CTRL1000, vptr->mac_regs);
 	}
 
 	if (vptr->mii_status & VELOCITY_SPEED_1000)
-		MII_REG_BITS_ON(BMCR_REAUTO, MII_REG_BMCR, vptr->mac_regs);
+		MII_REG_BITS_ON(BMCR_ANRESTART, MII_BMCR, vptr->mac_regs);
 
 	BYTE_REG_BITS_ON(CHIPGCR_FCMODE, &regs->CHIPGCR);
 
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index ef4a0f6..c381911 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1240,86 +1240,16 @@ struct velocity_context {
 	u32 pattern[8];
 };
 
-
-/*
- *	MII registers.
- */
-
-
 /*
  *	Registers in the MII (offset unit is WORD)
  */
 
-#define MII_REG_BMCR        0x00	// physical address
-#define MII_REG_BMSR        0x01	//
-#define MII_REG_PHYID1      0x02	// OUI
-#define MII_REG_PHYID2      0x03	// OUI + Module ID + REV ID
-#define MII_REG_ANAR        0x04	//
-#define MII_REG_ANLPAR      0x05	//
-#define MII_REG_G1000CR     0x09	//
-#define MII_REG_G1000SR     0x0A	//
-#define MII_REG_MODCFG      0x10	//
-#define MII_REG_TCSR        0x16	//
-#define MII_REG_PLED        0x1B	//
-// NS, MYSON only
-#define MII_REG_PCR         0x17	//
-// ESI only
-#define MII_REG_PCSR        0x17	//
-#define MII_REG_AUXCR       0x1C	//
-
 // Marvell 88E1000/88E1000S
 #define MII_REG_PSCR        0x10	// PHY specific control register
 
 //
-// Bits in the BMCR register
-//
-#define BMCR_RESET          0x8000	//
-#define BMCR_LBK            0x4000	//
-#define BMCR_SPEED100       0x2000	//
-#define BMCR_AUTO           0x1000	//
-#define BMCR_PD             0x0800	//
-#define BMCR_ISO            0x0400	//
-#define BMCR_REAUTO         0x0200	//
-#define BMCR_FDX            0x0100	//
-#define BMCR_SPEED1G        0x0040	//
-//
-// Bits in the BMSR register
-//
-#define BMSR_AUTOCM         0x0020	//
-#define BMSR_LNK            0x0004	//
-
-//
-// Bits in the ANAR register
-//
-#define ANAR_ASMDIR         0x0800	// Asymmetric PAUSE support
-#define ANAR_PAUSE          0x0400	// Symmetric PAUSE Support
-#define ANAR_T4             0x0200	//
-#define ANAR_TXFD           0x0100	//
-#define ANAR_TX             0x0080	//
-#define ANAR_10FD           0x0040	//
-#define ANAR_10             0x0020	//
-//
-// Bits in the ANLPAR register
-//
-#define ANLPAR_ASMDIR       0x0800	// Asymmetric PAUSE support
-#define ANLPAR_PAUSE        0x0400	// Symmetric PAUSE Support
-#define ANLPAR_T4           0x0200	//
-#define ANLPAR_TXFD         0x0100	//
-#define ANLPAR_TX           0x0080	//
-#define ANLPAR_10FD         0x0040	//
-#define ANLPAR_10           0x0020	//
-
-//
-// Bits in the G1000CR register
-//
-#define G1000CR_1000FD      0x0200	// PHY is 1000-T Full-duplex capable
-#define G1000CR_1000        0x0100	// PHY is 1000-T Half-duplex capable
-
-//
-// Bits in the G1000SR register
+// Bits in the Silicon revision register
 //
-#define G1000SR_1000FD      0x0800	// LP PHY is 1000-T Full-duplex capable
-#define G1000SR_1000        0x0400	// LP PHY is 1000-T Half-duplex capable
 
 #define TCSR_ECHODIS        0x2000	//
 #define AUXCR_MDPPS         0x0004	//
@@ -1338,7 +1268,6 @@ struct velocity_context {
 
 #define PHYID_REV_ID_MASK   0x0000000FUL
 
-#define PHYID_GET_PHY_REV_ID(i)     ((i) & PHYID_REV_ID_MASK)
 #define PHYID_GET_PHY_ID(i)         ((i) & ~PHYID_REV_ID_MASK)
 
 #define MII_REG_BITS_ON(x,i,p) do {\
@@ -1362,8 +1291,8 @@ struct velocity_context {
 
 #define MII_GET_PHY_ID(p) ({\
     u32 id;\
-    velocity_mii_read((p),MII_REG_PHYID2,(u16 *) &id);\
-    velocity_mii_read((p),MII_REG_PHYID1,((u16 *) &id)+1);\
+    velocity_mii_read((p),MII_PHYSID2,(u16 *) &id);\
+    velocity_mii_read((p),MII_PHYSID1,((u16 *) &id)+1);\
     (id);})
 
 /*
-- 
1.6.6.1

