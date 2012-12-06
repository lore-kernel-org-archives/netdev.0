From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5 net-next] bnx2: Rename register read and write
 macros
Date: Thu, 6 Dec 2012 12:33:08 -0800
Message-ID: <1354825992-8547-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2161 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422812Ab2LFUR7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 15:17:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

with BNX2_ prefix for namespace consistency.  Currently, these macro names
conflict with similar macros in bnx2x.h, preventing the cnic driver from
including both bnx2.h and bnx2x.h.  Including bnx2x.h in cnic.c will remove
many redundant definitions and simplify the interface.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |  636 +++++++++++++++++-----------------
 drivers/net/ethernet/broadcom/bnx2.h |    6 +-
 2 files changed, 321 insertions(+), 321 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index e264e96..41fa6af 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -274,8 +274,8 @@ bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset)
 	u32 val;
 
 	spin_lock_bh(&bp->indirect_lock);
-	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
-	val = REG_RD(bp, BNX2_PCICFG_REG_WINDOW);
+	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
+	val = BNX2_RD(bp, BNX2_PCICFG_REG_WINDOW);
 	spin_unlock_bh(&bp->indirect_lock);
 	return val;
 }
@@ -284,8 +284,8 @@ static void
 bnx2_reg_wr_ind(struct bnx2 *bp, u32 offset, u32 val)
 {
 	spin_lock_bh(&bp->indirect_lock);
-	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
-	REG_WR(bp, BNX2_PCICFG_REG_WINDOW, val);
+	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, offset);
+	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW, val);
 	spin_unlock_bh(&bp->indirect_lock);
 }
 
@@ -309,18 +309,18 @@ bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val)
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		int i;
 
-		REG_WR(bp, BNX2_CTX_CTX_DATA, val);
-		REG_WR(bp, BNX2_CTX_CTX_CTRL,
-		       offset | BNX2_CTX_CTX_CTRL_WRITE_REQ);
+		BNX2_WR(bp, BNX2_CTX_CTX_DATA, val);
+		BNX2_WR(bp, BNX2_CTX_CTX_CTRL,
+			offset | BNX2_CTX_CTX_CTRL_WRITE_REQ);
 		for (i = 0; i < 5; i++) {
-			val = REG_RD(bp, BNX2_CTX_CTX_CTRL);
+			val = BNX2_RD(bp, BNX2_CTX_CTX_CTRL);
 			if ((val & BNX2_CTX_CTX_CTRL_WRITE_REQ) == 0)
 				break;
 			udelay(5);
 		}
 	} else {
-		REG_WR(bp, BNX2_CTX_DATA_ADR, offset);
-		REG_WR(bp, BNX2_CTX_DATA, val);
+		BNX2_WR(bp, BNX2_CTX_DATA_ADR, offset);
+		BNX2_WR(bp, BNX2_CTX_DATA, val);
 	}
 	spin_unlock_bh(&bp->indirect_lock);
 }
@@ -494,11 +494,11 @@ bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 	int i, ret;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 &= ~BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
-		REG_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
-		REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		BNX2_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
+		BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 
 		udelay(40);
 	}
@@ -506,16 +506,16 @@ bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 	val1 = (bp->phy_addr << 21) | (reg << 16) |
 		BNX2_EMAC_MDIO_COMM_COMMAND_READ | BNX2_EMAC_MDIO_COMM_DISEXT |
 		BNX2_EMAC_MDIO_COMM_START_BUSY;
-	REG_WR(bp, BNX2_EMAC_MDIO_COMM, val1);
+	BNX2_WR(bp, BNX2_EMAC_MDIO_COMM, val1);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_COMM);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_COMM);
 		if (!(val1 & BNX2_EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 
-			val1 = REG_RD(bp, BNX2_EMAC_MDIO_COMM);
+			val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_COMM);
 			val1 &= BNX2_EMAC_MDIO_COMM_DATA;
 
 			break;
@@ -532,11 +532,11 @@ bnx2_read_phy(struct bnx2 *bp, u32 reg, u32 *val)
 	}
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 |= BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
-		REG_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
-		REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		BNX2_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
+		BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 
 		udelay(40);
 	}
@@ -551,11 +551,11 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 	int i, ret;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 &= ~BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
-		REG_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
-		REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		BNX2_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
+		BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 
 		udelay(40);
 	}
@@ -563,12 +563,12 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 	val1 = (bp->phy_addr << 21) | (reg << 16) | val |
 		BNX2_EMAC_MDIO_COMM_COMMAND_WRITE |
 		BNX2_EMAC_MDIO_COMM_START_BUSY | BNX2_EMAC_MDIO_COMM_DISEXT;
-	REG_WR(bp, BNX2_EMAC_MDIO_COMM, val1);
+	BNX2_WR(bp, BNX2_EMAC_MDIO_COMM, val1);
 
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_COMM);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_COMM);
 		if (!(val1 & BNX2_EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
@@ -581,11 +581,11 @@ bnx2_write_phy(struct bnx2 *bp, u32 reg, u32 val)
 		ret = 0;
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_INT_MODE_AUTO_POLLING) {
-		val1 = REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		val1 = BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 		val1 |= BNX2_EMAC_MDIO_MODE_AUTO_POLL;
 
-		REG_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
-		REG_RD(bp, BNX2_EMAC_MDIO_MODE);
+		BNX2_WR(bp, BNX2_EMAC_MDIO_MODE, val1);
+		BNX2_RD(bp, BNX2_EMAC_MDIO_MODE);
 
 		udelay(40);
 	}
@@ -601,10 +601,10 @@ bnx2_disable_int(struct bnx2 *bp)
 
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		bnapi = &bp->bnx2_napi[i];
-		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+		BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
 		       BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
 	}
-	REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
+	BNX2_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
 }
 
 static void
@@ -616,16 +616,16 @@ bnx2_enable_int(struct bnx2 *bp)
 	for (i = 0; i < bp->irq_nvecs; i++) {
 		bnapi = &bp->bnx2_napi[i];
 
-		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
-		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-		       BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
-		       bnapi->last_status_idx);
+		BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+			BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+			BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
+			bnapi->last_status_idx);
 
-		REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
-		       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-		       bnapi->last_status_idx);
+		BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+			BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+			bnapi->last_status_idx);
 	}
-	REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW);
+	BNX2_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW);
 }
 
 static void
@@ -1294,14 +1294,14 @@ bnx2_set_mac_link(struct bnx2 *bp)
 {
 	u32 val;
 
-	REG_WR(bp, BNX2_EMAC_TX_LENGTHS, 0x2620);
+	BNX2_WR(bp, BNX2_EMAC_TX_LENGTHS, 0x2620);
 	if (bp->link_up && (bp->line_speed == SPEED_1000) &&
 		(bp->duplex == DUPLEX_HALF)) {
-		REG_WR(bp, BNX2_EMAC_TX_LENGTHS, 0x26ff);
+		BNX2_WR(bp, BNX2_EMAC_TX_LENGTHS, 0x26ff);
 	}
 
 	/* Configure the EMAC mode register. */
-	val = REG_RD(bp, BNX2_EMAC_MODE);
+	val = BNX2_RD(bp, BNX2_EMAC_MODE);
 
 	val &= ~(BNX2_EMAC_MODE_PORT | BNX2_EMAC_MODE_HALF_DUPLEX |
 		BNX2_EMAC_MODE_MAC_LOOP | BNX2_EMAC_MODE_FORCE_LINK |
@@ -1333,25 +1333,25 @@ bnx2_set_mac_link(struct bnx2 *bp)
 	/* Set the MAC to operate in the appropriate duplex mode. */
 	if (bp->duplex == DUPLEX_HALF)
 		val |= BNX2_EMAC_MODE_HALF_DUPLEX;
-	REG_WR(bp, BNX2_EMAC_MODE, val);
+	BNX2_WR(bp, BNX2_EMAC_MODE, val);
 
 	/* Enable/disable rx PAUSE. */
 	bp->rx_mode &= ~BNX2_EMAC_RX_MODE_FLOW_EN;
 
 	if (bp->flow_ctrl & FLOW_CTRL_RX)
 		bp->rx_mode |= BNX2_EMAC_RX_MODE_FLOW_EN;
-	REG_WR(bp, BNX2_EMAC_RX_MODE, bp->rx_mode);
+	BNX2_WR(bp, BNX2_EMAC_RX_MODE, bp->rx_mode);
 
 	/* Enable/disable tx PAUSE. */
-	val = REG_RD(bp, BNX2_EMAC_TX_MODE);
+	val = BNX2_RD(bp, BNX2_EMAC_TX_MODE);
 	val &= ~BNX2_EMAC_TX_MODE_FLOW_EN;
 
 	if (bp->flow_ctrl & FLOW_CTRL_TX)
 		val |= BNX2_EMAC_TX_MODE_FLOW_EN;
-	REG_WR(bp, BNX2_EMAC_TX_MODE, val);
+	BNX2_WR(bp, BNX2_EMAC_TX_MODE, val);
 
 	/* Acknowledge the interrupt. */
-	REG_WR(bp, BNX2_EMAC_STATUS, BNX2_EMAC_STATUS_LINK_CHANGE);
+	BNX2_WR(bp, BNX2_EMAC_STATUS, BNX2_EMAC_STATUS_LINK_CHANGE);
 
 	bnx2_init_all_rx_contexts(bp);
 }
@@ -1554,7 +1554,7 @@ bnx2_set_link(struct bnx2 *bp)
 			bnx2_5706s_force_link_dn(bp, 0);
 			bp->phy_flags &= ~BNX2_PHY_FLAG_FORCED_DOWN;
 		}
