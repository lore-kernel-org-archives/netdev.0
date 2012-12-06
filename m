From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5 net-next] bnx2: Add BNX2 prefix to CHIP ID and name
 macros
Date: Thu, 6 Dec 2012 12:33:10 -0800
Message-ID: <1354825992-8547-3-git-send-email-mchan@broadcom.com>
References: <1354825992-8547-1-git-send-email-mchan@broadcom.com>
 <1354825992-8547-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4129 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422861Ab2LFUSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 15:18:01 -0500
In-Reply-To: <1354825992-8547-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for namespace consistency.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |  178 +++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnx2.h |   48 +++++-----
 drivers/net/ethernet/broadcom/cnic.c |   14 ++--
 3 files changed, 120 insertions(+), 120 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 98cb76b..a9b2fea 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -306,7 +306,7 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 {
 	offset += cid_addr;
 	spin_lock_bh(&bp->indirect_lock);
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		int i;
 
 		BNX2_WR(bp, BNX2_CTX_CTX_DATA, val);
@@ -887,7 +887,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	bp->stats_blk_mapping = bp->status_blk_mapping + status_blk_size;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		bp->ctx_pages = 0x2000 / BNX2_PAGE_SIZE;
 		if (bp->ctx_pages == 0)
 			bp->ctx_pages = 1;
@@ -1034,7 +1034,7 @@ bnx2_resolve_flow_ctrl(struct bnx2 *bp)
 	}
 
 	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5708)) {
+	    (BNX2_CHIP(bp) == BNX2_CHIP_5708)) {
 		u32 val;
 
 		bnx2_read_phy(bp, BCM5708S_1000X_STAT1, &val);
@@ -1310,7 +1310,7 @@ bnx2_set_mac_link(struct bnx2 *bp)
 	if (bp->link_up) {
 		switch (bp->line_speed) {
 			case SPEED_10:
-				if (CHIP_NUM(bp) != CHIP_NUM_5706) {
+				if (BNX2_CHIP(bp) != BNX2_CHIP_5706) {
 					val |= BNX2_EMAC_MODE_PORT_MII_10M;
 					break;
 				}
@@ -1360,7 +1360,7 @@ static void
 bnx2_enable_bmsr1(struct bnx2 *bp)
 {
 	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5709))
+	    (BNX2_CHIP(bp) == BNX2_CHIP_5709))
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_GP_STATUS);
 }
@@ -1369,7 +1369,7 @@ static void
 bnx2_disable_bmsr1(struct bnx2 *bp)
 {
 	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5709))
+	    (BNX2_CHIP(bp) == BNX2_CHIP_5709))
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
 }
@@ -1386,7 +1386,7 @@ bnx2_test_and_enable_2g5(struct bnx2 *bp)
 	if (bp->autoneg & AUTONEG_SPEED)
 		bp->advertising |= ADVERTISED_2500baseX_Full;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
 
 	bnx2_read_phy(bp, bp->mii_up1, &up1);
@@ -1396,7 +1396,7 @@ bnx2_test_and_enable_2g5(struct bnx2 *bp)
 		ret = 0;
 	}
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
 
@@ -1412,7 +1412,7 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return 0;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR, MII_BNX2_BLK_ADDR_OVER1G);
 
 	bnx2_read_phy(bp, bp->mii_up1, &up1);
@@ -1422,7 +1422,7 @@ bnx2_test_and_disable_2g5(struct bnx2 *bp)
 		ret = 1;
 	}
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
 
@@ -1438,7 +1438,7 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		u32 val;
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
@@ -1454,7 +1454,7 @@ bnx2_enable_forced_2g5(struct bnx2 *bp)
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
 		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
