From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BNX2]: Fix driver software flag namespace.
Date: Mon, 21 Jan 2008 19:00:20 -0800
Message-ID: <1200970820.10010.58.camel@dell>
References: <20080121.171755.250146056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4314 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754998AbYAVCMw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 21:12:52 -0500
In-Reply-To: <20080121.171755.250146056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-21 at 17:17 -0800, David Miller wrote:
> Michael, I noticed the following while checking in your patches today.
> 
> I've checked this into net-2.6.25
> 
> [BNX2]: Fix driver software flag namespace.
> 
> Prefix "bnx2->flags" names with BNX2_* for consistency.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 

Thanks.  Here's a follow-up patch to fix the phy_flags namespace.

[BNX2]: Fix driver phy_flags name space.

Prefix "bp->phy_flags" names with BNX2_PHY_FLAG_* for consistency.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cb90457..506358a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -296,7 +296,7 @@ bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 	u32 val1;
 	int i, ret;
 
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
 		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 &= ~BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
@@ -334,7 +334,7 @@ bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 		ret = 0;
 	}
 
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
 		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 |= BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
@@ -353,7 +353,7 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 	u32 val1;
 	int i, ret;
 
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
 		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 &= ~BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
@@ -383,7 +383,7 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 	else
 		ret = 0;
 
-	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
 		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 |= BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
@@ -634,7 +634,7 @@ bnx2_report_fw_link(struct bnx2 *bp)
 {
 	u32 fw_link_status = 0;
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		return;
 
 	if (bp->link_up) {
@@ -676,7 +676,7 @@ bnx2_report_fw_link(struct bnx2 *bp)
 			bnx2_read_phy(bp, bp->mii_bmsr, &bmsr);
 
 			if (!(bmsr & BMSR_ANEGCOMPLETE) ||
-			    bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)
+			    bp->phy_flags & BNX2_PHY_FLAG_PARALLEL_DETECT)
 				fw_link_status |= BNX2_LINK_STATUS_PARALLEL_DET;
 			else
 				fw_link_status |= BNX2_LINK_STATUS_AN_COMPLETE;
@@ -692,7 +692,7 @@ static char *
 bnx2_xceiver_str(struct bnx2 *bp)
 {
 	return ((bp->phy_port == PORT_FIBRE) ? "SerDes" :
-		((bp->phy_flags & PHY_SERDES_FLAG) ? "Remote Copper" :
+		((bp->phy_flags & BNX2_PHY_FLAG_SERDES) ? "Remote Copper" :
 		 "Copper"));
 }
 
@@ -752,7 +752,7 @@ bnx2_resolve_flow_ctrl(struct bnx2 *bp)
 		return;
 	}
 
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5708)) {
 		u32 val;
 
@@ -767,7 +767,7 @@ bnx2_resolve_flow_ctrl(struct bnx2 *bp)
 	bnx2_read_phy(bp, bp->mii_adv, &local_adv);
 	bnx2_read_phy(bp, bp->mii_lpa, &remote_adv);
 
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		u32 new_local_adv = 0;
 		u32 new_remote_adv = 0;
 
@@ -1050,7 +1050,7 @@ bnx2_set_mac_link(struct bnx2 *bp)
 static void
 bnx2_enable_bmsr1(struct bnx2 *bp)
 {
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5709))
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_GP_STATUS);
@@ -1059,7 +1059,7 @@ bnx2_enable_bmsr1(struct bnx2 *bp)
 static void
 bnx2_disable_bmsr1(struct bnx2 *bp)
 {
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5709))
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
@@ -1071,7 +1071,7 @@ bnx2_test_and_enable_2g5(struct bnx2 *bp)
 	u32 up1;
 	int ret = 1;
 
-	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return 0;
 
 	if (bp->autoneg & AUTONEG_SPEED)
@@ -1100,7 +1100,7 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 	u32 up1;
 	int ret = 0;
 