-		val = REG_RD(bp, BNX2_EMAC_STATUS);
+		val = BNX2_RD(bp, BNX2_EMAC_STATUS);
 
 		bnx2_write_phy(bp, MII_BNX2_MISC_SHADOW, MISC_SHDW_AN_DBG);
 		bnx2_read_phy(bp, MII_BNX2_MISC_SHADOW, &an_dbg);
@@ -1942,8 +1942,8 @@ bnx2_send_heart_beat(struct bnx2 *bp)
 	spin_lock(&bp->indirect_lock);
 	msg = (u32) (++bp->fw_drv_pulse_wr_seq & BNX2_DRV_PULSE_SEQ_MASK);
 	addr = bp->shmem_base + BNX2_DRV_PULSE_MB;
-	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, addr);
-	REG_WR(bp, BNX2_PCICFG_REG_WINDOW, msg);
+	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, addr);
+	BNX2_WR(bp, BNX2_PCICFG_REG_WINDOW, msg);
 	spin_unlock(&bp->indirect_lock);
 }
 
@@ -2269,7 +2269,7 @@ bnx2_init_5706s_phy(struct bnx2 *bp, int reset_phy)
 	bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5706)
-        	REG_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
+		BNX2_WR(bp, BNX2_MISC_GP_HW_CTL0, 0x300);
 
 	if (bp->dev->mtu > 1500) {
 		u32 val;
@@ -2368,7 +2368,7 @@ __acquires(&bp->phy_lock)
 	bp->mii_adv = MII_ADVERTISE;
 	bp->mii_lpa = MII_LPA;
 
-        REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
+	BNX2_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 		goto setup_phy;
@@ -2402,10 +2402,10 @@ bnx2_set_mac_loopback(struct bnx2 *bp)
 {
 	u32 mac_mode;
 
-	mac_mode = REG_RD(bp, BNX2_EMAC_MODE);
+	mac_mode = BNX2_RD(bp, BNX2_EMAC_MODE);
 	mac_mode &= ~BNX2_EMAC_MODE_PORT;
 	mac_mode |= BNX2_EMAC_MODE_MAC_LOOP | BNX2_EMAC_MODE_FORCE_LINK;
-	REG_WR(bp, BNX2_EMAC_MODE, mac_mode);
+	BNX2_WR(bp, BNX2_EMAC_MODE, mac_mode);
 	bp->link_up = 1;
 	return 0;
 }
@@ -2431,13 +2431,13 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 		msleep(100);
 	}
 
-	mac_mode = REG_RD(bp, BNX2_EMAC_MODE);
+	mac_mode = BNX2_RD(bp, BNX2_EMAC_MODE);
 	mac_mode &= ~(BNX2_EMAC_MODE_PORT | BNX2_EMAC_MODE_HALF_DUPLEX |
 		      BNX2_EMAC_MODE_MAC_LOOP | BNX2_EMAC_MODE_FORCE_LINK |
 		      BNX2_EMAC_MODE_25G_MODE);
 
 	mac_mode |= BNX2_EMAC_MODE_PORT_GMII;
-	REG_WR(bp, BNX2_EMAC_MODE, mac_mode);
+	BNX2_WR(bp, BNX2_EMAC_MODE, mac_mode);
 	bp->link_up = 1;
 	return 0;
 }
@@ -2539,9 +2539,9 @@ bnx2_init_5709_context(struct bnx2 *bp)
 
 	val = BNX2_CTX_COMMAND_ENABLED | BNX2_CTX_COMMAND_MEM_INIT | (1 << 12);
 	val |= (BCM_PAGE_BITS - 8) << 16;
-	REG_WR(bp, BNX2_CTX_COMMAND, val);
+	BNX2_WR(bp, BNX2_CTX_COMMAND, val);
 	for (i = 0; i < 10; i++) {
-		val = REG_RD(bp, BNX2_CTX_COMMAND);
+		val = BNX2_RD(bp, BNX2_CTX_COMMAND);
 		if (!(val & BNX2_CTX_COMMAND_MEM_INIT))
 			break;
 		udelay(2);
@@ -2557,16 +2557,16 @@ bnx2_init_5709_context(struct bnx2 *bp)
 		else
 			return -ENOMEM;
 
-		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA0,
-		       (bp->ctx_blk_mapping[i] & 0xffffffff) |
-		       BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID);
-		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA1,
-		       (u64) bp->ctx_blk_mapping[i] >> 32);
-		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL, i |
-		       BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ);
+		BNX2_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA0,
+			(bp->ctx_blk_mapping[i] & 0xffffffff) |
+			BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID);
+		BNX2_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA1,
+			(u64) bp->ctx_blk_mapping[i] >> 32);
+		BNX2_WR(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL, i |
+			BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ);
 		for (j = 0; j < 10; j++) {
 
-			val = REG_RD(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL);
+			val = BNX2_RD(bp, BNX2_CTX_HOST_PAGE_TBL_CTRL);
 			if (!(val & BNX2_CTX_HOST_PAGE_TBL_CTRL_WRITE_REQ))
 				break;
 			udelay(5);
@@ -2612,8 +2612,8 @@ bnx2_init_context(struct bnx2 *bp)
 			vcid_addr += (i << PHY_CTX_SHIFT);
 			pcid_addr += (i << PHY_CTX_SHIFT);
 
-			REG_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
-			REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
+			BNX2_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
+			BNX2_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
 
 			/* Zero out the context. */
 			for (offset = 0; offset < PHY_CTX_SIZE; offset += 4)
@@ -2633,7 +2633,7 @@ bnx2_alloc_bad_rbuf(struct bnx2 *bp)
 	if (good_mbuf == NULL)
 		return -ENOMEM;
 
-	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
+	BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
 		BNX2_MISC_ENABLE_SET_BITS_RX_MBUF_ENABLE);
 
 	good_mbuf_cnt = 0;
@@ -2678,12 +2678,12 @@ bnx2_set_mac_addr(struct bnx2 *bp, u8 *mac_addr, u32 pos)
 
 	val = (mac_addr[0] << 8) | mac_addr[1];
 
-	REG_WR(bp, BNX2_EMAC_MAC_MATCH0 + (pos * 8), val);
+	BNX2_WR(bp, BNX2_EMAC_MAC_MATCH0 + (pos * 8), val);
 
 	val = (mac_addr[2] << 24) | (mac_addr[3] << 16) |
 		(mac_addr[4] << 8) | mac_addr[5];
 
-	REG_WR(bp, BNX2_EMAC_MAC_MATCH1 + (pos * 8), val);
+	BNX2_WR(bp, BNX2_EMAC_MAC_MATCH1 + (pos * 8), val);
 }
 
 static inline int
@@ -2770,9 +2770,9 @@ bnx2_phy_event_is_set(struct bnx2 *bp, struct bnx2_napi *bnapi, u32 event)
 	old_link_state = sblk->status_attn_bits_ack & event;
 	if (new_link_state != old_link_state) {
 		if (new_link_state)
-			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_SET_CMD, event);
+			BNX2_WR(bp, BNX2_PCICFG_STATUS_BIT_SET_CMD, event);
 		else
-			REG_WR(bp, BNX2_PCICFG_STATUS_BIT_CLEAR_CMD, event);
+			BNX2_WR(bp, BNX2_PCICFG_STATUS_BIT_CLEAR_CMD, event);
 	} else
 		is_set = 0;
 
@@ -3255,11 +3255,11 @@ next_rx:
 	rxr->rx_prod = sw_prod;
 
 	if (pg_ring_used)
-		REG_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
+		BNX2_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
 
-	REG_WR16(bp, rxr->rx_bidx_addr, sw_prod);
+	BNX2_WR16(bp, rxr->rx_bidx_addr, sw_prod);
 
-	REG_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
+	BNX2_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
 
 	mmiowb();
 
@@ -3277,7 +3277,7 @@ bnx2_msi(int irq, void *dev_instance)
 	struct bnx2 *bp = bnapi->bp;
 
 	prefetch(bnapi->status_blk.msi);
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+	BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
 		BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
 
@@ -3321,18 +3321,18 @@ bnx2_interrupt(int irq, void *dev_instance)
 	 * the status block write.
 	 */
 	if ((sblk->status_idx == bnapi->last_status_idx) &&
-	    (REG_RD(bp, BNX2_PCICFG_MISC_STATUS) &
+	    (BNX2_RD(bp, BNX2_PCICFG_MISC_STATUS) &
 	     BNX2_PCICFG_MISC_STATUS_INTA_VALUE))
 		return IRQ_NONE;
 
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+	BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
 		BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
 
 	/* Read back to deassert IRQ immediately to avoid too many
 	 * spurious interrupts.
 	 */
-	REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
+	BNX2_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
 
 	/* Return here if interrupt is shared and is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
@@ -3388,14 +3388,14 @@ bnx2_chk_missed_msi(struct bnx2 *bp)
 	u32 msi_ctrl;
 
 	if (bnx2_has_work(bnapi)) {
-		msi_ctrl = REG_RD(bp, BNX2_PCICFG_MSI_CONTROL);
+		msi_ctrl = BNX2_RD(bp, BNX2_PCICFG_MSI_CONTROL);
 		if (!(msi_ctrl & BNX2_PCICFG_MSI_CONTROL_ENABLE))
 			return;
 
 		if (bnapi->last_status_idx == bp->idle_chk_status_idx) {
-			REG_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl &
-			       ~BNX2_PCICFG_MSI_CONTROL_ENABLE);
-			REG_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl);
+			BNX2_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl &
+				~BNX2_PCICFG_MSI_CONTROL_ENABLE);
+			BNX2_WR(bp, BNX2_PCICFG_MSI_CONTROL, msi_ctrl);
 			bnx2_msi(bp->irq_tbl[0].vector, bnapi);
 		}
 	}
@@ -3434,9 +3434,9 @@ static void bnx2_poll_link(struct bnx2 *bp, struct bnx2_napi *bnapi)
 		/* This is needed to take care of transient status
 		 * during link changes.
 		 */
-		REG_WR(bp, BNX2_HC_COMMAND,
-		       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
-		REG_RD(bp, BNX2_HC_COMMAND);
+		BNX2_WR(bp, BNX2_HC_COMMAND,
+			bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
+		BNX2_RD(bp, BNX2_HC_COMMAND);
 	}
 }
 
@@ -3473,9 +3473,9 @@ static int bnx2_poll_msix(struct napi_struct *napi, int budget)
 		if (likely(!bnx2_has_fast_work(bnapi))) {
 
 			napi_complete(napi);
-			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
-			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-			       bnapi->last_status_idx);
+			BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+				BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+				bnapi->last_status_idx);
 			break;
 		}
 	}