-	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+	} else if (BNX2_CHIP(bp) == BNX2_CHIP_5708) {
 		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		if (!err)
 			bmcr |= BCM5708S_BMCR_FORCE_2500;
@@ -1482,7 +1482,7 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 	if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE))
 		return;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		u32 val;
 
 		bnx2_write_phy(bp, MII_BNX2_BLK_ADDR,
@@ -1496,7 +1496,7 @@ bnx2_disable_forced_2g5(struct bnx2 *bp)
 			       MII_BNX2_BLK_ADDR_COMBO_IEEEB0);
 		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
-	} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+	} else if (BNX2_CHIP(bp) == BNX2_CHIP_5708) {
 		err = bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 		if (!err)
 			bmcr &= ~BCM5708S_BMCR_FORCE_2500;
@@ -1547,7 +1547,7 @@ bnx2_set_link(struct bnx2 *bp)
 	bnx2_disable_bmsr1(bp);
 
 	if ((bp->phy_flags & BNX2_PHY_FLAG_SERDES) &&
-	    (CHIP_NUM(bp) == CHIP_NUM_5706)) {
+	    (BNX2_CHIP(bp) == BNX2_CHIP_5706)) {
 		u32 val, an_dbg;
 
 		if (bp->phy_flags & BNX2_PHY_FLAG_FORCED_DOWN) {
@@ -1571,11 +1571,11 @@ bnx2_set_link(struct bnx2 *bp)
 		bp->link_up = 1;
 
 		if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
-			if (CHIP_NUM(bp) == CHIP_NUM_5706)
+			if (BNX2_CHIP(bp) == BNX2_CHIP_5706)
 				bnx2_5706s_linkup(bp);
-			else if (CHIP_NUM(bp) == CHIP_NUM_5708)
+			else if (BNX2_CHIP(bp) == BNX2_CHIP_5708)
 				bnx2_5708s_linkup(bp);
-			else if (CHIP_NUM(bp) == CHIP_NUM_5709)
+			else if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 				bnx2_5709s_linkup(bp);
 		}
 		else {
@@ -1757,7 +1757,7 @@ __acquires(&bp->phy_lock)
 		new_bmcr = bmcr & ~BMCR_ANENABLE;
 		new_bmcr |= BMCR_SPEED1000;
 
-		if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 			if (bp->req_line_speed == SPEED_2500)
 				bnx2_enable_forced_2g5(bp);
 			else if (bp->req_line_speed == SPEED_1000) {
@@ -1765,7 +1765,7 @@ __acquires(&bp->phy_lock)
 				new_bmcr &= ~0x2000;
 			}
 
-		} else if (CHIP_NUM(bp) == CHIP_NUM_5708) {
+		} else if (BNX2_CHIP(bp) == BNX2_CHIP_5708) {
 			if (bp->req_line_speed == SPEED_2500)
 				new_bmcr |= BCM5708S_BMCR_FORCE_2500;
 			else
@@ -2230,9 +2230,9 @@ bnx2_init_5708s_phy(struct bnx2 *bp, int reset_phy)
 		bnx2_write_phy(bp, BCM5708S_UP1, val);
 	}
 
-	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B1)) {
+	if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_A0) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_B0) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_B1)) {
 		/* increase tx signal amplitude */
 		bnx2_write_phy(bp, BCM5708S_BLK_ADDR,
 			       BCM5708S_BLK_ADDR_TX_MISC);
@@ -2268,7 +2268,7 @@ bnx2_init_5706s_phy(struct bnx2 *bp, int reset_phy)
 
 	bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5706)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5706)
 		BNX2_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
 
 	if (bp->dev->mtu > 1500) {
@@ -2379,11 +2379,11 @@ __acquires(&bp->phy_lock)
 	bp->phy_id |= val & 0xffff;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
-		if (CHIP_NUM(bp) == CHIP_NUM_5706)
+		if (BNX2_CHIP(bp) == BNX2_CHIP_5706)
 			rc = bnx2_init_5706s_phy(bp, reset_phy);
-		else if (CHIP_NUM(bp) == CHIP_NUM_5708)
+		else if (BNX2_CHIP(bp) == BNX2_CHIP_5708)
 			rc = bnx2_init_5708s_phy(bp, reset_phy);
-		else if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		else if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 			rc = bnx2_init_5709s_phy(bp, reset_phy);
 	}
 	else {
@@ -2449,7 +2449,7 @@ bnx2_dump_mcp_state(struct bnx2 *bp)
 	u32 mcp_p0, mcp_p1;
 
 	netdev_err(dev, "<--- start MCP states dump --->\n");
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		mcp_p0 = BNX2_MCP_STATE_P0;
 		mcp_p1 = BNX2_MCP_STATE_P1;
 	} else {
@@ -2591,7 +2591,7 @@ bnx2_init_context(struct bnx2 *bp)
 
 		vcid--;
 
-		if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
+		if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 			u32 new_vcid;
 
 			vcid_addr = GET_PCID_ADDR(vcid);
@@ -3668,10 +3668,10 @@ static int bnx2_request_uncached_firmware(struct bnx2 *bp)
 	const struct bnx2_rv2p_fw_file *rv2p_fw;
 	int rc;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		mips_fw_file = FW_MIPS_FILE_09;
-		if ((CHIP_ID(bp) == CHIP_ID_5709_A0) ||
-		    (CHIP_ID(bp) == CHIP_ID_5709_A1))
+		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5709_A0) ||
+		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5709_A1))
 			rv2p_fw_file = FW_RV2P_FILE_09_Ax;
 		else
 			rv2p_fw_file = FW_RV2P_FILE_09;
