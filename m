From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 5/11] bnx2x: White spaces
Date: Mon, 19 Apr 2010 14:13:57 +0300
Message-ID: <1271675637.6900.277.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1333 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498Ab0DSLOB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 07:14:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

White spaces, code readability and prints.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    9 +-
 drivers/net/bnx2x_main.c |  366 +++++++++++++++++++++++++-------------------
 2 files changed, 214 insertions(+), 162 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index fc00f79..236235f 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -83,7 +83,12 @@ do {								\
 	       __func__, __LINE__,				\
 	       bp->dev ? (bp->dev->name) : "?",			\
 	       ##__args);					\
-} while (0)
+	} while (0)
+
+#define BNX2X_ERROR(__fmt, __args...) do { \
+	pr_err("[%s:%d]" __fmt, __func__, __LINE__, ##__args); \
+	} while (0)
+
 
 /* before we have a dev->name use dev_info() */
 #define BNX2X_DEV_INFO(__fmt, __args...)			 \
@@ -972,6 +977,8 @@ struct bnx2x {
 	u16			rx_quick_cons_trip;
 	u16			rx_ticks_int;
 	u16			rx_ticks;
+/* Maximal coalescing timeout in us */
+#define BNX2X_MAX_COALESCE_TOUT		(0xf0*12)
 
 	u32			lin_cnt;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 4861ee3..4bf8013 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -102,7 +102,8 @@ MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
 static int int_mode;
 module_param(int_mode, int, 0);
-MODULE_PARM_DESC(int_mode, " Force interrupt mode (1 INT#x; 2 MSI)");
+MODULE_PARM_DESC(int_mode, " Force interrupt mode other then MSI-X "
+				"(1 INT#x; 2 MSI)");
 
 static int dropless_fc;
 module_param(dropless_fc, int, 0);
@@ -509,6 +510,7 @@ static int bnx2x_mc_assert(struct bnx2x *bp)
 
 static void bnx2x_fw_dump(struct bnx2x *bp)
 {
+	u32 addr;
 	u32 mark, offset;
 	__be32 data[9];
 	int word;
@@ -517,22 +519,22 @@ static void bnx2x_fw_dump(struct bnx2x *bp)
 		BNX2X_ERR("NO MCP - can not dump\n");
 		return;
 	}
-	mark = REG_RD(bp, MCP_REG_MCPR_SCRATCH + 0xf104);
-	mark = ((mark + 0x3) & ~0x3);
+
+	addr = bp->common.shmem_base - 0x0800 + 4;
+	mark = REG_RD(bp, addr);
+	mark = MCP_REG_MCPR_SCRATCH + ((mark + 0x3) & ~0x3) - 0x08000000;
 	pr_err("begin fw dump (mark 0x%x)\n", mark);
 
 	pr_err("");
-	for (offset = mark - 0x08000000; offset <= 0xF900; offset += 0x8*4) {
+	for (offset = mark; offset <= bp->common.shmem_base; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
-			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
-						  offset + 4*word));
+			data[word] = htonl(REG_RD(bp, offset + 4*word));
 		data[8] = 0x0;
 		pr_cont("%s", (char *)data);
 	}