@@ -3511,19 +3511,19 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 		if (likely(!bnx2_has_work(bnapi))) {
 			napi_complete(napi);
 			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
-				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-				       bnapi->last_status_idx);
+				BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+					BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+					bnapi->last_status_idx);
 				break;
 			}
-			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-			       BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
-			       bnapi->last_status_idx);
-
-			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
-			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
-			       bnapi->last_status_idx);
+			BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+				BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+				BNX2_PCICFG_INT_ACK_CMD_MASK_INT |
+				bnapi->last_status_idx);
+
+			BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
+				BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+				bnapi->last_status_idx);
 			break;
 		}
 	}
@@ -3561,8 +3561,8 @@ bnx2_set_rx_mode(struct net_device *dev)
 	}
 	else if (dev->flags & IFF_ALLMULTI) {
 		for (i = 0; i < NUM_MC_HASH_REGISTERS; i++) {
-			REG_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
-			       0xffffffff);
+			BNX2_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
+				0xffffffff);
         	}
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_EN;
 	}
@@ -3584,8 +3584,8 @@ bnx2_set_rx_mode(struct net_device *dev)
 		}
 
 		for (i = 0; i < NUM_MC_HASH_REGISTERS; i++) {
-			REG_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
-			       mc_filter[i]);
+			BNX2_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
+				mc_filter[i]);
 		}
 
 		sort_mode |= BNX2_RPM_SORT_USER0_MC_HSH_EN;
@@ -3610,12 +3610,12 @@ bnx2_set_rx_mode(struct net_device *dev)
 
 	if (rx_mode != bp->rx_mode) {
 		bp->rx_mode = rx_mode;
-		REG_WR(bp, BNX2_EMAC_RX_MODE, rx_mode);
+		BNX2_WR(bp, BNX2_EMAC_RX_MODE, rx_mode);
 	}
 
-	REG_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
-	REG_WR(bp, BNX2_RPM_SORT_USER0, sort_mode);
-	REG_WR(bp, BNX2_RPM_SORT_USER0, sort_mode | BNX2_RPM_SORT_USER0_ENA);
+	BNX2_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
+	BNX2_WR(bp, BNX2_RPM_SORT_USER0, sort_mode);
+	BNX2_WR(bp, BNX2_RPM_SORT_USER0, sort_mode | BNX2_RPM_SORT_USER0_ENA);
 
 	spin_unlock_bh(&bp->phy_lock);
 }
@@ -3756,13 +3756,13 @@ load_rv2p_fw(struct bnx2 *bp, u32 rv2p_proc,
 	}
 
 	for (i = 0; i < rv2p_code_len; i += 8) {
-		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, be32_to_cpu(*rv2p_code));
+		BNX2_WR(bp, BNX2_RV2P_INSTR_HIGH, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
-		REG_WR(bp, BNX2_RV2P_INSTR_LOW, be32_to_cpu(*rv2p_code));
+		BNX2_WR(bp, BNX2_RV2P_INSTR_LOW, be32_to_cpu(*rv2p_code));
 		rv2p_code++;
 
 		val = (i / 8) | cmd;
-		REG_WR(bp, addr, val);
+		BNX2_WR(bp, addr, val);
 	}
 
 	rv2p_code = (__be32 *)(bp->rv2p_firmware->data + file_offset);
@@ -3772,22 +3772,22 @@ load_rv2p_fw(struct bnx2 *bp, u32 rv2p_proc,
 		loc = be32_to_cpu(fw_entry->fixup[i]);
 		if (loc && ((loc * 4) < rv2p_code_len)) {
 			code = be32_to_cpu(*(rv2p_code + loc - 1));
-			REG_WR(bp, BNX2_RV2P_INSTR_HIGH, code);
+			BNX2_WR(bp, BNX2_RV2P_INSTR_HIGH, code);
 			code = be32_to_cpu(*(rv2p_code + loc));
 			code = rv2p_fw_fixup(rv2p_proc, i, loc, code);
-			REG_WR(bp, BNX2_RV2P_INSTR_LOW, code);
+			BNX2_WR(bp, BNX2_RV2P_INSTR_LOW, code);
 
 			val = (loc / 2) | cmd;
-			REG_WR(bp, addr, val);
+			BNX2_WR(bp, addr, val);
 		}
 	}
 
 	/* Reset the processor, un-stall is done later. */
 	if (rv2p_proc == RV2P_PROC1) {
-		REG_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC1_RESET);
+		BNX2_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC1_RESET);
 	}
 	else {
-		REG_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC2_RESET);
+		BNX2_WR(bp, BNX2_RV2P_COMMAND, BNX2_RV2P_COMMAND_PROC2_RESET);
 	}
 
 	return 0;
@@ -3924,14 +3924,14 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 			/* delay required during transition out of D3hot */
 			msleep(20);
 
-		val = REG_RD(bp, BNX2_EMAC_MODE);
+		val = BNX2_RD(bp, BNX2_EMAC_MODE);
 		val |= BNX2_EMAC_MODE_MPKT_RCVD | BNX2_EMAC_MODE_ACPI_RCVD;
 		val &= ~BNX2_EMAC_MODE_MPKT;
-		REG_WR(bp, BNX2_EMAC_MODE, val);
+		BNX2_WR(bp, BNX2_EMAC_MODE, val);
 
-		val = REG_RD(bp, BNX2_RPM_CONFIG);
+		val = BNX2_RD(bp, BNX2_RPM_CONFIG);
 		val &= ~BNX2_RPM_CONFIG_ACPI_ENA;
-		REG_WR(bp, BNX2_RPM_CONFIG, val);
+		BNX2_WR(bp, BNX2_RPM_CONFIG, val);
 		break;
 	}
 	case PCI_D3hot: {
@@ -3963,7 +3963,7 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 
 			bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
 
-			val = REG_RD(bp, BNX2_EMAC_MODE);
+			val = BNX2_RD(bp, BNX2_EMAC_MODE);
 
 			/* Enable port mode. */
 			val &= ~BNX2_EMAC_MODE_PORT;
@@ -3978,32 +3978,32 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 					val |= BNX2_EMAC_MODE_25G_MODE;
 			}
 
-			REG_WR(bp, BNX2_EMAC_MODE, val);
+			BNX2_WR(bp, BNX2_EMAC_MODE, val);
 
 			/* receive all multicast */
 			for (i = 0; i < NUM_MC_HASH_REGISTERS; i++) {
-				REG_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
-				       0xffffffff);
+				BNX2_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
+					0xffffffff);
 			}
-			REG_WR(bp, BNX2_EMAC_RX_MODE,
-			       BNX2_EMAC_RX_MODE_SORT_MODE);
+			BNX2_WR(bp, BNX2_EMAC_RX_MODE,
+				BNX2_EMAC_RX_MODE_SORT_MODE);
 
 			val = 1 | BNX2_RPM_SORT_USER0_BC_EN |
 			      BNX2_RPM_SORT_USER0_MC_EN;
-			REG_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
-			REG_WR(bp, BNX2_RPM_SORT_USER0, val);
-			REG_WR(bp, BNX2_RPM_SORT_USER0, val |
-			       BNX2_RPM_SORT_USER0_ENA);
+			BNX2_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
+			BNX2_WR(bp, BNX2_RPM_SORT_USER0, val);
+			BNX2_WR(bp, BNX2_RPM_SORT_USER0, val |
+				BNX2_RPM_SORT_USER0_ENA);
 
 			/* Need to enable EMAC and RPM for WOL. */
-			REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
-			       BNX2_MISC_ENABLE_SET_BITS_RX_PARSER_MAC_ENABLE |
-			       BNX2_MISC_ENABLE_SET_BITS_TX_HEADER_Q_ENABLE |
-			       BNX2_MISC_ENABLE_SET_BITS_EMAC_ENABLE);
+			BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
+				BNX2_MISC_ENABLE_SET_BITS_RX_PARSER_MAC_ENABLE |
+				BNX2_MISC_ENABLE_SET_BITS_TX_HEADER_Q_ENABLE |
+				BNX2_MISC_ENABLE_SET_BITS_EMAC_ENABLE);
 
-			val = REG_RD(bp, BNX2_RPM_CONFIG);
+			val = BNX2_RD(bp, BNX2_RPM_CONFIG);
 			val &= ~BNX2_RPM_CONFIG_ACPI_ENA;