@@ -4021,8 +4021,8 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 				     1, 0);
 
 		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
-		if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
-		    (CHIP_ID(bp) == CHIP_ID_5706_A1)) {
+		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
+		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1)) {
 
 			if (bp->wol)
 				pmcsr |= 3;
@@ -4292,7 +4292,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 	int j, entry_count, rc = 0;
 	const struct flash_spec *flash;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		bp->flash_info = &flash_5709;
 		goto get_flash_size;
 	}
@@ -4716,8 +4716,8 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 	/* Wait for the current PCI transaction to complete before
 	 * issuing a reset. */
-	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
-	    (CHIP_NUM(bp) == CHIP_NUM_5708)) {
+	if ((BNX2_CHIP(bp) == BNX2_CHIP_5706) ||
+	    (BNX2_CHIP(bp) == BNX2_CHIP_5708)) {
 		BNX2_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
 			BNX2_MISC_ENABLE_CLR_BITS_TX_DMA_ENABLE |
 			BNX2_MISC_ENABLE_CLR_BITS_DMA_ENGINE_ENABLE |
@@ -4751,7 +4751,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	 * before we issue a reset. */
 	val = BNX2_RD(bp, BNX2_MISC_ID);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		BNX2_WR(bp, BNX2_MISC_COMMAND, BNX2_MISC_COMMAND_SW_RESET);
 		BNX2_RD(bp, BNX2_MISC_COMMAND);
 		udelay(5);
@@ -4773,8 +4773,8 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		 * bus on 5706 A0 and A1.  The msleep below provides plenty
 		 * of margin for write posting.
 		 */
-		if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
-		    (CHIP_ID(bp) == CHIP_ID_5706_A1))
+		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
+		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1))
 			msleep(20);
 
 		/* Reset takes approximate 30 usec */
@@ -4813,7 +4813,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		bnx2_set_default_remote_link(bp);
 	spin_unlock_bh(&bp->phy_lock);
 
-	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
+	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 		/* Adjust the voltage regular to two steps lower.  The default
 		 * of this register is 0x0000000e. */
 		BNX2_WR(bp, BNX2_MISC_VREG_CONTROL, 0x000000fa);
@@ -4855,13 +4855,14 @@ bnx2_init_chip(struct bnx2 *bp)
 	if ((bp->flags & BNX2_FLAG_PCIX) && (bp->bus_speed_mhz == 133))
 		val |= (1 << 23);
 