-	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return 0;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
@@ -1125,7 +1125,7 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 {
 	u32 bmcr;
 
-	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
@@ -1160,7 +1160,7 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 {
 	u32 bmcr;
 
-	if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
@@ -1210,7 +1210,7 @@ bnx2_set_link(struct bnx2 *bp)
 		return 0;
 	}
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		return 0;
 
 	link_up = bp->link_up;
@@ -1220,13 +1220,13 @@ bnx2_set_link(struct bnx2 *bp)
 	bnx2_read_phy(bp, bp->mii_bmsr1, &bmsr);
 	bnx2_disable_bmsr1(bp);
 
-	if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
 		u32 val;
 
-		if (bp->phy_flags & PHY_FORCED_DOWN_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN) {
 			bnx2_5706s_force_link_dn(bp, 0);
-			bp->phy_flags &= ~PHY_FORCED_DOWN_FLAG;
+			bp->phy_flags &= ~BNX2_PHY_FLAG_FORCED_DOWN;
 		}
 		val = REG_RD(bp, BNX2_EMAC_STATUS);
 		if (val & BNX2_EMAC_STATUS_LINK)
@@ -1238,7 +1238,7 @@ bnx2_set_link(struct bnx2 *bp)
 	if (bmsr & BMSR_LSTATUS) {
 		bp->link_up = 1;
 
-		if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 			if (CHIP_NUM(bp) == CHIP_NUM_5706)
 				bnx2_5706s_linkup(bp);
 			else if (CHIP_NUM(bp) == CHIP_NUM_5708)
@@ -1252,18 +1252,18 @@ bnx2_set_link(struct bnx2 *bp)
 		bnx2_resolve_flow_ctrl(bp);
 	}
 	else {
-		if ((bp->phy_flags & PHY_SERDES_FLAG) &&
+		if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
 		    (bp->autoneg & AUTONEG_SPEED))
 			bnx2_disable_forced_2g5(bp);
 
-		if (bp->phy_flags & PHY_PARALLEL_DETECT_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_PARALLEL_DETECT) {
 			u32 bmcr;
 
 			bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 			bmcr |= BMCR_ANENABLE;
 			bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
 
-			bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+			bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 		}
 		bp->link_up = 0;
 	}
@@ -1309,7 +1309,7 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 	if ((bp->req_flow_ctrl & (FLOW_CTRL_RX | FLOW_CTRL_TX)) ==
 		(FLOW_CTRL_RX | FLOW_CTRL_TX)) {
 
-		if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 			adv = ADVERTISE_1000XPAUSE;
 		}
 		else {
@@ -1317,7 +1317,7 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 		}
 	}
 	else if (bp->req_flow_ctrl & FLOW_CTRL_TX) {
-		if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 			adv = ADVERTISE_1000XPSE_ASYM;
 		}
 		else {
@@ -1325,7 +1325,7 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 		}
 	}
 	else if (bp->req_flow_ctrl & FLOW_CTRL_RX) {
-		if (bp->phy_flags & PHY_SERDES_FLAG) {
+		if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 			adv = ADVERTISE_1000XPAUSE | ADVERTISE_1000XPSE_ASYM;
 		}
 		else {
@@ -1400,7 +1400,7 @@ bnx2_setup_serdes_phy(struct bnx2 *bp, u8 port)
 	u32 adv, bmcr;
 	u32 new_adv = 0;
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		return (bnx2_setup_remote_phy(bp, port));
 
 	if (!(bp->autoneg & AUTONEG_SPEED)) {
@@ -1510,7 +1510,7 @@ bnx2_setup_serdes_phy(struct bnx2 *bp, u8 port)
 }
 
 #define ETHTOOL_ALL_FIBRE_SPEED						\
-	(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) ?			\
+	(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE) ?			\
 		(ADVERTISED_2500baseX_Full | ADVERTISED_1000baseT_Full) :\
 		(ADVERTISED_1000baseT_Full)
 
@@ -1574,12 +1574,12 @@ bnx2_set_default_remote_link(struct bnx2 *bp)
 static void
 bnx2_set_default_link(struct bnx2 *bp)
 {
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		return bnx2_set_default_remote_link(bp);
 
 	bp->autoneg = AUTONEG_SPEED | AUTONEG_FLOW_CTRL;
 	bp->req_line_speed = 0;
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		u32 reg;
 
 		bp->advertising = ETHTOOL_ALL_FIBRE_SPEED | ADVERTISED_Autoneg;
@@ -1809,7 +1809,7 @@ bnx2_setup_phy(struct bnx2 *bp, u8 port)
 	if (bp->loopback == MAC_LOOPBACK)
 		return 0;
 
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		return (bnx2_setup_serdes_phy(bp, port));
 	}
 	else {
@@ -1844,7 +1844,7 @@ bnx2_init_5709s_phy(struct bnx2 *bp)
 
 	bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
 	bnx2_read_phy(bp, MII_BNX2_OVER1G_UP1, &val);
-	if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE)
 		val |= BCM5708S_UP1_2G5;
 	else
 		val &= ~BCM5708S_UP1_2G5;
@@ -1887,7 +1887,7 @@ bnx2_init_5708s_phy(struct bnx2 *bp)
 	val |= BCM5708S_1000X_CTL2_PLLEL_DET_EN;
 	bnx2_write_phy(bp, BCM5708S_1000X_CTL2, val);
 
-	if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE) {
 		bnx2_read_phy(bp, BCM5708S_UP1, &val);
 		val |= BCM5708S_UP1_2G5;
 		bnx2_write_phy(bp, BCM5708S_UP1, val);
@@ -1929,7 +1929,7 @@ bnx2_init_5706s_phy(struct bnx2 *bp)
 {
 	bnx2_reset_phy(bp);
 
-	bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+	bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5706)
         	REG_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
@@ -1968,7 +1968,7 @@ bnx2_init_copper_phy(struct bnx2 *bp)
 
 	bnx2_reset_phy(bp);
 
-	if (bp->phy_flags & PHY_CRC_FIX_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_CRC_FIX) {
 		bnx2_write_phy(bp, 0x18, 0x0c00);
 		bnx2_write_phy(bp, 0x17, 0x000a);
 		bnx2_write_phy(bp, 0x15, 0x310b);
@@ -1979,7 +1979,7 @@ bnx2_init_copper_phy(struct bnx2 *bp)
 		bnx2_write_phy(bp, 0x18, 0x0400);
 	}
 
-	if (bp->phy_flags & PHY_DIS_EARLY_DAC_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_DIS_EARLY_DAC) {
 		bnx2_write_phy(bp, MII_BNX2_DSP_ADDRESS,
 			       MII_BNX2_DSP_EXPAND_REG | 0x8);
 		bnx2_read_phy(bp, MII_BNX2_DSP_RW_PORT, &val);
@@ -2019,8 +2019,8 @@ bnx2_init_phy(struct bnx2 *bp)
 	u32 val;
 	int rc = 0;
 
-	bp->phy_flags &= ~PHY_INT_MODE_MASK_FLAG;
-	bp->phy_flags |= PHY_INT_MODE_LINK_READY_FLAG;
+	bp->phy_flags &= ~BNX2_PHY_FLAG_INT_MODE_MASK;
+	bp->phy_flags |= BNX2_PHY_FLAG_INT_MODE_LINK_READY;
 
 	bp->mii_bmcr = MII_BMCR;
 	bp->mii_bmsr = MII_BMSR;
@@ -2030,7 +2030,7 @@ bnx2_init_phy(struct bnx2 *bp)
 
         REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		goto setup_phy;
 
 	bnx2_read_phy(bp, MII_PHYSID1, &val);
@@ -2038,7 +2038,7 @@ bnx2_init_phy(struct bnx2 *bp)
 	bnx2_read_phy(bp, MII_PHYSID2, &val);
 	bp->phy_id |= val & 0xffff;
 
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)
 			rc = bnx2_init_5706s_phy(bp);
 		else if (CHIP_NUM(bp) == CHIP_NUM_5708)
@@ -4140,8 +4140,8 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 {
 	u32 val;
 
-	bp->phy_flags &= ~REMOTE_PHY_CAP_FLAG;
-	if (!(bp->phy_flags & PHY_SERDES_FLAG))
+	bp->phy_flags &= ~BNX2_PHY_FLAG_REMOTE_PHY_CAP;
+	if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES))
 		return;
 
 	val = REG_RD_IND(bp, bp->shmem_base + BNX2_FW_CAP_MB);
@@ -4149,7 +4149,7 @@ bnx2_init_remote_phy(struct bnx2 *bp)
 		return;
 
 	if (val & BNX2_FW_CAP_REMOTE_PHY_CAPABLE) {
-		bp->phy_flags |= REMOTE_PHY_CAP_FLAG;
+		bp->phy_flags |= BNX2_PHY_FLAG_REMOTE_PHY_CAP;
 
 		val = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
 		if (val & BNX2_LINK_STATUS_SERDES_LINK)
@@ -4270,7 +4270,8 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	spin_lock_bh(&bp->phy_lock);
 	old_port = bp->phy_port;
 	bnx2_init_remote_phy(bp);
-	if ((bp->phy_flags & REMOTE_PHY_CAP_FLAG) && old_port != bp->phy_port)
+	if ((bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) &&
+	    old_port != bp->phy_port)
 		bnx2_set_default_remote_link(bp);
 	spin_unlock_bh(&bp->phy_lock);
 
@@ -5083,7 +5084,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		bnx2_set_mac_loopback(bp);
 	}
 	else if (loopback_mode == BNX2_PHY_LOOPBACK) {
-		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 			return 0;
 
 		bp->loopback = PHY_LOOPBACK;
@@ -5253,7 +5254,7 @@ bnx2_test_link(struct bnx2 *bp)
 {
 	u32 bmsr;
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) {
 		if (bp->link_up)
 			return 0;
 		return -ENODEV;
@@ -5335,9 +5336,9 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 	int check_link = 1;
 
 	spin_lock(&bp->phy_lock);
-	if (bp->phy_flags & PHY_FORCED_DOWN_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN) {
 		bnx2_5706s_force_link_dn(bp, 0);
-		bp->phy_flags &= ~PHY_FORCED_DOWN_FLAG;
+		bp->phy_flags &= ~BNX2_PHY_FLAG_FORCED_DOWN;
 		spin_unlock(&bp->phy_lock);
 		return;
 	}
@@ -5357,12 +5358,12 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 				bmcr &= ~BMCR_ANENABLE;
 				bmcr |= BMCR_SPEED1000 | BMCR_FULLDPLX;
 				bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
-				bp->phy_flags |= PHY_PARALLEL_DETECT_FLAG;
+				bp->phy_flags |= BNX2_PHY_FLAG_PARALLEL_DETECT;
 			}
 		}
 	}
 	else if ((bp->link_up) && (bp->autoneg & AUTONEG_SPEED) &&
-		 (bp->phy_flags & PHY_PARALLEL_DETECT_FLAG)) {
+		 (bp->phy_flags & BNX2_PHY_FLAG_PARALLEL_DETECT)) {
 		u32 phy2;
 
 		check_link = 0;
@@ -5375,7 +5376,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 			bmcr |= BMCR_ANENABLE;
 			bnx2_write_phy(bp, bp->mii_bmcr, bmcr);
 
-			bp->phy_flags &= ~PHY_PARALLEL_DETECT_FLAG;
+			bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 		}
 	} else
 		bp->current_interval = bp->timer_interval;