-	for (offset = 0xF108; offset <= mark - 0x08000000; offset += 0x8*4) {
+	for (offset = addr + 4; offset <= mark; offset += 0x8*4) {
 		for (word = 0; word < 8; word++)
-			data[word] = htonl(REG_RD(bp, MCP_REG_MCPR_SCRATCH +
-						  offset + 4*word));
+			data[word] = htonl(REG_RD(bp, offset + 4*word));
 		data[8] = 0x0;
 		pr_cont("%s", (char *)data);
 	}
@@ -551,9 +553,9 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 	/* Indices */
 	/* Common */
-	BNX2X_ERR("def_c_idx(%u)  def_u_idx(%u)  def_x_idx(%u)"
-		  "  def_t_idx(%u)  def_att_idx(%u)  attn_state(%u)"
-		  "  spq_prod_idx(%u)\n",
+	BNX2X_ERR("def_c_idx(0x%x)  def_u_idx(0x%x)  def_x_idx(0x%x)"
+		  "  def_t_idx(0x%x)  def_att_idx(0x%x)  attn_state(0x%x)"
+		  "  spq_prod_idx(0x%x)\n",
 		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
 		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
 
@@ -561,14 +563,14 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		BNX2X_ERR("fp%d: rx_bd_prod(%x)  rx_bd_cons(%x)"
-			  "  *rx_bd_cons_sb(%x)  rx_comp_prod(%x)"
-			  "  rx_comp_cons(%x)  *rx_cons_sb(%x)\n",
+		BNX2X_ERR("fp%d: rx_bd_prod(0x%x)  rx_bd_cons(0x%x)"
+			  "  *rx_bd_cons_sb(0x%x)  rx_comp_prod(0x%x)"
+			  "  rx_comp_cons(0x%x)  *rx_cons_sb(0x%x)\n",
 			  i, fp->rx_bd_prod, fp->rx_bd_cons,
 			  le16_to_cpu(*fp->rx_bd_cons_sb), fp->rx_comp_prod,
 			  fp->rx_comp_cons, le16_to_cpu(*fp->rx_cons_sb));
-		BNX2X_ERR("      rx_sge_prod(%x)  last_max_sge(%x)"
-			  "  fp_u_idx(%x) *sb_u_idx(%x)\n",
+		BNX2X_ERR("     rx_sge_prod(0x%x)  last_max_sge(0x%x)"
+			  "  fp_u_idx(0x%x) *sb_u_idx(0x%x)\n",
 			  fp->rx_sge_prod, fp->last_max_sge,
 			  le16_to_cpu(fp->fp_u_idx),
 			  fp->status_blk->u_status_block.status_block_index);
@@ -578,12 +580,13 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		BNX2X_ERR("fp%d: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
-			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
+		BNX2X_ERR("fp%d: tx_pkt_prod(0x%x)  tx_pkt_cons(0x%x)"
+			  "  tx_bd_prod(0x%x)  tx_bd_cons(0x%x)"
+			  "  *tx_cons_sb(0x%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
-		BNX2X_ERR("      fp_c_idx(%x)  *sb_c_idx(%x)"
-			  "  tx_db_prod(%x)\n", le16_to_cpu(fp->fp_c_idx),
+		BNX2X_ERR("     fp_c_idx(0x%x)  *sb_c_idx(0x%x)"
+			  "  tx_db_prod(0x%x)\n", le16_to_cpu(fp->fp_c_idx),
 			  fp->status_blk->c_status_block.status_block_index,
 			  fp->tx_db.data.prod);
 	}
@@ -1050,7 +1053,8 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 
 		default:
 			BNX2X_ERR("unexpected MC reply (%d)  "
-				  "fp->state is %x\n", command, fp->state);
+				  "fp[%d] state is %x\n",
+				  command, fp->index, fp->state);
 			break;
 		}
 		mb(); /* force bnx2x_wait_ramrod() to see the change */
@@ -1329,7 +1333,7 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 
 #ifdef BNX2X_STOP_ON_ERROR
 	fp->tpa_queue_used |= (1 << queue);
-#ifdef __powerpc64__
+#ifdef _ASM_GENERIC_INT_L64_H
 	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%lx\n",
 #else
 	DP(NETIF_MSG_RX_STATUS, "fp->tpa_queue_used = 0x%llx\n",
@@ -1358,8 +1362,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 					       max(frag_size, (u32)len_on_bd));
 
 #ifdef BNX2X_STOP_ON_ERROR
-	if (pages >
-	    min((u32)8, (u32)MAX_SKB_FRAGS) * SGE_PAGE_SIZE * PAGES_PER_SGE) {
+	if (pages > min_t(u32, 8, MAX_SKB_FRAGS)*SGE_PAGE_SIZE*PAGES_PER_SGE) {
 		BNX2X_ERR("SGL length is too long: %d. CQE index is %d\n",
 			  pages, cqe_idx);
 		BNX2X_ERR("fp_cqe->pkt_len = %d  fp_cqe->len_on_bd = %d\n",
@@ -1858,8 +1861,8 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 			return IRQ_HANDLED;
 	}
 
-	if (status)
-		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status %u)\n",
+	if (unlikely(status))
+		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status 0x%x)\n",
 		   status);
 
 	return IRQ_HANDLED;
@@ -2419,10 +2422,10 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 		   T_FAIR_COEF / (8 * vn_weight_sum) will always be greater
 		   than zero */
 		m_fair_vn.vn_credit_delta =
-			max((u32)(vn_min_rate * (T_FAIR_COEF /
-						 (8 * bp->vn_weight_sum))),
-			    (u32)(bp->cmng.fair_vars.fair_threshold * 2));
-		DP(NETIF_MSG_IFUP, "m_fair_vn.vn_credit_delta=%d\n",
+			max_t(u32, (vn_min_rate * (T_FAIR_COEF /
+						   (8 * bp->vn_weight_sum))),
+			      (bp->cmng.fair_vars.fair_threshold * 2));
+		DP(NETIF_MSG_IFUP, "m_fair_vn.vn_credit_delta %d\n",
 		   m_fair_vn.vn_credit_delta);
 	}
 
@@ -2592,7 +2595,6 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	return rc;
 }
 
-static void bnx2x_set_storm_rx_mode(struct bnx2x *bp);
 static void bnx2x_set_eth_mac_addr_e1h(struct bnx2x *bp, int set);
 static void bnx2x_set_rx_mode(struct net_device *dev);
 
@@ -2728,12 +2730,6 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 {
 	struct eth_spe *spe;
 
-	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
-	   "SPQE (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
-	   (u32)U64_HI(bp->spq_mapping), (u32)(U64_LO(bp->spq_mapping) +
-	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
-	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
-
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
 		return -EIO;
@@ -2752,8 +2748,8 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 
 	/* CID needs port number to be encoded int it */
 	spe->hdr.conn_and_cmd_data =
-			cpu_to_le32(((command << SPE_HDR_CMD_ID_SHIFT) |
-				     HW_CID(bp, cid)));
+			cpu_to_le32((command << SPE_HDR_CMD_ID_SHIFT) |
+				    HW_CID(bp, cid));
 	spe->hdr.type = cpu_to_le16(ETH_CONNECTION_TYPE);
 	if (common)
 		spe->hdr.type |=
@@ -2764,6 +2760,13 @@ static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 
 	bp->spq_left--;
 
+	DP(BNX2X_MSG_SP/*NETIF_MSG_TIMER*/,
+	   "SPQE[%x] (%x:%x)  command %d  hw_cid %x  data (%x:%x)  left %x\n",
+	   bp->spq_prod_idx, (u32)U64_HI(bp->spq_mapping),
+	   (u32)(U64_LO(bp->spq_mapping) +
+	   (void *)bp->spq_prod_bd - (void *)bp->spq), command,
+	   HW_CID(bp, cid), data_hi, data_lo, bp->spq_left);
+
 	bnx2x_sp_prod_update(bp);
 	spin_unlock_bh(&bp->spq_lock);
 	return 0;
@@ -2939,8 +2942,9 @@ static inline void bnx2x_fan_failure(struct bnx2x *bp)
 		 bp->link_params.ext_phy_config);
 
 	/* log the failure */
-	netdev_err(bp->dev, "Fan Failure on Network Controller has caused the driver to shutdown the card to prevent permanent damage.\n"
-		   "Please contact Dell Support for assistance.\n");
+	netdev_err(bp->dev, "Fan Failure on Network Controller has caused"
+	       " the driver to shutdown the card to prevent permanent"
+	       " damage.  Please contact OEM Support for assistance\n");
 }
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
@@ -3562,11 +3566,23 @@ static void bnx2x_sp_task(struct work_struct *work)
 /*	if (status == 0)				     */
 /*		BNX2X_ERR("spurious slowpath interrupt!\n"); */
 
-	DP(NETIF_MSG_INTR, "got a slowpath interrupt (updated %x)\n", status);
+	DP(NETIF_MSG_INTR, "got a slowpath interrupt (status 0x%x)\n", status);
 
 	/* HW attentions */
-	if (status & 0x1)
+	if (status & 0x1) {
 		bnx2x_attn_int(bp);
+		status &= ~0x1;
+	}
+
+	/* CStorm events: STAT_QUERY */
+	if (status & 0x2) {
+		DP(BNX2X_MSG_SP, "CStorm events: STAT_QUERY\n");
+		status &= ~0x2;
+	}
+
+	if (unlikely(status))
+		DP(NETIF_MSG_INTR, "got an unknown interrupt! (status 0x%x)\n",
+		   status);
 
 	bnx2x_ack_sb(bp, DEF_SB_ID, ATTENTION_ID, le16_to_cpu(bp->def_att_idx),
 		     IGU_INT_NOP, 1);
@@ -3578,7 +3594,6 @@ static void bnx2x_sp_task(struct work_struct *work)
 		     IGU_INT_NOP, 1);
 	bnx2x_ack_sb(bp, DEF_SB_ID, TSTORM_ID, le16_to_cpu(bp->def_t_idx),
 		     IGU_INT_ENABLE, 1);
-
 }
 
 static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
@@ -4363,21 +4378,21 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 		if ((u16)(le16_to_cpu(xclient->stats_counter) + 1) !=
 							bp->stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by xstorm"
-			   "  xstorm counter (%d) != stats_counter (%d)\n",
+			   "  xstorm counter (0x%x) != stats_counter (0x%x)\n",
 			   i, xclient->stats_counter, bp->stats_counter);
 			return -1;
 		}
 		if ((u16)(le16_to_cpu(tclient->stats_counter) + 1) !=
 							bp->stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by tstorm"
-			   "  tstorm counter (%d) != stats_counter (%d)\n",
+			   "  tstorm counter (0x%x) != stats_counter (0x%x)\n",
 			   i, tclient->stats_counter, bp->stats_counter);
 			return -2;
 		}
 		if ((u16)(le16_to_cpu(uclient->stats_counter) + 1) !=
 							bp->stats_counter) {
 			DP(BNX2X_MSG_STATS, "[%d] stats not updated by ustorm"
-			   "  ustorm counter (%d) != stats_counter (%d)\n",
+			   "  ustorm counter (0x%x) != stats_counter (0x%x)\n",
 			   i, uclient->stats_counter, bp->stats_counter);
 			return -4;
 		}
