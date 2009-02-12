From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 33/41]bnx2x: Removing redundant macros
Date: Thu, 12 Feb 2009 20:38:14 +0200
Message-ID: <1234463894.1863.165.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Harvey Harrison" <harvey.harrison@gmail.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1442 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757269AbZBLSih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 33/41]bnx2x: Removing redundant macros

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   10 --------
 drivers/net/bnx2x_main.c |   52 +++++++++++++++++++++++-----------------------
 2 files changed, 26 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 88eeee9..e07d915 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -96,12 +96,10 @@
 
 #define REG_RD(bp, offset)		readl(REG_ADDR(bp, offset))
 #define REG_RD8(bp, offset)		readb(REG_ADDR(bp, offset))
-#define REG_RD64(bp, offset)		readq(REG_ADDR(bp, offset))
 
 #define REG_WR(bp, offset, val)		writel((u32)val, REG_ADDR(bp, offset))
 #define REG_WR8(bp, offset, val)	writeb((u8)val, REG_ADDR(bp, offset))
 #define REG_WR16(bp, offset, val)	writew((u16)val, REG_ADDR(bp, offset))
-#define REG_WR32(bp, offset, val)	REG_WR(bp, offset, val)
 
 #define REG_RD_IND(bp, offset)		bnx2x_reg_rd_ind(bp, offset)
 #define REG_WR_IND(bp, offset, val)	bnx2x_reg_wr_ind(bp, offset, val)
@@ -267,11 +265,6 @@ struct bnx2x_fastpath {
 	u8			index;	/* number in fp array */
 	u8			cl_id;	/* eth client id */
 	u8			sb_id;	/* status block number in HW */
-#define FP_IDX(fp)			(fp->index)
-#define FP_CL_ID(fp)			(fp->cl_id)
-#define BP_CL_ID(bp)			(bp->fp[0].cl_id)
-#define FP_SB_ID(fp)			(fp->sb_id)
-#define CNIC_SB_ID			0
 
 	u16			tx_pkt_prod;
 	u16			tx_pkt_cons;
@@ -1128,9 +1121,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_MCP_ASSERT \
 	GENERAL_ATTEN_OFFSET(MCP_FATAL_ASSERT_ATTENTION_BIT)
 
-#define BNX2X_DOORQ_ASSERT \
-	AEU_INPUTS_ATTN_BITS_DOORBELLQ_HW_INTERRUPT
-
 #define BNX2X_GRC_TIMEOUT	GENERAL_ATTEN_OFFSET(LATCHED_ATTN_TIMEOUT_GRC)
 #define BNX2X_GRC_RSV		(GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCR) | \
 				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCT) | \
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 96e23fd..2542ba8 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -929,12 +929,12 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 
 	DP(BNX2X_MSG_SP,
 	   "fp %d  cid %d  got ramrod #%d  state is %x  type is %d\n",
-	   FP_IDX(fp), cid, command, bp->state,
+	   fp->index, cid, command, bp->state,
 	   rr_cqe->ramrod_cqe.ramrod_type);
 
 	bp->spq_left++;
 
-	if (FP_IDX(fp)) {
+	if (fp->index) {
 		switch (command | fp->state) {
 		case (RAMROD_CMD_ID_ETH_CLIENT_SETUP |
 						BNX2X_FP_STATE_OPENING):
@@ -1411,7 +1411,7 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 
 	for (i = 0; i < sizeof(struct ustorm_eth_rx_producers)/4; i++)
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)) + i*4,
+		       USTORM_RX_PRODS_OFFSET(BP_PORT(bp), fp->cl_id) + i*4,
 		       ((u32 *)&rx_prods)[i]);
 
 	mmiowb(); /* keep prod updates ordered */
@@ -1452,7 +1452,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 	DP(NETIF_MSG_RX_STATUS,
 	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   FP_IDX(fp), hw_comp_cons, sw_comp_cons);