@@ -5389,7 +5390,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 
 		if (val & MISC_SHDW_AN_DBG_NOSYNC) {
 			bnx2_5706s_force_link_dn(bp, 1);
-			bp->phy_flags |= PHY_FORCED_DOWN_FLAG;
+			bp->phy_flags |= BNX2_PHY_FLAG_FORCED_DOWN;
 		}
 	}
 	spin_unlock(&bp->phy_lock);
@@ -5398,10 +5399,10 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 static void
 bnx2_5708_serdes_timer(struct bnx2 *bp)
 {
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		return;
 
-	if ((bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) == 0) {
+	if ((bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE) == 0) {
 		bp->serdes_an_pending = 0;
 		return;
 	}
@@ -5448,7 +5449,7 @@ bnx2_timer(unsigned long data)
 		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
 					    BNX2_HC_COMMAND_STATS_NOW);
 
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)
 			bnx2_5706_serdes_timer(bp);
 		else
@@ -5962,7 +5963,7 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int support_serdes = 0, support_copper = 0;
 
 	cmd->supported = SUPPORTED_Autoneg;
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) {
 		support_serdes = 1;
 		support_copper = 1;
 	} else if (bp->phy_port == PORT_FIBRE)
@@ -5973,7 +5974,7 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (support_serdes) {
 		cmd->supported |= SUPPORTED_1000baseT_Full |
 			SUPPORTED_FIBRE;
-		if (bp->phy_flags & PHY_2_5G_CAPABLE_FLAG)
+		if (bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE)
 			cmd->supported |= SUPPORTED_2500baseX_Full;
 
 	}