-			REG_WR(bp, BNX2_RPM_CONFIG, val);
+			BNX2_WR(bp, BNX2_RPM_CONFIG, val);
 
 			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
 		}
@@ -4050,9 +4050,9 @@ bnx2_acquire_nvram_lock(struct bnx2 *bp)
 	int j;
 
 	/* Request access to the flash interface. */
-	REG_WR(bp, BNX2_NVM_SW_ARB, BNX2_NVM_SW_ARB_ARB_REQ_SET2);
+	BNX2_WR(bp, BNX2_NVM_SW_ARB, BNX2_NVM_SW_ARB_ARB_REQ_SET2);
 	for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
-		val = REG_RD(bp, BNX2_NVM_SW_ARB);
+		val = BNX2_RD(bp, BNX2_NVM_SW_ARB);
 		if (val & BNX2_NVM_SW_ARB_ARB_ARB2)
 			break;
 
@@ -4072,10 +4072,10 @@ bnx2_release_nvram_lock(struct bnx2 *bp)
 	u32 val;
 
 	/* Relinquish nvram interface. */
-	REG_WR(bp, BNX2_NVM_SW_ARB, BNX2_NVM_SW_ARB_ARB_REQ_CLR2);
+	BNX2_WR(bp, BNX2_NVM_SW_ARB, BNX2_NVM_SW_ARB_ARB_REQ_CLR2);
 
 	for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
-		val = REG_RD(bp, BNX2_NVM_SW_ARB);
+		val = BNX2_RD(bp, BNX2_NVM_SW_ARB);
 		if (!(val & BNX2_NVM_SW_ARB_ARB_ARB2))
 			break;
 
@@ -4094,20 +4094,20 @@ bnx2_enable_nvram_write(struct bnx2 *bp)
 {
 	u32 val;
 
-	val = REG_RD(bp, BNX2_MISC_CFG);
-	REG_WR(bp, BNX2_MISC_CFG, val | BNX2_MISC_CFG_NVM_WR_EN_PCI);
+	val = BNX2_RD(bp, BNX2_MISC_CFG);
+	BNX2_WR(bp, BNX2_MISC_CFG, val | BNX2_MISC_CFG_NVM_WR_EN_PCI);
 
 	if (bp->flash_info->flags & BNX2_NV_WREN) {
 		int j;
 
-		REG_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
-		REG_WR(bp, BNX2_NVM_COMMAND,
-		       BNX2_NVM_COMMAND_WREN | BNX2_NVM_COMMAND_DOIT);
+		BNX2_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
+		BNX2_WR(bp, BNX2_NVM_COMMAND,
+			BNX2_NVM_COMMAND_WREN | BNX2_NVM_COMMAND_DOIT);
 
 		for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
 			udelay(5);
 
-			val = REG_RD(bp, BNX2_NVM_COMMAND);
+			val = BNX2_RD(bp, BNX2_NVM_COMMAND);
 			if (val & BNX2_NVM_COMMAND_DONE)
 				break;
 		}
@@ -4123,8 +4123,8 @@ bnx2_disable_nvram_write(struct bnx2 *bp)
 {
 	u32 val;
 
-	val = REG_RD(bp, BNX2_MISC_CFG);
-	REG_WR(bp, BNX2_MISC_CFG, val & ~BNX2_MISC_CFG_NVM_WR_EN);
+	val = BNX2_RD(bp, BNX2_MISC_CFG);
+	BNX2_WR(bp, BNX2_MISC_CFG, val & ~BNX2_MISC_CFG_NVM_WR_EN);
 }
 
 
@@ -4133,10 +4133,10 @@ bnx2_enable_nvram_access(struct bnx2 *bp)
 {
 	u32 val;
 
-	val = REG_RD(bp, BNX2_NVM_ACCESS_ENABLE);
+	val = BNX2_RD(bp, BNX2_NVM_ACCESS_ENABLE);
 	/* Enable both bits, even on read. */
-	REG_WR(bp, BNX2_NVM_ACCESS_ENABLE,
-	       val | BNX2_NVM_ACCESS_ENABLE_EN | BNX2_NVM_ACCESS_ENABLE_WR_EN);
+	BNX2_WR(bp, BNX2_NVM_ACCESS_ENABLE,
+		val | BNX2_NVM_ACCESS_ENABLE_EN | BNX2_NVM_ACCESS_ENABLE_WR_EN);
 }
 
 static void
@@ -4144,9 +4144,9 @@ bnx2_disable_nvram_access(struct bnx2 *bp)
 {
 	u32 val;
 
-	val = REG_RD(bp, BNX2_NVM_ACCESS_ENABLE);
+	val = BNX2_RD(bp, BNX2_NVM_ACCESS_ENABLE);
 	/* Disable both bits, even after read. */
-	REG_WR(bp, BNX2_NVM_ACCESS_ENABLE,
+	BNX2_WR(bp, BNX2_NVM_ACCESS_ENABLE,
 		val & ~(BNX2_NVM_ACCESS_ENABLE_EN |
 			BNX2_NVM_ACCESS_ENABLE_WR_EN));
 }
@@ -4166,13 +4166,13 @@ bnx2_nvram_erase_page(struct bnx2 *bp, u32 offset)
 	      BNX2_NVM_COMMAND_DOIT;
 
 	/* Need to clear DONE bit separately. */
-	REG_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
 
 	/* Address of the NVRAM to read from. */
-	REG_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
+	BNX2_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
 
 	/* Issue an erase command. */
-	REG_WR(bp, BNX2_NVM_COMMAND, cmd);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, cmd);
 
 	/* Wait for completion. */
 	for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
@@ -4180,7 +4180,7 @@ bnx2_nvram_erase_page(struct bnx2 *bp, u32 offset)
 
 		udelay(5);
 
-		val = REG_RD(bp, BNX2_NVM_COMMAND);
+		val = BNX2_RD(bp, BNX2_NVM_COMMAND);
 		if (val & BNX2_NVM_COMMAND_DONE)
 			break;
 	}
@@ -4208,13 +4208,13 @@ bnx2_nvram_read_dword(struct bnx2 *bp, u32 offset, u8 *ret_val, u32 cmd_flags)
 	}
 
 	/* Need to clear DONE bit separately. */
-	REG_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
 
 	/* Address of the NVRAM to read from. */
-	REG_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
+	BNX2_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
 
 	/* Issue a read command. */
-	REG_WR(bp, BNX2_NVM_COMMAND, cmd);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, cmd);
 
 	/* Wait for completion. */
 	for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
@@ -4222,9 +4222,9 @@ bnx2_nvram_read_dword(struct bnx2 *bp, u32 offset, u8 *ret_val, u32 cmd_flags)
 
 		udelay(5);
 
-		val = REG_RD(bp, BNX2_NVM_COMMAND);
+		val = BNX2_RD(bp, BNX2_NVM_COMMAND);
 		if (val & BNX2_NVM_COMMAND_DONE) {
-			__be32 v = cpu_to_be32(REG_RD(bp, BNX2_NVM_READ));
+			__be32 v = cpu_to_be32(BNX2_RD(bp, BNX2_NVM_READ));
 			memcpy(ret_val, &v, 4);
 			break;
 		}
@@ -4254,24 +4254,24 @@ bnx2_nvram_write_dword(struct bnx2 *bp, u32 offset, u8 *val, u32 cmd_flags)
 	}
 
 	/* Need to clear DONE bit separately. */
-	REG_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, BNX2_NVM_COMMAND_DONE);
 
 	memcpy(&val32, val, 4);
 
 	/* Write the data. */
-	REG_WR(bp, BNX2_NVM_WRITE, be32_to_cpu(val32));
+	BNX2_WR(bp, BNX2_NVM_WRITE, be32_to_cpu(val32));
 
 	/* Address of the NVRAM to write to. */
-	REG_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
+	BNX2_WR(bp, BNX2_NVM_ADDR, offset & BNX2_NVM_ADDR_NVM_ADDR_VALUE);
 
 	/* Issue the write command. */
-	REG_WR(bp, BNX2_NVM_COMMAND, cmd);
+	BNX2_WR(bp, BNX2_NVM_COMMAND, cmd);
 
 	/* Wait for completion. */
 	for (j = 0; j < NVRAM_TIMEOUT_COUNT; j++) {
 		udelay(5);
 
-		if (REG_RD(bp, BNX2_NVM_COMMAND) & BNX2_NVM_COMMAND_DONE)
+		if (BNX2_RD(bp, BNX2_NVM_COMMAND) & BNX2_NVM_COMMAND_DONE)
 			break;
 	}
 	if (j >= NVRAM_TIMEOUT_COUNT)
@@ -4293,7 +4293,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 	}
 
 	/* Determine the selected interface. */
-	val = REG_RD(bp, BNX2_NVM_CFG1);
+	val = BNX2_RD(bp, BNX2_NVM_CFG1);
 
 	entry_count = ARRAY_SIZE(flash_table);
 
@@ -4332,10 +4332,10 @@ bnx2_init_nvram(struct bnx2 *bp)
 				bnx2_enable_nvram_access(bp);
 
 				/* Reconfigure the flash interface */
-				REG_WR(bp, BNX2_NVM_CFG1, flash->config1);
-				REG_WR(bp, BNX2_NVM_CFG2, flash->config2);
-				REG_WR(bp, BNX2_NVM_CFG3, flash->config3);
-				REG_WR(bp, BNX2_NVM_WRITE1, flash->write1);
+				BNX2_WR(bp, BNX2_NVM_CFG1, flash->config1);
+				BNX2_WR(bp, BNX2_NVM_CFG2, flash->config2);
+				BNX2_WR(bp, BNX2_NVM_CFG3, flash->config3);
+				BNX2_WR(bp, BNX2_NVM_WRITE1, flash->write1);
 
 				/* Disable access to flash interface */
 				bnx2_disable_nvram_access(bp);