+	   fp->index, hw_comp_cons, sw_comp_cons);
 
 	while (sw_comp_cons != hw_comp_cons) {
 		struct sw_rx_bd *rx_buf = NULL;
@@ -1648,7 +1648,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 {
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
-	int index = FP_IDX(fp);
+	int index = fp->index;
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
@@ -1657,8 +1657,8 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	}
 
 	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
-	   index, FP_SB_ID(fp));
-	bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID, 0, IGU_INT_DISABLE, 0);
+	   index, fp->sb_id);
+	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -2641,7 +2641,7 @@ static inline void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 {
 	u32 val;
 
-	if (attn & BNX2X_DOORQ_ASSERT) {
+	if (attn & AEU_INPUTS_ATTN_BITS_DOORBELLQ_HW_INTERRUPT) {
 
 		val = REG_RD(bp, DORQ_REG_DORQ_INT_STS_CLR);
 		BNX2X_ERR("DB hw attention 0x%x\n", val);
@@ -4641,11 +4641,11 @@ static void bnx2x_init_context(struct bnx2x *bp)
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		u8 cl_id = fp->cl_id;
-		u8 sb_id = FP_SB_ID(fp);
+		u8 sb_id = fp->sb_id;
 
 		context->ustorm_st_context.common.sb_index_numbers =
 						BNX2X_RX_SB_INDEX_NUM;
-		context->ustorm_st_context.common.clientId = FP_CL_ID(fp);
+		context->ustorm_st_context.common.clientId = cl_id;
 		context->ustorm_st_context.common.status_block_id = sb_id;
 		context->ustorm_st_context.common.flags =
 			(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT |
@@ -4686,7 +4686,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_HI(fp->tx_prods_mapping);
 		context->xstorm_st_context.db_data_addr_lo =
 						U64_LO(fp->tx_prods_mapping);
-		context->xstorm_st_context.statistics_data = (fp->cl_id |
+		context->xstorm_st_context.statistics_data = (cl_id |
 				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
 		context->cstorm_st_context.sb_index_number =
 						C_SB_ETH_TX_CQ_INDEX;
@@ -4712,7 +4712,7 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			BP_CL_ID(bp) + (i % bp->num_rx_queues));
+			bp->fp->cl_id + (i % bp->num_rx_queues));
 }
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
@@ -4998,14 +4998,14 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)),
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id),
 		       U64_LO(fp->rx_comp_mapping));
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)) + 4,
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_MAX_AGG_SIZE_OFFSET(port, FP_CL_ID(fp)),
+			 USTORM_MAX_AGG_SIZE_OFFSET(port, fp->cl_id),
 			 max_agg_size);
 	}
 
@@ -5116,9 +5116,9 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		fp->sb_id = fp->cl_id;
 		DP(NETIF_MSG_IFUP,
 		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
-		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
+		   bp, fp->status_blk, i, fp->cl_id, fp->sb_id);
 		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping,
-			      FP_SB_ID(fp));
+			      fp->sb_id);
 		bnx2x_update_fpsb_idx(fp);
 	}
 
@@ -6585,7 +6585,7 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	 */
 	config->hdr.length = 2;
 	config->hdr.offset = port ? 32 : 0;
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
@@ -6643,7 +6643,7 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 	 */
 	config->hdr.length = 1;
 	config->hdr.offset = BP_FUNC(bp);
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
@@ -7045,7 +7045,7 @@ static int bnx2x_stop_leading(struct bnx2x *bp)
 
 	/* Send HALT ramrod */
 	bp->fp[0].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, BP_CL_ID(bp), 0);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, bp->fp->cl_id, 0);
 
 	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
@@ -7215,7 +7215,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			config->hdr.offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
 		else
 			config->hdr.offset = BNX2X_MAX_MULTICAST*(1 + port);
-		config->hdr.client_id = BP_CL_ID(bp);
+		config->hdr.client_id = bp->fp->cl_id;
 		config->hdr.reserved1 = 0;
 
 		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
@@ -9392,7 +9392,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, FP_IDX(fp), 0);
+	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
 
@@ -9545,7 +9545,7 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 		config->hdr.offset = (BP_PORT(bp) ? 32 : 0);
 	else
 		config->hdr.offset = BP_FUNC(bp);
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
@@ -10050,9 +10050,9 @@ poll_panic:
 #endif
 		napi_complete(napi);
 
-		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
+		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, FP_SB_ID(fp), CSTORM_ID,
+		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
 			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
 	}
 	return work_done;
@@ -10491,7 +10491,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, FP_IDX(fp), 0);
+	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
 
-- 
1.5.4.3