-	if ((CHIP_NUM(bp) == CHIP_NUM_5706) &&
-	    (CHIP_ID(bp) != CHIP_ID_5706_A0) && !(bp->flags & BNX2_FLAG_PCIX))
+	if ((BNX2_CHIP(bp) == BNX2_CHIP_5706) &&
+	    (BNX2_CHIP_ID(bp) != BNX2_CHIP_ID_5706_A0) &&
+	    !(bp->flags & BNX2_FLAG_PCIX))
 		val |= BNX2_DMA_CONFIG_CNTL_PING_PONG_DMA;
 
 	BNX2_WR(bp, BNX2_DMA_CONFIG, val);
 
-	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
+	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 		val = BNX2_RD(bp, BNX2_TDMA_CONFIG);
 		val |= BNX2_TDMA_CONFIG_ONE_DMA;
 		BNX2_WR(bp, BNX2_TDMA_CONFIG, val);
@@ -4883,7 +4884,7 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	/* Initialize context mapping and zero out the quick contexts.  The
 	 * context block must have already been enabled. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		rc = bnx2_init_5709_context(bp);
 		if (rc)
 			return rc;
@@ -4900,9 +4901,9 @@ bnx2_init_chip(struct bnx2 *bp)
 	val = BNX2_RD(bp, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
 	val |= BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE_256;
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		val |= BNX2_MQ_CONFIG_BIN_MQ_MODE;
-		if (CHIP_REV(bp) == CHIP_REV_Ax)
+		if (BNX2_CHIP_REV(bp) == BNX2_CHIP_REV_Ax)
 			val |= BNX2_MQ_CONFIG_HALT_DIS;
 	}
 
@@ -4988,7 +4989,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		BNX2_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks);
 	BNX2_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
 
-	if (CHIP_ID(bp) == CHIP_ID_5706_A1)
+	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1)
 		val = BNX2_HC_CONFIG_COLLECT_STATS;
 	else {
 		val = BNX2_HC_CONFIG_RX_TMR_MODE | BNX2_HC_CONFIG_TX_TMR_MODE |
@@ -5044,7 +5045,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	/* Initialize the receive filter. */
 	bnx2_set_rx_mode(bp->dev);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		val = BNX2_RD(bp, BNX2_MISC_NEW_CORE_CTL);
 		val |= BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE;
 		BNX2_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
@@ -5091,7 +5092,7 @@ bnx2_init_tx_context(struct bnx2 *bp, u32 cid, struct bnx2_tx_ring_info *txr)
 	u32 val, offset0, offset1, offset2, offset3;
 	u32 cid_addr = GET_CID_ADDR(cid);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		offset0 = BNX2_L2CTX_TYPE_XI;
 		offset1 = BNX2_L2CTX_CMD_TYPE_XI;
 		offset2 = BNX2_L2CTX_TBDR_BHADDR_HI_XI;
@@ -5192,7 +5193,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	bnx2_init_rx_context(bp, cid);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		val = BNX2_RD(bp, BNX2_MQ_MAP_L2_5);
 		BNX2_WR(bp, BNX2_MQ_MAP_L2_5, val | BNX2_MQ_MAP_L2_5_ARM);
 	}
@@ -5213,7 +5214,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 		val = (u64) rxr->rx_pg_desc_mapping[0] & 0xffffffff;
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
 
-		if (CHIP_NUM(bp) == CHIP_NUM_5709)
+		if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 			BNX2_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
 	}
 
@@ -5621,7 +5622,7 @@ bnx2_test_registers(struct bnx2 *bp)
 
 	ret = 0;
 	is_5709 = 0;
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		is_5709 = 1;
 
 	for (i = 0; reg_tbl[i].offset != 0xffff; i++) {
@@ -5720,7 +5721,7 @@ bnx2_test_memory(struct bnx2 *bp)
 	};
 	struct mem_entry *mem_tbl;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		mem_tbl = mem_tbl_5709;
 	else
 		mem_tbl = mem_tbl_5706;