@@ -4696,10 +4696,10 @@ bnx2_init_fw_cap(struct bnx2 *bp)
 static void
 bnx2_setup_msix_tbl(struct bnx2 *bp)
 {
-	REG_WR(bp, BNX2_PCI_GRC_WINDOW_ADDR, BNX2_PCI_GRC_WINDOW_ADDR_SEP_WIN);
+	BNX2_WR(bp, BNX2_PCI_GRC_WINDOW_ADDR, BNX2_PCI_GRC_WINDOW_ADDR_SEP_WIN);
 
-	REG_WR(bp, BNX2_PCI_GRC_WINDOW2_ADDR, BNX2_MSIX_TABLE_ADDR);
-	REG_WR(bp, BNX2_PCI_GRC_WINDOW3_ADDR, BNX2_MSIX_PBA_ADDR);
+	BNX2_WR(bp, BNX2_PCI_GRC_WINDOW2_ADDR, BNX2_MSIX_TABLE_ADDR);
+	BNX2_WR(bp, BNX2_PCI_GRC_WINDOW3_ADDR, BNX2_MSIX_PBA_ADDR);
 }
 
 static int
@@ -4713,22 +4713,22 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	 * issuing a reset. */
 	if ((CHIP_NUM(bp) == CHIP_NUM_5706) ||
 	    (CHIP_NUM(bp) == CHIP_NUM_5708)) {
-		REG_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
-		       BNX2_MISC_ENABLE_CLR_BITS_TX_DMA_ENABLE |
-		       BNX2_MISC_ENABLE_CLR_BITS_DMA_ENGINE_ENABLE |
-		       BNX2_MISC_ENABLE_CLR_BITS_RX_DMA_ENABLE |
-		       BNX2_MISC_ENABLE_CLR_BITS_HOST_COALESCE_ENABLE);
-		val = REG_RD(bp, BNX2_MISC_ENABLE_CLR_BITS);
+		BNX2_WR(bp, BNX2_MISC_ENABLE_CLR_BITS,
+			BNX2_MISC_ENABLE_CLR_BITS_TX_DMA_ENABLE |
+			BNX2_MISC_ENABLE_CLR_BITS_DMA_ENGINE_ENABLE |
+			BNX2_MISC_ENABLE_CLR_BITS_RX_DMA_ENABLE |
+			BNX2_MISC_ENABLE_CLR_BITS_HOST_COALESCE_ENABLE);
+		val = BNX2_RD(bp, BNX2_MISC_ENABLE_CLR_BITS);
 		udelay(5);
 	} else {  /* 5709 */
-		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+		val = BNX2_RD(bp, BNX2_MISC_NEW_CORE_CTL);
 		val &= ~BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE;
-		REG_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
-		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+		BNX2_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
+		val = BNX2_RD(bp, BNX2_MISC_NEW_CORE_CTL);
 
 		for (i = 0; i < 100; i++) {
 			msleep(1);
-			val = REG_RD(bp, BNX2_PCICFG_DEVICE_CONTROL);
+			val = BNX2_RD(bp, BNX2_PCICFG_DEVICE_CONTROL);
 			if (!(val & BNX2_PCICFG_DEVICE_STATUS_NO_PEND))
 				break;
 		}
@@ -4744,17 +4744,17 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 	/* Do a dummy read to force the chip to complete all current transaction
 	 * before we issue a reset. */
-	val = REG_RD(bp, BNX2_MISC_ID);
+	val = BNX2_RD(bp, BNX2_MISC_ID);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		REG_WR(bp, BNX2_MISC_COMMAND, BNX2_MISC_COMMAND_SW_RESET);
-		REG_RD(bp, BNX2_MISC_COMMAND);
+		BNX2_WR(bp, BNX2_MISC_COMMAND, BNX2_MISC_COMMAND_SW_RESET);
+		BNX2_RD(bp, BNX2_MISC_COMMAND);
 		udelay(5);
 
 		val = BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
 		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
 
-		REG_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+		BNX2_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
 
 	} else {
 		val = BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
@@ -4762,7 +4762,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 		      BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP;
 
 		/* Chip reset. */
-		REG_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
+		BNX2_WR(bp, BNX2_PCICFG_MISC_CONFIG, val);
 
 		/* Reading back any register after chip reset will hang the
 		 * bus on 5706 A0 and A1.  The msleep below provides plenty
@@ -4774,7 +4774,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 
 		/* Reset takes approximate 30 usec */
 		for (i = 0; i < 10; i++) {
-			val = REG_RD(bp, BNX2_PCICFG_MISC_CONFIG);
+			val = BNX2_RD(bp, BNX2_PCICFG_MISC_CONFIG);
 			if ((val & (BNX2_PCICFG_MISC_CONFIG_CORE_RST_REQ |
 				    BNX2_PCICFG_MISC_CONFIG_CORE_RST_BSY)) == 0)
 				break;
@@ -4789,7 +4789,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	}
 
 	/* Make sure byte swapping is properly configured. */
-	val = REG_RD(bp, BNX2_PCI_SWAP_DIAG0);
+	val = BNX2_RD(bp, BNX2_PCI_SWAP_DIAG0);
 	if (val != 0x01020304) {
 		pr_err("Chip not in correct endian mode\n");
 		return -ENODEV;
@@ -4811,7 +4811,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
 		/* Adjust the voltage regular to two steps lower.  The default
 		 * of this register is 0x0000000e. */
-		REG_WR(bp, BNX2_MISC_VREG_CONTROL, 0x000000fa);
+		BNX2_WR(bp, BNX2_MISC_VREG_CONTROL, 0x000000fa);
 
 		/* Remove bad rbuf memory from the free pool. */
 		rc = bnx2_alloc_bad_rbuf(bp);
@@ -4820,7 +4820,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	if (bp->flags & BNX2_FLAG_USING_MSIX) {
 		bnx2_setup_msix_tbl(bp);
 		/* Prevent MSIX table reads and write from timing out */
-		REG_WR(bp, BNX2_MISC_ECO_HW_CTL,
+		BNX2_WR(bp, BNX2_MISC_ECO_HW_CTL,
 			BNX2_MISC_ECO_HW_CTL_LARGE_GRC_TMOUT_EN);
 	}
 
@@ -4834,7 +4834,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	int rc, i;
 
 	/* Make sure the interrupt is not active. */
-	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
+	BNX2_WR(bp, BNX2_PCICFG_INT_ACK_CMD, BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
 
 	val = BNX2_DMA_CONFIG_DATA_BYTE_SWAP |
 	      BNX2_DMA_CONFIG_DATA_WORD_SWAP |
@@ -4854,12 +4854,12 @@ bnx2_init_chip(struct bnx2 *bp)
 	    (CHIP_ID(bp) != CHIP_ID_5706_A0) && !(bp->flags & BNX2_FLAG_PCIX))
 		val |= BNX2_DMA_CONFIG_CNTL_PING_PONG_DMA;
 
-	REG_WR(bp, BNX2_DMA_CONFIG, val);
+	BNX2_WR(bp, BNX2_DMA_CONFIG, val);
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
-		val = REG_RD(bp, BNX2_TDMA_CONFIG);
+		val = BNX2_RD(bp, BNX2_TDMA_CONFIG);
 		val |= BNX2_TDMA_CONFIG_ONE_DMA;
-		REG_WR(bp, BNX2_TDMA_CONFIG, val);
+		BNX2_WR(bp, BNX2_TDMA_CONFIG, val);
 	}
 
 	if (bp->flags & BNX2_FLAG_PCIX) {
@@ -4871,10 +4871,10 @@ bnx2_init_chip(struct bnx2 *bp)
 				      val16 & ~PCI_X_CMD_ERO);
 	}
 
-	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
-	       BNX2_MISC_ENABLE_SET_BITS_HOST_COALESCE_ENABLE |
-	       BNX2_MISC_ENABLE_STATUS_BITS_RX_V2P_ENABLE |
-	       BNX2_MISC_ENABLE_STATUS_BITS_CONTEXT_ENABLE);
+	BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
+		BNX2_MISC_ENABLE_SET_BITS_HOST_COALESCE_ENABLE |
+		BNX2_MISC_ENABLE_STATUS_BITS_RX_V2P_ENABLE |
+		BNX2_MISC_ENABLE_STATUS_BITS_CONTEXT_ENABLE);
 
 	/* Initialize context mapping and zero out the quick contexts.  The
 	 * context block must have already been enabled. */
@@ -4892,7 +4892,7 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
 
-	val = REG_RD(bp, BNX2_MQ_CONFIG);
+	val = BNX2_RD(bp, BNX2_MQ_CONFIG);
 	val &= ~BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE;
 	val |= BNX2_MQ_CONFIG_KNL_BYP_BLK_SIZE_256;
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
@@ -4901,20 +4901,20 @@ bnx2_init_chip(struct bnx2 *bp)
 			val |= BNX2_MQ_CONFIG_HALT_DIS;
 	}
 
-	REG_WR(bp, BNX2_MQ_CONFIG, val);
+	BNX2_WR(bp, BNX2_MQ_CONFIG, val);
 
 	val = 0x10000 + (MAX_CID_CNT * MB_KERNEL_CTX_SIZE);