@@ -6029,7 +6030,8 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->port != PORT_TP && cmd->port != PORT_FIBRE)
 		goto err_out_unlock;
 
-	if (cmd->port != bp->phy_port && !(bp->phy_flags & REMOTE_PHY_CAP_FLAG))
+	if (cmd->port != bp->phy_port &&
+	    !(bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP))
 		goto err_out_unlock;
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
@@ -6049,7 +6051,7 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			advertising = cmd->advertising;
 
 		} else if (cmd->advertising == ADVERTISED_2500baseX_Full) {
-			if (!(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG) ||
+			if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE) ||
 			    (cmd->port == PORT_TP))
 				goto err_out_unlock;
 		} else if (cmd->advertising == ADVERTISED_1000baseT_Full)
@@ -6072,7 +6074,7 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				goto err_out_unlock;
 
 			if (cmd->speed == SPEED_2500 &&
-			    !(bp->phy_flags & PHY_2_5G_CAPABLE_FLAG))
+			    !(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 				goto err_out_unlock;
 		}
 		else if (cmd->speed == SPEED_1000 || cmd->speed == SPEED_2500)
@@ -6217,7 +6219,7 @@ bnx2_nway_reset(struct net_device *dev)
 
 	spin_lock_bh(&bp->phy_lock);
 