@@ -4806,6 +4821,9 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 {
 	enum bnx2x_stats_state state = bp->stats_state;
 
+	if (unlikely(bp->panic))
+		return;
+
 	bnx2x_stats_stm[state][event].action(bp);
 	bp->stats_state = bnx2x_stats_stm[state][event].next_state;
 
@@ -5410,8 +5428,8 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 
 		fp->rx_bd_prod = ring_prod;
 		/* must not have more available CQEs than BDs */
-		fp->rx_comp_prod = min((u16)(NUM_RCQ_RINGS*RCQ_DESC_CNT),
-				       cqe_ring_prod);
+		fp->rx_comp_prod = min_t(u16, NUM_RCQ_RINGS*RCQ_DESC_CNT,
+					 cqe_ring_prod);
 		fp->rx_pkt = fp->rx_calls = 0;
 
 		/* Warning!
@@ -5517,8 +5535,8 @@ static void bnx2x_init_context(struct bnx2x *bp)
 			context->ustorm_st_context.common.flags |=
 				USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA;
 			context->ustorm_st_context.common.sge_buff_size =
-				(u16)min((u32)SGE_PAGE_SIZE*PAGES_PER_SGE,
-					 (u32)0xffff);
+				(u16)min_t(u32, SGE_PAGE_SIZE*PAGES_PER_SGE,
+					   0xffff);
 			context->ustorm_st_context.common.sge_page_base_hi =
 						U64_HI(fp->rx_sge_mapping);
 			context->ustorm_st_context.common.sge_page_base_lo =
@@ -5815,10 +5833,8 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	}
 
 	/* Init CQ ring mapping and aggregation size, the FW limit is 8 frags */
-	max_agg_size =
-		min((u32)(min((u32)8, (u32)MAX_SKB_FRAGS) *
-			  SGE_PAGE_SIZE * PAGES_PER_SGE),
-		    (u32)0xffff);
+	max_agg_size = min_t(u32, (min_t(u32, 8, MAX_SKB_FRAGS) *
+				   SGE_PAGE_SIZE * PAGES_PER_SGE), 0xffff);
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
@@ -5904,7 +5920,7 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	}
 
 
-	/* Store it to internal memory */
+	/* Store cmng structures to internal memory */
 	if (bp->port.pmf)
 		for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
 			REG_WR(bp, BAR_XSTRORM_INTMEM +
@@ -6022,7 +6038,8 @@ gunzip_nomem2:
 	bp->gunzip_buf = NULL;
 
 gunzip_nomem1:
-	netdev_err(bp->dev, "Cannot allocate firmware buffer for un-compression\n");
+	netdev_err(bp->dev, "Cannot allocate firmware buffer for"
+	       " un-compression\n");
 	return -ENOMEM;
 }
 