-	REG_WR(bp, BNX2_MQ_KNL_BYP_WIND_START, val);
-	REG_WR(bp, BNX2_MQ_KNL_WIND_END, val);
+	BNX2_WR(bp, BNX2_MQ_KNL_BYP_WIND_START, val);
+	BNX2_WR(bp, BNX2_MQ_KNL_WIND_END, val);
 
 	val = (BCM_PAGE_BITS - 8) << 24;
-	REG_WR(bp, BNX2_RV2P_CONFIG, val);
+	BNX2_WR(bp, BNX2_RV2P_CONFIG, val);
 
 	/* Configure page size. */
-	val = REG_RD(bp, BNX2_TBDR_CONFIG);
+	val = BNX2_RD(bp, BNX2_TBDR_CONFIG);
 	val &= ~BNX2_TBDR_CONFIG_PAGE_SIZE;
 	val |= (BCM_PAGE_BITS - 8) << 24 | 0x40;
-	REG_WR(bp, BNX2_TBDR_CONFIG, val);
+	BNX2_WR(bp, BNX2_TBDR_CONFIG, val);
 
 	val = bp->mac_addr[0] +
 	      (bp->mac_addr[1] << 8) +
@@ -4922,14 +4922,14 @@ bnx2_init_chip(struct bnx2 *bp)
 	      bp->mac_addr[3] +
 	      (bp->mac_addr[4] << 8) +
 	      (bp->mac_addr[5] << 16);
-	REG_WR(bp, BNX2_EMAC_BACKOFF_SEED, val);
+	BNX2_WR(bp, BNX2_EMAC_BACKOFF_SEED, val);
 
 	/* Program the MTU.  Also include 4 bytes for CRC32. */
 	mtu = bp->dev->mtu;
 	val = mtu + ETH_HLEN + ETH_FCS_LEN;
 	if (val > (MAX_ETHERNET_PACKET_SIZE + 4))
 		val |= BNX2_EMAC_RX_MTU_SIZE_JUMBO_ENA;
-	REG_WR(bp, BNX2_EMAC_RX_MTU_SIZE, val);
+	BNX2_WR(bp, BNX2_EMAC_RX_MTU_SIZE, val);
 
 	if (mtu < 1500)
 		mtu = 1500;
@@ -4947,41 +4947,41 @@ bnx2_init_chip(struct bnx2 *bp)
 	bp->rx_mode = BNX2_EMAC_RX_MODE_SORT_MODE;
 
 	/* Set up how to generate a link change interrupt. */
-	REG_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
+	BNX2_WR(bp, BNX2_EMAC_ATTENTION_ENA, BNX2_EMAC_ATTENTION_ENA_LINK);
 
-	REG_WR(bp, BNX2_HC_STATUS_ADDR_L,
-	       (u64) bp->status_blk_mapping & 0xffffffff);
-	REG_WR(bp, BNX2_HC_STATUS_ADDR_H, (u64) bp->status_blk_mapping >> 32);
+	BNX2_WR(bp, BNX2_HC_STATUS_ADDR_L,
+		(u64) bp->status_blk_mapping & 0xffffffff);
+	BNX2_WR(bp, BNX2_HC_STATUS_ADDR_H, (u64) bp->status_blk_mapping >> 32);
 
-	REG_WR(bp, BNX2_HC_STATISTICS_ADDR_L,
-	       (u64) bp->stats_blk_mapping & 0xffffffff);
-	REG_WR(bp, BNX2_HC_STATISTICS_ADDR_H,
-	       (u64) bp->stats_blk_mapping >> 32);
+	BNX2_WR(bp, BNX2_HC_STATISTICS_ADDR_L,
+		(u64) bp->stats_blk_mapping & 0xffffffff);
+	BNX2_WR(bp, BNX2_HC_STATISTICS_ADDR_H,
+		(u64) bp->stats_blk_mapping >> 32);
 
-	REG_WR(bp, BNX2_HC_TX_QUICK_CONS_TRIP,
-	       (bp->tx_quick_cons_trip_int << 16) | bp->tx_quick_cons_trip);
+	BNX2_WR(bp, BNX2_HC_TX_QUICK_CONS_TRIP,
+		(bp->tx_quick_cons_trip_int << 16) | bp->tx_quick_cons_trip);
 
-	REG_WR(bp, BNX2_HC_RX_QUICK_CONS_TRIP,
-	       (bp->rx_quick_cons_trip_int << 16) | bp->rx_quick_cons_trip);
+	BNX2_WR(bp, BNX2_HC_RX_QUICK_CONS_TRIP,
+		(bp->rx_quick_cons_trip_int << 16) | bp->rx_quick_cons_trip);
 
-	REG_WR(bp, BNX2_HC_COMP_PROD_TRIP,
-	       (bp->comp_prod_trip_int << 16) | bp->comp_prod_trip);
+	BNX2_WR(bp, BNX2_HC_COMP_PROD_TRIP,
+		(bp->comp_prod_trip_int << 16) | bp->comp_prod_trip);
 
-	REG_WR(bp, BNX2_HC_TX_TICKS, (bp->tx_ticks_int << 16) | bp->tx_ticks);
+	BNX2_WR(bp, BNX2_HC_TX_TICKS, (bp->tx_ticks_int << 16) | bp->tx_ticks);
 
-	REG_WR(bp, BNX2_HC_RX_TICKS, (bp->rx_ticks_int << 16) | bp->rx_ticks);
+	BNX2_WR(bp, BNX2_HC_RX_TICKS, (bp->rx_ticks_int << 16) | bp->rx_ticks);
 
-	REG_WR(bp, BNX2_HC_COM_TICKS,
-	       (bp->com_ticks_int << 16) | bp->com_ticks);
+	BNX2_WR(bp, BNX2_HC_COM_TICKS,
+		(bp->com_ticks_int << 16) | bp->com_ticks);
 
-	REG_WR(bp, BNX2_HC_CMD_TICKS,
-	       (bp->cmd_ticks_int << 16) | bp->cmd_ticks);
+	BNX2_WR(bp, BNX2_HC_CMD_TICKS,
+		(bp->cmd_ticks_int << 16) | bp->cmd_ticks);
 
 	if (bp->flags & BNX2_FLAG_BROKEN_STATS)
-		REG_WR(bp, BNX2_HC_STATS_TICKS, 0);
+		BNX2_WR(bp, BNX2_HC_STATS_TICKS, 0);
 	else
-		REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks);
-	REG_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
+		BNX2_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks);
+	BNX2_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A1)
 		val = BNX2_HC_CONFIG_COLLECT_STATS;
@@ -4991,8 +4991,8 @@ bnx2_init_chip(struct bnx2 *bp)
 	}
 
 	if (bp->flags & BNX2_FLAG_USING_MSIX) {
-		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
-		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
+		BNX2_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
+			BNX2_HC_MSIX_BIT_VECTOR_VAL);
 
 		val |= BNX2_HC_CONFIG_SB_ADDR_INC_128B;
 	}
@@ -5000,7 +5000,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	if (bp->flags & BNX2_FLAG_ONE_SHOT_MSI)
 		val |= BNX2_HC_CONFIG_ONE_SHOT | BNX2_HC_CONFIG_USE_INT_PARAM;
 
-	REG_WR(bp, BNX2_HC_CONFIG, val);
+	BNX2_WR(bp, BNX2_HC_CONFIG, val);
 
 	if (bp->rx_ticks < 25)
 		bnx2_reg_wr_ind(bp, BNX2_FW_RX_LOW_LATENCY, 1);
@@ -5011,48 +5011,48 @@ bnx2_init_chip(struct bnx2 *bp)
 		u32 base = ((i - 1) * BNX2_HC_SB_CONFIG_SIZE) +
 			   BNX2_HC_SB_CONFIG_1;
 
-		REG_WR(bp, base,
+		BNX2_WR(bp, base,
 			BNX2_HC_SB_CONFIG_1_TX_TMR_MODE |
 			BNX2_HC_SB_CONFIG_1_RX_TMR_MODE |
 			BNX2_HC_SB_CONFIG_1_ONE_SHOT);
 
-		REG_WR(bp, base + BNX2_HC_TX_QUICK_CONS_TRIP_OFF,
+		BNX2_WR(bp, base + BNX2_HC_TX_QUICK_CONS_TRIP_OFF,
 			(bp->tx_quick_cons_trip_int << 16) |
 			 bp->tx_quick_cons_trip);
 
-		REG_WR(bp, base + BNX2_HC_TX_TICKS_OFF,
+		BNX2_WR(bp, base + BNX2_HC_TX_TICKS_OFF,
 			(bp->tx_ticks_int << 16) | bp->tx_ticks);
 
-		REG_WR(bp, base + BNX2_HC_RX_QUICK_CONS_TRIP_OFF,
-		       (bp->rx_quick_cons_trip_int << 16) |
+		BNX2_WR(bp, base + BNX2_HC_RX_QUICK_CONS_TRIP_OFF,
+			(bp->rx_quick_cons_trip_int << 16) |
 			bp->rx_quick_cons_trip);
 
-		REG_WR(bp, base + BNX2_HC_RX_TICKS_OFF,
+		BNX2_WR(bp, base + BNX2_HC_RX_TICKS_OFF,
 			(bp->rx_ticks_int << 16) | bp->rx_ticks);
 	}
 
 	/* Clear internal stats counters. */
-	REG_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
+	BNX2_WR(bp, BNX2_HC_COMMAND, BNX2_HC_COMMAND_CLR_STAT_NOW);
 
-	REG_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_EVENTS);
+	BNX2_WR(bp, BNX2_HC_ATTN_BITS_ENABLE, STATUS_ATTN_EVENTS);
 
 	/* Initialize the receive filter. */
 	bnx2_set_rx_mode(bp->dev);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		val = REG_RD(bp, BNX2_MISC_NEW_CORE_CTL);
+		val = BNX2_RD(bp, BNX2_MISC_NEW_CORE_CTL);
 		val |= BNX2_MISC_NEW_CORE_CTL_DMA_ENABLE;
-		REG_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
+		BNX2_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
 	}
 	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT2 | BNX2_DRV_MSG_CODE_RESET,
 			  1, 0);
 
-	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, BNX2_MISC_ENABLE_DEFAULT);
-	REG_RD(bp, BNX2_MISC_ENABLE_SET_BITS);
+	BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS, BNX2_MISC_ENABLE_DEFAULT);
+	BNX2_RD(bp, BNX2_MISC_ENABLE_SET_BITS);
 
 	udelay(20);
 