-	if (bp->phy_flags & REMOTE_PHY_CAP_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP) {
 		int rc;
 
 		rc = bnx2_setup_remote_phy(bp, bp->phy_port);
@@ -6226,7 +6228,7 @@ bnx2_nway_reset(struct net_device *dev)
 	}
 
 	/* Force a link down visible on the other side */
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		bnx2_write_phy(bp, bp->mii_bmcr, BMCR_LOOPBACK);
 		spin_unlock_bh(&bp->phy_lock);
 
@@ -6838,7 +6840,7 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG: {
 		u32 mii_regval;
 
-		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 			return -EOPNOTSUPP;
 
 		if (!netif_running(dev))
@@ -6857,7 +6859,7 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if (bp->phy_flags & REMOTE_PHY_CAP_FLAG)
+		if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 			return -EOPNOTSUPP;
 
 		if (!netif_running(dev))
@@ -6929,7 +6931,7 @@ bnx2_get_5709_media(struct bnx2 *bp)
 	if (bond_id == BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_C)
 		return;
 	else if (bond_id == BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID_S) {
-		bp->phy_flags |= PHY_SERDES_FLAG;
+		bp->phy_flags |= BNX2_PHY_FLAG_SERDES;
 		return;
 	}
 
@@ -6943,7 +6945,7 @@ bnx2_get_5709_media(struct bnx2 *bp)
 		case 0x4:
 		case 0x5:
 		case 0x6:
-			bp->phy_flags |= PHY_SERDES_FLAG;
+			bp->phy_flags |= BNX2_PHY_FLAG_SERDES;
 			return;
 		}
 	} else {
@@ -6951,7 +6953,7 @@ bnx2_get_5709_media(struct bnx2 *bp)
 		case 0x1:
 		case 0x2:
 		case 0x4:
-			bp->phy_flags |= PHY_SERDES_FLAG;
+			bp->phy_flags |= BNX2_PHY_FLAG_SERDES;
 			return;
 		}
 	}