@@ -6073,8 +6090,9 @@ static int bnx2x_gunzip(struct bnx2x *bp, const u8 *zbuf, int len)
 
 	bp->gunzip_outlen = (FW_BUF_SIZE - bp->strm->avail_out);
 	if (bp->gunzip_outlen & 0x3)
-		netdev_err(bp->dev, "Firmware decompression error: gunzip_outlen (%d) not aligned\n",
-			   bp->gunzip_outlen);
+		netdev_err(bp->dev, "Firmware decompression error:"
+				    " gunzip_outlen (%d) not aligned\n",
+				bp->gunzip_outlen);
 	bp->gunzip_outlen >>= 2;
 
 	zlib_inflateEnd(bp->strm);
@@ -6432,7 +6450,7 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 	/* set to active low mode */
 	val = REG_RD(bp, MISC_REG_SPIO_INT);
 	val |= ((1 << MISC_REGISTERS_SPIO_5) <<
-				MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
+					MISC_REGISTERS_SPIO_INT_OLD_SET_POS);
 	REG_WR(bp, MISC_REG_SPIO_INT, val);
 
 	/* enable interrupt to signal the IGU */
@@ -6619,7 +6637,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 
 	if (sizeof(union cdu_context) != 1024)
 		/* we currently assume that a context is 1024 bytes */