-	bp->hc_cmd = REG_RD(bp, BNX2_HC_COMMAND);
+	bp->hc_cmd = BNX2_RD(bp, BNX2_HC_COMMAND);
 
 	return rc;
 }
@@ -5188,8 +5188,8 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 	bnx2_init_rx_context(bp, cid);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
-		val = REG_RD(bp, BNX2_MQ_MAP_L2_5);
-		REG_WR(bp, BNX2_MQ_MAP_L2_5, val | BNX2_MQ_MAP_L2_5_ARM);
+		val = BNX2_RD(bp, BNX2_MQ_MAP_L2_5);
+		BNX2_WR(bp, BNX2_MQ_MAP_L2_5, val | BNX2_MQ_MAP_L2_5_ARM);
 	}
 
 	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
@@ -5209,7 +5209,7 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
 
 		if (CHIP_NUM(bp) == CHIP_NUM_5709)
-			REG_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
+			BNX2_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
 	}
 
 	val = (u64) rxr->rx_desc_mapping[0] >> 32;
@@ -5246,10 +5246,10 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 	rxr->rx_bseq_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_HOST_BSEQ;
 	rxr->rx_pg_bidx_addr = MB_GET_CID_ADDR(cid) + BNX2_L2CTX_HOST_PG_BDIDX;
 
-	REG_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
-	REG_WR16(bp, rxr->rx_bidx_addr, prod);
+	BNX2_WR16(bp, rxr->rx_pg_bidx_addr, rxr->rx_pg_prod);
+	BNX2_WR16(bp, rxr->rx_bidx_addr, prod);
 
-	REG_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
+	BNX2_WR(bp, rxr->rx_bseq_addr, rxr->rx_prod_bseq);
 }
 
 static void
@@ -5260,15 +5260,15 @@ bnx2_init_all_rings(struct bnx2 *bp)
 
 	bnx2_clear_ring_states(bp);
 
-	REG_WR(bp, BNX2_TSCH_TSS_CFG, 0);
+	BNX2_WR(bp, BNX2_TSCH_TSS_CFG, 0);
 	for (i = 0; i < bp->num_tx_rings; i++)
 		bnx2_init_tx_ring(bp, i);
 
 	if (bp->num_tx_rings > 1)
-		REG_WR(bp, BNX2_TSCH_TSS_CFG, ((bp->num_tx_rings - 1) << 24) |
-		       (TX_TSS_CID << 7));
+		BNX2_WR(bp, BNX2_TSCH_TSS_CFG, ((bp->num_tx_rings - 1) << 24) |
+			(TX_TSS_CID << 7));
 
-	REG_WR(bp, BNX2_RLUP_RSS_CONFIG, 0);
+	BNX2_WR(bp, BNX2_RLUP_RSS_CONFIG, 0);
 	bnx2_reg_wr_ind(bp, BNX2_RXP_SCRATCH_RSS_TBL_SZ, 0);
 
 	for (i = 0; i < bp->num_rx_rings; i++)
@@ -5282,8 +5282,8 @@ bnx2_init_all_rings(struct bnx2 *bp)
 
 			tbl_32 |= (i % (bp->num_rx_rings - 1)) << shift;
 			if ((i % 8) == 7) {
-				REG_WR(bp, BNX2_RLUP_RSS_DATA, tbl_32);
-				REG_WR(bp, BNX2_RLUP_RSS_COMMAND, (i >> 3) |
+				BNX2_WR(bp, BNX2_RLUP_RSS_DATA, tbl_32);
+				BNX2_WR(bp, BNX2_RLUP_RSS_COMMAND, (i >> 3) |
 					BNX2_RLUP_RSS_COMMAND_RSS_WRITE_MASK |
 					BNX2_RLUP_RSS_COMMAND_WRITE |
 					BNX2_RLUP_RSS_COMMAND_HASH_MASK);
@@ -5294,7 +5294,7 @@ bnx2_init_all_rings(struct bnx2 *bp)
 		val = BNX2_RLUP_RSS_CONFIG_IPV4_RSS_TYPE_ALL_XI |
 		      BNX2_RLUP_RSS_CONFIG_IPV6_RSS_TYPE_ALL_XI;
 
-		REG_WR(bp, BNX2_RLUP_RSS_CONFIG, val);
+		BNX2_WR(bp, BNX2_RLUP_RSS_CONFIG, val);
 
 	}
 }
@@ -5784,10 +5784,10 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 		return -EIO;
 	}
 