@@ -7260,10 +7262,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		bnx2_get_5709_media(bp);
 	else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
-		bp->phy_flags |= PHY_SERDES_FLAG;
+		bp->phy_flags |= BNX2_PHY_FLAG_SERDES;
 
 	bp->phy_port = PORT_TP;
-	if (bp->phy_flags & PHY_SERDES_FLAG) {
+	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		bp->phy_port = PORT_FIBRE;
 		reg = REG_RD_IND(bp, bp->shmem_base +
 				     BNX2_SHARED_HW_CFG_CONFIG);
@@ -7274,17 +7276,17 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		if (CHIP_NUM(bp) != CHIP_NUM_5706) {
 			bp->phy_addr = 2;
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
-				bp->phy_flags |= PHY_2_5G_CAPABLE_FLAG;
+				bp->phy_flags |= BNX2_PHY_FLAG_2_5G_CAPABLE;
 		}
 		bnx2_init_remote_phy(bp);
 
 	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
 		   CHIP_NUM(bp) == CHIP_NUM_5708)
-		bp->phy_flags |= PHY_CRC_FIX_FLAG;
+		bp->phy_flags |= BNX2_PHY_FLAG_CRC_FIX;
 	else if (CHIP_NUM(bp) == CHIP_NUM_5709 &&
 		 (CHIP_REV(bp) == CHIP_REV_Ax ||
 		  CHIP_REV(bp) == CHIP_REV_Bx))
-		bp->phy_flags |= PHY_DIS_EARLY_DAC_FLAG;
+		bp->phy_flags |= BNX2_PHY_FLAG_DIS_EARLY_DAC;
 
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index cd79b5c..54ce11a 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6644,16 +6644,16 @@ struct bnx2 {
 	spinlock_t		indirect_lock;
 
 	u32			phy_flags;
-#define PHY_SERDES_FLAG			1
-#define PHY_CRC_FIX_FLAG		2
-#define PHY_PARALLEL_DETECT_FLAG	4
-#define PHY_2_5G_CAPABLE_FLAG		8
-#define PHY_INT_MODE_MASK_FLAG		0x300
-#define PHY_INT_MODE_AUTO_POLLING_FLAG	0x100
-#define PHY_INT_MODE_LINK_READY_FLAG	0x200
-#define PHY_DIS_EARLY_DAC_FLAG		0x400
-#define REMOTE_PHY_CAP_FLAG		0x800
-#define PHY_FORCED_DOWN_FLAG		0x1000
+#define BNX2_PHY_FLAG_SERDES			0x00000001
+#define BNX2_PHY_FLAG_CRC_FIX			0x00000002
+#define BNX2_PHY_FLAG_PARALLEL_DETECT		0x00000004
+#define BNX2_PHY_FLAG_2_5G_CAPABLE		0x00000008
+#define BNX2_PHY_FLAG_INT_MODE_MASK		0x00000300
+#define BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING	0x00000100
+#define BNX2_PHY_FLAG_INT_MODE_LINK_READY	0x00000200
+#define BNX2_PHY_FLAG_DIS_EARLY_DAC		0x00000400
+#define BNX2_PHY_FLAG_REMOTE_PHY_CAP		0x00000800
+#define BNX2_PHY_FLAG_FORCED_DOWN		0x00001000
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;