-		pr_alert("please adjust the size of cdu_context(%ld)\n",
+		dev_alert(&bp->pdev->dev, "please adjust the size "
+					  "of cdu_context(%ld)\n",
 			 (long)sizeof(union cdu_context));
 
 	bnx2x_init_block(bp, CDU_BLOCK, COMMON_STAGE);
@@ -6723,7 +6742,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	u32 low, high;
 	u32 val;
 
-	DP(BNX2X_MSG_MCP, "starting port init  port %x\n", port);
+	DP(BNX2X_MSG_MCP, "starting port init  port %d\n", port);
 
 	REG_WR(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4, 0);
 
@@ -6742,6 +6761,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR(bp, TM_REG_LIN0_SCAN_TIME + port*4, 20);
 	REG_WR(bp, TM_REG_LIN0_MAX_ACTIVE_CID + port*4, 31);
 #endif
+
 	bnx2x_init_block(bp, DQ_BLOCK, init_stage);
 
 	bnx2x_init_block(bp, BRB1_BLOCK, init_stage);
@@ -6934,7 +6954,7 @@ static int bnx2x_init_func(struct bnx2x *bp)
 	u32 addr, val;
 	int i;
 
-	DP(BNX2X_MSG_MCP, "starting func init  func %x\n", func);
+	DP(BNX2X_MSG_MCP, "starting func init  func %d\n", func);
 
 	/* set MSI reconfigure capability */
 	addr = (port ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0);
@@ -7428,10 +7448,11 @@ static int bnx2x_req_msix_irqs(struct bnx2x *bp)
 	}
 
 	i = BNX2X_NUM_QUEUES(bp);
-	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d ... fp[%d] %d\n",
-		    bp->msix_table[0].vector,
-		    0, bp->msix_table[offset].vector,
-		    i - 1, bp->msix_table[offset + i - 1].vector);
+	netdev_info(bp->dev, "using MSI-X  IRQs: sp %d  fp[%d] %d"
+	       " ... fp[%d] %d\n",
+	       bp->msix_table[0].vector,
+	       0, bp->msix_table[offset].vector,
+	       i - 1, bp->msix_table[offset + i - 1].vector);
 
 	return 0;
 }
@@ -9142,7 +9163,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	val = SHMEM_RD(bp, validity_map[BP_PORT(bp)]);
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
-		BNX2X_ERR("BAD MCP validity signature\n");
+		BNX2X_ERROR("BAD MCP validity signature\n");
 
 	bp->common.hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
 	BNX2X_DEV_INFO("hw_config 0x%08x\n", bp->common.hw_config);
@@ -9166,8 +9187,8 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	if (val < BNX2X_BC_VER) {
 		/* for now only warn
 		 * later we might need to enforce this */
-		BNX2X_ERR("This driver needs bc_ver %X but found %X,"
-			  " please upgrade BC\n", BNX2X_BC_VER, val);
+		BNX2X_ERROR("This driver needs bc_ver %X but found %X, "
+			    "please upgrade BC\n", BNX2X_BC_VER, val);
 	}
 	bp->link_params.feature_config_flags |=
 		(val >= REQ_BC_VER_4_VRFY_OPT_MDL) ?
@@ -9188,7 +9209,8 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	val3 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[8]);
 	val4 = SHMEM_RD(bp, dev_info.shared_hw_config.part_num[12]);
 
-	pr_info("part number %X-%X-%X-%X\n", val, val2, val3, val4);
+	dev_info(&bp->pdev->dev, "part number %X-%X-%X-%X\n",
+		 val, val2, val3, val4);
 }
 
 static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
@@ -9466,11 +9488,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_10baseT_Full |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9482,11 +9504,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_10baseT_Half |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9497,11 +9519,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_100baseT_Full |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9513,11 +9535,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_100baseT_Half |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9528,11 +9550,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_1000baseT_Full |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9543,11 +9565,11 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_2500baseX_Full |
 						ADVERTISED_TP);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