-	REG_WR(bp, BNX2_HC_COMMAND,
-	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
+	BNX2_WR(bp, BNX2_HC_COMMAND,
+		bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
 
-	REG_RD(bp, BNX2_HC_COMMAND);
+	BNX2_RD(bp, BNX2_HC_COMMAND);
 
 	udelay(5);
 	rx_start_idx = bnx2_get_hw_rx_cons(bnapi);
@@ -5805,15 +5805,15 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	txr->tx_prod = NEXT_TX_BD(txr->tx_prod);
 	txr->tx_prod_bseq += pkt_size;
 
-	REG_WR16(bp, txr->tx_bidx_addr, txr->tx_prod);
-	REG_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
+	BNX2_WR16(bp, txr->tx_bidx_addr, txr->tx_prod);
+	BNX2_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
 
 	udelay(100);
 
-	REG_WR(bp, BNX2_HC_COMMAND,
-	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
+	BNX2_WR(bp, BNX2_HC_COMMAND,
+		bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
 
-	REG_RD(bp, BNX2_HC_COMMAND);
+	BNX2_RD(bp, BNX2_HC_COMMAND);
 
 	udelay(5);
 
@@ -5962,14 +5962,14 @@ bnx2_test_intr(struct bnx2 *bp)
 	if (!netif_running(bp->dev))
 		return -ENODEV;
 
-	status_idx = REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD) & 0xffff;
+	status_idx = BNX2_RD(bp, BNX2_PCICFG_INT_ACK_CMD) & 0xffff;
 
 	/* This register is not touched during run-time. */
-	REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW);
-	REG_RD(bp, BNX2_HC_COMMAND);
+	BNX2_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW);
+	BNX2_RD(bp, BNX2_HC_COMMAND);
 
 	for (i = 0; i < 10; i++) {
-		if ((REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD) & 0xffff) !=
+		if ((BNX2_RD(bp, BNX2_PCICFG_INT_ACK_CMD) & 0xffff) !=
 			status_idx) {
 
 			break;
@@ -6132,8 +6132,8 @@ bnx2_timer(unsigned long data)
 
 	/* workaround occasional corrupted counters */
 	if ((bp->flags & BNX2_FLAG_BROKEN_STATS) && bp->stats_ticks)
-		REG_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
-					    BNX2_HC_COMMAND_STATS_NOW);
+		BNX2_WR(bp, BNX2_HC_COMMAND, bp->hc_cmd |
+			BNX2_HC_COMMAND_STATS_NOW);
 
 	if (bp->phy_flags & BNX2_PHY_FLAG_SERDES) {
 		if (CHIP_NUM(bp) == CHIP_NUM_5706)
@@ -6205,13 +6205,13 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 	const int len = sizeof(bp->irq_tbl[0].name);
 
 	bnx2_setup_msix_tbl(bp);
-	REG_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
-	REG_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
-	REG_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
+	BNX2_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
+	BNX2_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
+	BNX2_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
 
 	/*  Need to flush the previous three writes to ensure MSI-X
 	 *  is setup properly */
-	REG_RD(bp, BNX2_PCI_MSIX_CONTROL);
+	BNX2_RD(bp, BNX2_PCI_MSIX_CONTROL);
 
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
 		msix_ent[i].entry = i;
@@ -6464,22 +6464,22 @@ bnx2_dump_ftq(struct bnx2 *bp)
 	netdev_err(dev, "<--- end FTQ dump --->\n");
 	netdev_err(dev, "<--- start TBDC dump --->\n");
 	netdev_err(dev, "TBDC free cnt: %ld\n",
-		   REG_RD(bp, BNX2_TBDC_STATUS) & BNX2_TBDC_STATUS_FREE_CNT);
+		   BNX2_RD(bp, BNX2_TBDC_STATUS) & BNX2_TBDC_STATUS_FREE_CNT);
 	netdev_err(dev, "LINE     CID  BIDX   CMD  VALIDS\n");
 	for (i = 0; i < 0x20; i++) {
 		int j = 0;
 
-		REG_WR(bp, BNX2_TBDC_BD_ADDR, i);
-		REG_WR(bp, BNX2_TBDC_CAM_OPCODE,
-		       BNX2_TBDC_CAM_OPCODE_OPCODE_CAM_READ);
-		REG_WR(bp, BNX2_TBDC_COMMAND, BNX2_TBDC_COMMAND_CMD_REG_ARB);
-		while ((REG_RD(bp, BNX2_TBDC_COMMAND) &
+		BNX2_WR(bp, BNX2_TBDC_BD_ADDR, i);
+		BNX2_WR(bp, BNX2_TBDC_CAM_OPCODE,
+			BNX2_TBDC_CAM_OPCODE_OPCODE_CAM_READ);
+		BNX2_WR(bp, BNX2_TBDC_COMMAND, BNX2_TBDC_COMMAND_CMD_REG_ARB);
+		while ((BNX2_RD(bp, BNX2_TBDC_COMMAND) &
 			BNX2_TBDC_COMMAND_CMD_REG_ARB) && j < 100)
 			j++;
 
-		cid = REG_RD(bp, BNX2_TBDC_CID);
-		bdidx = REG_RD(bp, BNX2_TBDC_BIDX);
-		valid = REG_RD(bp, BNX2_TBDC_CAM_OPCODE);
+		cid = BNX2_RD(bp, BNX2_TBDC_CID);
+		bdidx = BNX2_RD(bp, BNX2_TBDC_BIDX);
+		valid = BNX2_RD(bp, BNX2_TBDC_CAM_OPCODE);
 		netdev_err(dev, "%02x    %06x  %04lx   %02x    [%x]\n",
 			   i, cid, bdidx & BNX2_TBDC_BDIDX_BDIDX,
 			   bdidx >> 24, (valid >> 8) & 0x0ff);
@@ -6500,15 +6500,15 @@ bnx2_dump_state(struct bnx2 *bp)
 	pci_read_config_dword(bp->pdev, BNX2_PCICFG_MISC_CONFIG, &val2);
 	netdev_err(dev, "DEBUG: PCI_PM[%08x] PCI_MISC_CFG[%08x]\n", val1, val2);
 	netdev_err(dev, "DEBUG: EMAC_TX_STATUS[%08x] EMAC_RX_STATUS[%08x]\n",
-		   REG_RD(bp, BNX2_EMAC_TX_STATUS),
-		   REG_RD(bp, BNX2_EMAC_RX_STATUS));
+		   BNX2_RD(bp, BNX2_EMAC_TX_STATUS),
+		   BNX2_RD(bp, BNX2_EMAC_RX_STATUS));
 	netdev_err(dev, "DEBUG: RPM_MGMT_PKT_CTRL[%08x]\n",
-		   REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
+		   BNX2_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
 	netdev_err(dev, "DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
-		   REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
+		   BNX2_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
 	if (bp->flags & BNX2_FLAG_USING_MSIX)
 		netdev_err(dev, "DEBUG: PBA[%08x]\n",
-			   REG_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
+			   BNX2_RD(bp, BNX2_PCI_GRC_WINDOW3_BASE));
 }
 
 static void
@@ -6655,8 +6655,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	prod = NEXT_TX_BD(prod);
 	txr->tx_prod_bseq += skb->len;
 
-	REG_WR16(bp, txr->tx_bidx_addr, prod);
-	REG_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
+	BNX2_WR16(bp, txr->tx_bidx_addr, prod);
+	BNX2_WR(bp, txr->tx_bseq_addr, txr->tx_prod_bseq);
 
 	mmiowb();
 
@@ -7030,7 +7030,7 @@ bnx2_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *_p)
 	offset = reg_boundaries[0];
 	p += offset;
 	while (offset < BNX2_REGDUMP_LEN) {
-		*p++ = REG_RD(bp, offset);
+		*p++ = BNX2_RD(bp, offset);
 		offset += 4;
 		if (offset == reg_boundaries[i + 1]) {
 			offset = reg_boundaries[i + 2];
@@ -7655,26 +7655,26 @@ bnx2_set_phys_id(struct net_device *dev, enum ethtool_phys_id_state state)
 	case ETHTOOL_ID_ACTIVE:
 		bnx2_set_power_state(bp, PCI_D0);
 
-		bp->leds_save = REG_RD(bp, BNX2_MISC_CFG);
-		REG_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
+		bp->leds_save = BNX2_RD(bp, BNX2_MISC_CFG);
+		BNX2_WR(bp, BNX2_MISC_CFG, BNX2_MISC_CFG_LEDMODE_MAC);
 		return 1;	/* cycle on/off once per second */
 
 	case ETHTOOL_ID_ON:
-		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |
-		       BNX2_EMAC_LED_1000MB_OVERRIDE |
-		       BNX2_EMAC_LED_100MB_OVERRIDE |
-		       BNX2_EMAC_LED_10MB_OVERRIDE |
-		       BNX2_EMAC_LED_TRAFFIC_OVERRIDE |
-		       BNX2_EMAC_LED_TRAFFIC);
+		BNX2_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE |
+			BNX2_EMAC_LED_1000MB_OVERRIDE |
+			BNX2_EMAC_LED_100MB_OVERRIDE |
+			BNX2_EMAC_LED_10MB_OVERRIDE |
+			BNX2_EMAC_LED_TRAFFIC_OVERRIDE |
+			BNX2_EMAC_LED_TRAFFIC);
 		break;
 
 	case ETHTOOL_ID_OFF:
-		REG_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE);
+		BNX2_WR(bp, BNX2_EMAC_LED, BNX2_EMAC_LED_OVERRIDE);
 		break;
 
 	case ETHTOOL_ID_INACTIVE:
-		REG_WR(bp, BNX2_EMAC_LED, 0);
-		REG_WR(bp, BNX2_MISC_CFG, bp->leds_save);
+		BNX2_WR(bp, BNX2_EMAC_LED, 0);
+		BNX2_WR(bp, BNX2_MISC_CFG, bp->leds_save);
 
 		if (!netif_running(dev))
 			bnx2_set_power_state(bp, PCI_D3hot);
@@ -7899,7 +7899,7 @@ poll_bnx2(struct net_device *dev)
 static void
 bnx2_get_5709_media(struct bnx2 *bp)
 {
-	u32 val = REG_RD(bp, BNX2_MISC_DUAL_MEDIA_CTRL);
+	u32 val = BNX2_RD(bp, BNX2_MISC_DUAL_MEDIA_CTRL);
 	u32 bond_id = val & BNX2_MISC_DUAL_MEDIA_CTRL_BOND_ID;
 	u32 strap;
 
@@ -7939,13 +7939,13 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 {
 	u32 reg;
 
-	reg = REG_RD(bp, BNX2_PCICFG_MISC_STATUS);
+	reg = BNX2_RD(bp, BNX2_PCICFG_MISC_STATUS);
 	if (reg & BNX2_PCICFG_MISC_STATUS_PCIX_DET) {
 		u32 clkreg;
 
 		bp->flags |= BNX2_FLAG_PCIX;
 
-		clkreg = REG_RD(bp, BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS);
+		clkreg = BNX2_RD(bp, BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS);
 
 		clkreg &= BNX2_PCICFG_PCI_CLOCK_CONTROL_BITS_PCI_CLK_SPD_DET;
 		switch (clkreg) {
@@ -8131,11 +8131,11 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	 * Rely on CPU to do target byte swapping on big endian systems
 	 * The chip's target access swapping will not swap all accesses
 	 */
-	REG_WR(bp, BNX2_PCICFG_MISC_CONFIG,
-		   BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
-		   BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP);
+	BNX2_WR(bp, BNX2_PCICFG_MISC_CONFIG,
+		BNX2_PCICFG_MISC_CONFIG_REG_WINDOW_ENA |
+		BNX2_PCICFG_MISC_CONFIG_TARGET_MB_WORD_SWAP);
 
-	bp->chip_id = REG_RD(bp, BNX2_MISC_ID);
+	bp->chip_id = BNX2_RD(bp, BNX2_MISC_ID);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		if (!pci_is_pcie(pdev)) {
@@ -8198,9 +8198,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	/* 5706A0 may falsely detect SERR and PERR. */
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {
-		reg = REG_RD(bp, PCI_COMMAND);
+		reg = BNX2_RD(bp, PCI_COMMAND);
 		reg &= ~(PCI_COMMAND_SERR | PCI_COMMAND_PARITY);
-		REG_WR(bp, PCI_COMMAND, reg);
+		BNX2_WR(bp, PCI_COMMAND, reg);
 	}
 	else if ((CHIP_ID(bp) == CHIP_ID_5706_A1) &&
 		!(bp->flags & BNX2_FLAG_PCIX)) {
@@ -8358,7 +8358,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
 	    (CHIP_ID(bp) == CHIP_ID_5708_B1) ||
-	    !(REG_RD(bp, BNX2_PCI_CONFIG_3) & BNX2_PCI_CONFIG_3_VAUX_PRESET)) {
+	    !(BNX2_RD(bp, BNX2_PCI_CONFIG_3) & BNX2_PCI_CONFIG_3_VAUX_PRESET)) {
 		bp->flags |= BNX2_FLAG_NO_WOL;
 		bp->wol = 0;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index af6451d..5f13674 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6991,13 +6991,13 @@ struct bnx2 {
 	const struct firmware	*rv2p_firmware;
 };
 
-#define REG_RD(bp, offset)					\
+#define BNX2_RD(bp, offset)					\
 	readl(bp->regview + offset)
 
-#define REG_WR(bp, offset, val)					\
+#define BNX2_WR(bp, offset, val)					\
 	writel(val, bp->regview + offset)
 
-#define REG_WR16(bp, offset, val)				\
+#define BNX2_WR16(bp, offset, val)				\
 	writew(val, bp->regview + offset)
 
 struct cpu_reg {
-- 
1.7.1