@@ -6142,7 +6143,7 @@ bnx2_timer(unsigned long data)
 			BNX2_HC_COMMAND_STATS_NOW);
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
-		if (CHIP_NUM(bp) == CHIP_NUM_5706)
+		if (BNX2_CHIP(bp) == BNX2_CHIP_5706)
 			bnx2_5706_serdes_timer(bp);
 		else
 			bnx2_5708_serdes_timer(bp);
@@ -6280,7 +6281,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	    !(bp->flags & BNX2_FLAG_USING_MSIX)) {
 		if (pci_enable_msi(bp->pdev) == 0) {
 			bp->flags |= BNX2_FLAG_USING_MSI;
-			if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+			if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 				bp->flags |= BNX2_FLAG_ONE_SHOT_MSI;
 				bp->irq_tbl[0].handler = bnx2_msi_1shot;
 			} else
@@ -6816,8 +6817,8 @@ bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		GET_32BIT_NET_STATS(stat_Dot3StatsExcessiveCollisions) +
 		GET_32BIT_NET_STATS(stat_Dot3StatsLateCollisions);
 
-	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_A0))
+	if ((BNX2_CHIP(bp) == BNX2_CHIP_5706) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_A0))
 		net_stats->tx_carrier_errors = 0;
 	else {
 		net_stats->tx_carrier_errors =
@@ -7620,10 +7621,10 @@ bnx2_get_ethtool_stats(struct net_device *dev,
 		return;
 	}
 
-	if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5706_A1) ||
-	    (CHIP_ID(bp) == CHIP_ID_5706_A2) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_A0))
+	if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A2) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_A0))
 		stats_len_arr = bnx2_5706_stats_len_arr;
 	else
 		stats_len_arr = bnx2_5708_stats_len_arr;
@@ -8143,14 +8144,14 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->chip_id = BNX2_RD(bp, BNX2_MISC_ID);
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709) {
 		if (!pci_is_pcie(pdev)) {
 			dev_err(&pdev->dev, "Not PCIE, aborting\n");
 			rc = -EIO;
 			goto err_out_unmap;
 		}
 		bp->flags |= BNX2_FLAG_PCIE;
-		if (CHIP_REV(bp) == CHIP_REV_Ax)
+		if (BNX2_CHIP_REV(bp) == BNX2_CHIP_REV_Ax)
 			bp->flags |= BNX2_FLAG_JUMBO_BROKEN;
 
 		/* AER (Advanced Error Reporting) hooks */
@@ -8169,18 +8170,20 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bp->flags |= BNX2_FLAG_BROKEN_STATS;
 	}
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709 && CHIP_REV(bp) != CHIP_REV_Ax) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709 &&
+	    BNX2_CHIP_REV(bp) != BNX2_CHIP_REV_Ax) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_MSIX))
 			bp->flags |= BNX2_FLAG_MSIX_CAP;
 	}
 
-	if (CHIP_ID(bp) != CHIP_ID_5706_A0 && CHIP_ID(bp) != CHIP_ID_5706_A1) {
+	if (BNX2_CHIP_ID(bp) != BNX2_CHIP_ID_5706_A0 &&
+	    BNX2_CHIP_ID(bp) != BNX2_CHIP_ID_5706_A1) {
 		if (pci_find_capability(pdev, PCI_CAP_ID_MSI))
 			bp->flags |= BNX2_FLAG_MSI_CAP;
 	}
 
 	/* 5708 cannot support DMA addresses > 40-bit.  */
-	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5708)
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 	else
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
@@ -8203,12 +8206,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		bnx2_get_pci_speed(bp);
 
 	/* 5706A0 may falsely detect SERR and PERR. */
-	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
+	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 		reg = BNX2_RD(bp, PCI_COMMAND);
 		reg &= ~(PCI_COMMAND_SERR | PCI_COMMAND_PARITY);
 		BNX2_WR(bp, PCI_COMMAND, reg);