@@ -9560,19 +9582,19 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->port.advertising = (ADVERTISED_10000baseT_Full |
 						ADVERTISED_FIBRE);
 		} else {
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  speed_cap_mask 0x%x\n",
-				  bp->port.link_config,
-				  bp->link_params.speed_cap_mask);
+			BNX2X_ERROR("NVRAM config error. "
+				    "Invalid link_config 0x%x"
+				    "  speed_cap_mask 0x%x\n",
+				    bp->port.link_config,
+				    bp->link_params.speed_cap_mask);
 			return;
 		}
 		break;
 
 	default:
-		BNX2X_ERR("NVRAM config error. "
-			  "BAD link speed link_config 0x%x\n",
-			  bp->port.link_config);
+		BNX2X_ERROR("NVRAM config error. "
+			    "BAD link speed link_config 0x%x\n",
+			    bp->port.link_config);
 		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
 		bp->port.advertising = bp->port.supported;
 		break;
@@ -9722,14 +9744,14 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 					       "(0x%04x)\n",
 					       func, bp->e1hov, bp->e1hov);
 			} else {
-				BNX2X_ERR("!!!  No valid E1HOV for func %d,"
-					  "  aborting\n", func);
+				BNX2X_ERROR("No valid E1HOV for func %d,"
+					    "  aborting\n", func);
 				rc = -EPERM;
 			}
 		} else {
 			if (BP_E1HVN(bp)) {
-				BNX2X_ERR("!!!  VN %d in single function mode,"
-					  "  aborting\n", BP_E1HVN(bp));
+				BNX2X_ERROR("VN %d in single function mode,"
+					    "  aborting\n", BP_E1HVN(bp));
 				rc = -EPERM;
 			}
 		}
@@ -9765,7 +9787,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	if (BP_NOMCP(bp)) {
 		/* only supposed to happen on emulation/FPGA */
-		BNX2X_ERR("warning random MAC workaround active\n");
+		BNX2X_ERROR("warning: random MAC workaround active\n");
 		random_ether_addr(bp->dev->dev_addr);
 		memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
 	}
@@ -9934,15 +9956,17 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 		bnx2x_undi_unload(bp);
 
 	if (CHIP_REV_IS_FPGA(bp))
-		pr_err("FPGA detected\n");
+		dev_err(&bp->pdev->dev, "FPGA detected\n");
 
 	if (BP_NOMCP(bp) && (func == 0))
-		pr_err("MCP disabled, must load devices in order!\n");
+		dev_err(&bp->pdev->dev, "MCP disabled, "
+					"must load devices in order!\n");
 
 	/* Set multi queue mode */
 	if ((multi_mode != ETH_RSS_MODE_DISABLED) &&
 	    ((int_mode == INT_MODE_INTx) || (int_mode == INT_MODE_MSI))) {
-		pr_err("Multi disabled since int_mode requested is not MSI-X\n");
+		dev_err(&bp->pdev->dev, "Multi disabled since int_mode "
+					"requested is not MSI-X\n");
 		multi_mode = ETH_RSS_MODE_DISABLED;
 	}
 	bp->multi_mode = multi_mode;
@@ -10859,19 +10883,18 @@ static int bnx2x_get_coalesce(struct net_device *dev,
 	return 0;
 }
 
-#define BNX2X_MAX_COALES_TOUT  (0xf0*12) /* Maximal coalescing timeout in us */
 static int bnx2x_set_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-	bp->rx_ticks = (u16) coal->rx_coalesce_usecs;
-	if (bp->rx_ticks > BNX2X_MAX_COALES_TOUT)
-		bp->rx_ticks = BNX2X_MAX_COALES_TOUT;
+	bp->rx_ticks = (u16)coal->rx_coalesce_usecs;
+	if (bp->rx_ticks > BNX2X_MAX_COALESCE_TOUT)
+		bp->rx_ticks = BNX2X_MAX_COALESCE_TOUT;
 
-	bp->tx_ticks = (u16) coal->tx_coalesce_usecs;
-	if (bp->tx_ticks > BNX2X_MAX_COALES_TOUT)
-		bp->tx_ticks = BNX2X_MAX_COALES_TOUT;
+	bp->tx_ticks = (u16)coal->tx_coalesce_usecs;
+	if (bp->tx_ticks > BNX2X_MAX_COALESCE_TOUT)
+		bp->tx_ticks = BNX2X_MAX_COALESCE_TOUT;
 
 	if (netif_running(dev))
 		bnx2x_update_coalesce(bp);
@@ -11082,9 +11105,9 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 	u32 wr_val = 0;
 	int port = BP_PORT(bp);
 	static const struct {
-		u32  offset0;
-		u32  offset1;
-		u32  mask;
+		u32 offset0;
+		u32 offset1;
+		u32 mask;
 	} reg_tbl[] = {
 /* 0 */		{ BRB1_REG_PAUSE_LOW_THRESHOLD_0,      4, 0x000003ff },
 		{ DORQ_REG_DB_ADDR0,                   4, 0xffffffff },
@@ -11157,9 +11180,13 @@ static int bnx2x_test_registers(struct bnx2x *bp)
 			/* Restore the original register's value */
 			REG_WR(bp, offset, save_val);
 
-			/* verify that value is as expected value */
-			if ((val & mask) != (wr_val & mask))
+			/* verify value is as expected */
+			if ((val & mask) != (wr_val & mask)) {
+				DP(NETIF_MSG_PROBE,
+				   "offset 0x%x: val 0x%x != 0x%x mask 0x%x\n",
+				   offset, val, wr_val, mask);
 				goto test_reg_exit;
+			}
 		}
 	}
 
@@ -11708,7 +11735,7 @@ static int bnx2x_get_sset_count(struct net_device *dev, int stringset)
 	struct bnx2x *bp = netdev_priv(dev);
 	int i, num_stats;
 