-	}
-	else if ((CHIP_ID(bp) == CHIP_ID_5706_A1) &&
+	} else if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1) &&
 		!(bp->flags & BNX2_FLAG_PCIX)) {
 
 		dev_err(&pdev->dev,
@@ -8325,9 +8327,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->phy_addr = 1;
 
 	/* Disable WOL support if we are running on a SERDES chip. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		bnx2_get_5709_media(bp);
-	else if (CHIP_BOND_ID(bp) & CHIP_BOND_ID_SERDES_BIT)
+	else if (BNX2_CHIP_BOND(bp) & BNX2_CHIP_BOND_SERDES_BIT)
 		bp->phy_flags |= BNX2_PHY_FLAG_SERDES;
 
 	bp->phy_port = PORT_TP;
@@ -8338,7 +8340,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			bp->flags |= BNX2_FLAG_NO_WOL;
 			bp->wol = 0;
 		}
-		if (CHIP_NUM(bp) == CHIP_NUM_5706) {
+		if (BNX2_CHIP(bp) == BNX2_CHIP_5706) {
 			/* Don't do parallel detect on this board because of
 			 * some board problems.  The link will not go down
 			 * if we do parallel detect.
@@ -8351,25 +8353,25 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			if (reg & BNX2_SHARED_HW_CFG_PHY_2_5G)
 				bp->phy_flags |= BNX2_PHY_FLAG_2_5G_CAPABLE;
 		}
-	} else if (CHIP_NUM(bp) == CHIP_NUM_5706 ||
-		   CHIP_NUM(bp) == CHIP_NUM_5708)
+	} else if (BNX2_CHIP(bp) == BNX2_CHIP_5706 ||
+		   BNX2_CHIP(bp) == BNX2_CHIP_5708)
 		bp->phy_flags |= BNX2_PHY_FLAG_CRC_FIX;
-	else if (CHIP_NUM(bp) == CHIP_NUM_5709 &&
-		 (CHIP_REV(bp) == CHIP_REV_Ax ||
-		  CHIP_REV(bp) == CHIP_REV_Bx))
+	else if (BNX2_CHIP(bp) == BNX2_CHIP_5709 &&
+		 (BNX2_CHIP_REV(bp) == BNX2_CHIP_REV_Ax ||
+		  BNX2_CHIP_REV(bp) == BNX2_CHIP_REV_Bx))
 		bp->phy_flags |= BNX2_PHY_FLAG_DIS_EARLY_DAC;
 
 	bnx2_init_fw_cap(bp);
 
-	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
-	    (CHIP_ID(bp) == CHIP_ID_5708_B1) ||
+	if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_A0) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_B0) ||
+	    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5708_B1) ||
 	    !(BNX2_RD(bp, BNX2_PCI_CONFIG_3) & BNX2_PCI_CONFIG_3_VAUX_PRESET)) {
 		bp->flags |= BNX2_FLAG_NO_WOL;
 		bp->wol = 0;
 	}
 
-	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
+	if (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) {
 		bp->tx_quick_cons_trip_int =
 			bp->tx_quick_cons_trip;
 		bp->tx_ticks_int = bp->tx_ticks;
@@ -8391,7 +8393,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	 * AMD believes this incompatibility is unique to the 5706, and
 	 * prefers to locally disable MSI rather than globally disabling it.
 	 */
-	if (CHIP_NUM(bp) == CHIP_NUM_5706 && disable_msi == 0) {
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5706 && disable_msi == 0) {
 		struct pci_dev *amd_8132 = NULL;
 
 		while ((amd_8132 = pci_get_device(PCI_VENDOR_ID_AMD,
@@ -8547,7 +8549,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		NETIF_F_TSO | NETIF_F_TSO_ECN |
 		NETIF_F_RXHASH | NETIF_F_RXCSUM;
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
+	if (BNX2_CHIP(bp) == BNX2_CHIP_5709)
 		dev->hw_features |= NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
 
 	dev->vlan_features = dev->hw_features;
@@ -8562,15 +8564,15 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev_info(dev, "%s (%c%d) %s found at mem %lx, IRQ %d, "
 		    "node addr %pM\n", board_info[ent->driver_data].name,
-		    ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
-		    ((CHIP_ID(bp) & 0x0ff0) >> 4),
+		    ((BNX2_CHIP_ID(bp) & 0xf000) >> 12) + 'A',
+		    ((BNX2_CHIP_ID(bp) & 0x0ff0) >> 4),
 		    bnx2_bus_string(bp, str), (long)pci_resource_start(pdev, 0),
 		    pdev->irq, dev->dev_addr);
 
 	return 0;
 
 error:
-	pci_iounmap(pdev, bp->regview);
+	iounmap(bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
@@ -8748,7 +8750,7 @@ static void bnx2_io_resume(struct pci_dev *pdev)
 	rtnl_unlock();
 }
 
-static const struct pci_error_handlers bnx2_err_handler = {
+static struct pci_error_handlers bnx2_err_handler = {
 	.error_detected	= bnx2_io_error_detected,
 	.slot_reset	= bnx2_io_slot_reset,
 	.resume		= bnx2_io_resume,
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 58caa22..38a640d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6854,33 +6854,31 @@ struct bnx2 {
 
 	u32			chip_id;
 	/* chip num:16-31, rev:12-15, metal:4-11, bond_id:0-3 */
-#define CHIP_NUM(bp)			(((bp)->chip_id) & 0xffff0000)
-#define CHIP_NUM_5706			0x57060000
-#define CHIP_NUM_5708			0x57080000
-#define CHIP_NUM_5709			0x57090000
-
-#define CHIP_REV(bp)			(((bp)->chip_id) & 0x0000f000)
-#define CHIP_REV_Ax			0x00000000
-#define CHIP_REV_Bx			0x00001000
-#define CHIP_REV_Cx			0x00002000
-
-#define CHIP_METAL(bp)			(((bp)->chip_id) & 0x00000ff0)
-#define CHIP_BONDING(bp)		(((bp)->chip_id) & 0x0000000f)
-
-#define CHIP_ID(bp)			(((bp)->chip_id) & 0xfffffff0)
-#define CHIP_ID_5706_A0			0x57060000
-#define CHIP_ID_5706_A1			0x57060010
-#define CHIP_ID_5706_A2			0x57060020
-#define CHIP_ID_5708_A0			0x57080000
-#define CHIP_ID_5708_B0			0x57081000
-#define CHIP_ID_5708_B1			0x57081010
-#define CHIP_ID_5709_A0			0x57090000
-#define CHIP_ID_5709_A1			0x57090010
-
-#define CHIP_BOND_ID(bp)		(((bp)->chip_id) & 0xf)
+#define BNX2_CHIP(bp)			(((bp)->chip_id) & 0xffff0000)
+#define BNX2_CHIP_5706			0x57060000
+#define BNX2_CHIP_5708			0x57080000
+#define BNX2_CHIP_5709			0x57090000
+
+#define BNX2_CHIP_REV(bp)		(((bp)->chip_id) & 0x0000f000)
+#define BNX2_CHIP_REV_Ax		0x00000000
+#define BNX2_CHIP_REV_Bx		0x00001000
+#define BNX2_CHIP_REV_Cx		0x00002000
+
+#define BNX2_CHIP_METAL(bp)		(((bp)->chip_id) & 0x00000ff0)
+#define BNX2_CHIP_BOND(bp)		(((bp)->chip_id) & 0x0000000f)
+
+#define BNX2_CHIP_ID(bp)		(((bp)->chip_id) & 0xfffffff0)
+#define BNX2_CHIP_ID_5706_A0		0x57060000
+#define BNX2_CHIP_ID_5706_A1			0x57060010
+#define BNX2_CHIP_ID_5706_A2			0x57060020
+#define BNX2_CHIP_ID_5708_A0			0x57080000
+#define BNX2_CHIP_ID_5708_B0			0x57081000
+#define BNX2_CHIP_ID_5708_B1			0x57081010
+#define BNX2_CHIP_ID_5709_A0			0x57090000
+#define BNX2_CHIP_ID_5709_A1			0x57090010
 
 /* A serdes chip will have the first bit of the bond id set. */
-#define CHIP_BOND_ID_SERDES_BIT		0x01
+#define BNX2_CHIP_BOND_SERDES_BIT		0x01
 
 	u32			phy_addr;
 	u32			phy_id;
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 756a2a7..5778098 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -895,7 +895,7 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 
-	if (CHIP_NUM(cp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(cp) == BNX2_CHIP_5709) {
 		int i, k, arr_size;
 
 		cp->ctx_blk_size = BNX2_PAGE_SIZE;
@@ -4358,7 +4358,7 @@ static int cnic_setup_5709_context(struct cnic_dev *dev, int valid)
 	int ret = 0, i;
 	u32 valid_bit = valid ? BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID : 0;
 
-	if (CHIP_NUM(cp) != CHIP_NUM_5709)
+	if (BNX2_CHIP(cp) != BNX2_CHIP_5709)
 		return 0;
 
 	for (i = 0; i < cp->ctx_blks; i++) {
@@ -4526,7 +4526,7 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 	cp->tx_cons = *cp->tx_cons_ptr;
 
 	cid_addr = GET_CID_ADDR(tx_cid);
-	if (CHIP_NUM(cp) == CHIP_NUM_5709) {
+	if (BNX2_CHIP(cp) == BNX2_CHIP_5709) {
 		u32 cid_addr2 = GET_CID_ADDR(tx_cid + 4) + 0x40;
 
 		for (i = 0; i < PHY_CTX_SIZE; i += 4)
@@ -4671,7 +4671,7 @@ static void cnic_set_bnx2_mac(struct cnic_dev *dev)
 	CNIC_WR(dev, BNX2_EMAC_MAC_MATCH5, val);
 
 	val = 4 | BNX2_RPM_SORT_USER2_BC_EN;
-	if (CHIP_NUM(cp) != CHIP_NUM_5709)
+	if (BNX2_CHIP(cp) != BNX2_CHIP_5709)
 		val |= BNX2_RPM_SORT_USER2_PROM_VLAN;
 
 	CNIC_WR(dev, BNX2_RPM_SORT_USER2, 0x0);
@@ -4717,7 +4717,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	cp->kwq_con_idx = 0;
 	set_bit(CNIC_LCL_FL_KWQ_INIT, &cp->cnic_local_flags);
 
-	if (CHIP_NUM(cp) == CHIP_NUM_5706 || CHIP_NUM(cp) == CHIP_NUM_5708)
+	if (BNX2_CHIP(cp) == BNX2_CHIP_5706 || BNX2_CHIP(cp) == BNX2_CHIP_5708)
 		cp->kwq_con_idx_ptr = &sblk->status_rx_quick_consumer_index15;
 	else
 		cp->kwq_con_idx_ptr = &sblk->status_cmd_consumer_index;
@@ -4917,9 +4917,9 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 
 		if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id))
 			pbd_e2->parsing_data = (UNICAST_ADDRESS <<
-				 ETH_TX_PARSE_BD_E2_ETH_ADDR_TYPE_SHIFT);
+				ETH_TX_PARSE_BD_E2_ETH_ADDR_TYPE_SHIFT);
 		else
-			 pbd_e1x->global_data = (UNICAST_ADDRESS <<
+			pbd_e1x->global_data = (UNICAST_ADDRESS <<
 				ETH_TX_PARSE_BD_E1X_ETH_ADDR_TYPE_SHIFT);
 	}
 
-- 
1.7.1