-	switch(stringset) {
+	switch (stringset) {
 	case ETH_SS_STATS:
 		if (is_multi(bp)) {
 			num_stats = BNX2X_NUM_Q_STATS * bp->num_queues;
@@ -12869,18 +12896,21 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
-		pr_err("Cannot enable PCI device, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot enable PCI device, aborting\n");
 		goto err_out;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		pr_err("Cannot find PCI device base address, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot find PCI device base address, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
 
 	if (!(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-		pr_err("Cannot find second PCI device base address, aborting\n");
+		dev_err(&bp->pdev->dev, "Cannot find second PCI device"
+		       " base address, aborting\n");
 		rc = -ENODEV;
 		goto err_out_disable;
 	}
@@ -12888,7 +12908,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (atomic_read(&pdev->enable_cnt) == 1) {
 		rc = pci_request_regions(pdev, DRV_MODULE_NAME);
 		if (rc) {
-			pr_err("Cannot obtain PCI resources, aborting\n");
+			dev_err(&bp->pdev->dev,
+				"Cannot obtain PCI resources, aborting\n");
 			goto err_out_disable;
 		}
 
@@ -12898,14 +12918,16 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	bp->pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
 	if (bp->pm_cap == 0) {
-		pr_err("Cannot find power management capability, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot find power management capability, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
 
 	bp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (bp->pcie_cap == 0) {
-		pr_err("Cannot find PCI Express capability, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot find PCI Express capability, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
@@ -12913,13 +12946,15 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) == 0) {
 		bp->flags |= USING_DAC_FLAG;
 		if (dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64)) != 0) {
-			pr_err("dma_set_coherent_mask failed, aborting\n");
+			dev_err(&bp->pdev->dev, "dma_set_coherent_mask"
+			       " failed, aborting\n");
 			rc = -EIO;
 			goto err_out_release;
 		}
 
 	} else if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(32)) != 0) {
-		pr_err("System does not support DMA, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"System does not support DMA, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
@@ -12932,7 +12967,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	bp->regview = pci_ioremap_bar(pdev, 0);
 	if (!bp->regview) {
-		pr_err("Cannot map register space, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot map register space, aborting\n");
 		rc = -ENOMEM;
 		goto err_out_release;
 	}
@@ -12941,7 +12977,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 					min_t(u64, BNX2X_DB_SIZE,
 					      pci_resource_len(pdev, 2)));
 	if (!bp->doorbells) {
-		pr_err("Cannot map doorbell space, aborting\n");
+		dev_err(&bp->pdev->dev,
+			"Cannot map doorbell space, aborting\n");
 		rc = -ENOMEM;
 		goto err_out_unmap;
 	}
@@ -13046,7 +13083,8 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 		offset = be32_to_cpu(sections[i].offset);
 		len = be32_to_cpu(sections[i].len);
 		if (offset + len > firmware->size) {
-			pr_err("Section %d length is out of bounds\n", i);
+			dev_err(&bp->pdev->dev,
+				"Section %d length is out of bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -13058,7 +13096,8 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 
 	for (i = 0; i < be32_to_cpu(fw_hdr->init_ops_offsets.len) / 2; i++) {
 		if (be16_to_cpu(ops_offsets[i]) > num_ops) {
-			pr_err("Section offset %d is out of bounds\n", i);
+			dev_err(&bp->pdev->dev,
+				"Section offset %d is out of bounds\n", i);
 			return -EINVAL;
 		}
 	}
@@ -13070,7 +13109,8 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 	    (fw_ver[1] != BCM_5710_FW_MINOR_VERSION) ||
 	    (fw_ver[2] != BCM_5710_FW_REVISION_VERSION) ||
 	    (fw_ver[3] != BCM_5710_FW_ENGINEERING_VERSION)) {
-		pr_err("Bad FW version:%d.%d.%d.%d. Should be %d.%d.%d.%d\n",
+		dev_err(&bp->pdev->dev,
+			"Bad FW version:%d.%d.%d.%d. Should be %d.%d.%d.%d\n",
 		       fw_ver[0], fw_ver[1], fw_ver[2],
 		       fw_ver[3], BCM_5710_FW_MAJOR_VERSION,
 		       BCM_5710_FW_MINOR_VERSION,
@@ -13105,8 +13145,8 @@ static inline void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
 	for (i = 0, j = 0; i < n/8; i++, j += 2) {
 		tmp = be32_to_cpu(source[j]);
 		target[i].op = (tmp >> 24) & 0xff;
-		target[i].offset =  tmp & 0xffffff;
-		target[i].raw_data = be32_to_cpu(source[j+1]);
+		target[i].offset = tmp & 0xffffff;
+		target[i].raw_data = be32_to_cpu(source[j + 1]);
 	}
 }
 
@@ -13140,20 +13180,24 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 
 	if (CHIP_IS_E1(bp))
 		fw_file_name = FW_FILE_NAME_E1;
-	else
+	else if (CHIP_IS_E1H(bp))
 		fw_file_name = FW_FILE_NAME_E1H;
+	else {
+		dev_err(dev, "Unsupported chip revision\n");
+		return -EINVAL;
+	}
 
-	pr_info("Loading %s\n", fw_file_name);
+	dev_info(dev, "Loading %s\n", fw_file_name);
 
 	rc = request_firmware(&bp->firmware, fw_file_name, dev);
 	if (rc) {
-		pr_err("Can't load firmware file %s\n", fw_file_name);
+		dev_err(dev, "Can't load firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
 	rc = bnx2x_check_firmware(bp);
 	if (rc) {
-		pr_err("Corrupt firmware file %s\n", fw_file_name);
+		dev_err(dev, "Corrupt firmware file %s\n", fw_file_name);
 		goto request_firmware_exit;
 	}
 
@@ -13212,7 +13256,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), MAX_CONTEXT);
 	if (!dev) {
-		pr_err("Cannot allocate net device\n");
+		dev_err(&pdev->dev, "Cannot allocate net device\n");
 		return -ENOMEM;
 	}
 
@@ -13234,7 +13278,7 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* Set init arrays */
 	rc = bnx2x_init_firmware(bp, &pdev->dev);
 	if (rc) {
-		pr_err("Error loading firmware\n");
+		dev_err(&pdev->dev, "Error loading firmware\n");
 		goto init_one_exit;
 	}
 
@@ -13245,11 +13289,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	}
 
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
-	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx, IRQ %d, node addr %pM\n",
-		    board_info[ent->driver_data].name,
-		    (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
-		    pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
-		    dev->base_addr, bp->pdev->irq, dev->dev_addr);
+	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
+	       " IRQ %d, ", board_info[ent->driver_data].name,
+	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
+	       pcie_width, (pcie_speed == 2) ? "5GHz (Gen2)" : "2.5GHz",
+	       dev->base_addr, bp->pdev->irq);
+	pr_cont("node addr %pM\n", dev->dev_addr);
 
 	return 0;
 
@@ -13277,7 +13322,7 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)
 	struct bnx2x *bp;
 
 	if (!dev) {
-		pr_err("BAD net device from bnx2x_init_one\n");
+		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
 		return;
 	}
 	bp = netdev_priv(dev);
@@ -13313,7 +13358,7 @@ static int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct bnx2x *bp;
 
 	if (!dev) {
-		pr_err("BAD net device from bnx2x_init_one\n");
+		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
 		return -ENODEV;
 	}
 	bp = netdev_priv(dev);
@@ -13345,7 +13390,7 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	int rc;
 
 	if (!dev) {
-		pr_err("BAD net device from bnx2x_init_one\n");
+		dev_err(&pdev->dev, "BAD net device from bnx2x_init_one\n");
 		return -ENODEV;
 	}
 	bp = netdev_priv(dev);
-- 
1.6.3.3




