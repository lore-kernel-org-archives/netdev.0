From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 16/18] bnx2x: Debug prints
Date: Mon, 02 Mar 2009 20:01:09 +0200
Message-ID: <1236016869.7723.89.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3108 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757077AbZCBSBz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 16/18] bnx2x: Debug prints

Add the FP index to relevant debug prints and simply beautify some others

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index bb9d539..e5952c5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -216,7 +216,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
 	dmae->comp_val = DMAE_COMP_VAL;
 
-	DP(BNX2X_MSG_OFF, "dmae: opcode 0x%08x\n"
+	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
@@ -237,7 +237,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		DP(BNX2X_MSG_OFF, "wb_comp 0x%08x\n", *wb_comp);
 
 		if (!cnt) {
-			BNX2X_ERR("dmae timeout!\n");
+			BNX2X_ERR("DMAE timeout!\n");
 			break;
 		}
 		cnt--;
@@ -292,7 +292,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
 	dmae->comp_val = DMAE_COMP_VAL;
 
-	DP(BNX2X_MSG_OFF, "dmae: opcode 0x%08x\n"
+	DP(BNX2X_MSG_OFF, "DMAE: opcode 0x%08x\n"
 	   DP_LEVEL "src_addr  [%x:%08x]  len [%d *4]  "
 		    "dst_addr [%x:%08x (%08x)]\n"
 	   DP_LEVEL "comp_addr [%x:%08x]  comp_val 0x%08x\n",
@@ -309,7 +309,7 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 	while (*wb_comp != DMAE_COMP_VAL) {
 
 		if (!cnt) {
-			BNX2X_ERR("dmae timeout!\n");
+			BNX2X_ERR("DMAE timeout!\n");
 			break;
 		}
 		cnt--;
@@ -517,13 +517,13 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
-		BNX2X_ERR("queue[%d]: rx_bd_prod(%x)  rx_bd_cons(%x)"
+		BNX2X_ERR("fp%d: rx_bd_prod(%x)  rx_bd_cons(%x)"
 			  "  *rx_bd_cons_sb(%x)  rx_comp_prod(%x)"
 			  "  rx_comp_cons(%x)  *rx_cons_sb(%x)\n",
 			  i, fp->rx_bd_prod, fp->rx_bd_cons,
 			  le16_to_cpu(*fp->rx_bd_cons_sb), fp->rx_comp_prod,
 			  fp->rx_comp_cons, le16_to_cpu(*fp->rx_cons_sb));
-		BNX2X_ERR("          rx_sge_prod(%x)  last_max_sge(%x)"
+		BNX2X_ERR("      rx_sge_prod(%x)  last_max_sge(%x)"
 			  "  fp_u_idx(%x) *sb_u_idx(%x)\n",
 			  fp->rx_sge_prod, fp->last_max_sge,
 			  le16_to_cpu(fp->fp_u_idx),
@@ -535,11 +535,11 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 		struct eth_tx_db_data *hw_prods = fp->hw_tx_prods;
 
-		BNX2X_ERR("queue[%d]: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
+		BNX2X_ERR("fp%d: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
 			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
 			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
 			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
-		BNX2X_ERR("          fp_c_idx(%x)  *sb_c_idx(%x)"
+		BNX2X_ERR("      fp_c_idx(%x)  *sb_c_idx(%x)"
 			  "  bd data(%x,%x)\n", le16_to_cpu(fp->fp_c_idx),
 			  fp->status_blk->c_status_block.status_block_index,
 			  hw_prods->packets_prod, hw_prods->bds_prod);
@@ -556,8 +556,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 			u32 *rx_bd = (u32 *)&fp->rx_desc_ring[j];
 			struct sw_rx_bd *sw_bd = &fp->rx_buf_ring[j];
 
-			BNX2X_ERR("rx_bd[%x]=[%x:%x]  sw_bd=[%p]\n",
-				  j, rx_bd[1], rx_bd[0], sw_bd->skb);
+			BNX2X_ERR("fp%d: rx_bd[%x]=[%x:%x]  sw_bd=[%p]\n",
+				  i, j, rx_bd[1], rx_bd[0], sw_bd->skb);
 		}
 
 		start = RX_SGE(fp->rx_sge_prod);
@@ -566,8 +566,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 			u32 *rx_sge = (u32 *)&fp->rx_sge_ring[j];
 			struct sw_rx_page *sw_page = &fp->rx_page_ring[j];
 
-			BNX2X_ERR("rx_sge[%x]=[%x:%x]  sw_page=[%p]\n",
-				  j, rx_sge[1], rx_sge[0], sw_page->page);
+			BNX2X_ERR("fp%d: rx_sge[%x]=[%x:%x]  sw_page=[%p]\n",
+				  i, j, rx_sge[1], rx_sge[0], sw_page->page);
 		}
 
 		start = RCQ_BD(fp->rx_comp_cons - 10);
@@ -575,8 +575,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		for (j = start; j != end; j = RCQ_BD(j + 1)) {
 			u32 *cqe = (u32 *)&fp->rx_comp_ring[j];
 
-			BNX2X_ERR("cqe[%x]=[%x:%x:%x:%x]\n",
-				  j, cqe[0], cqe[1], cqe[2], cqe[3]);
+			BNX2X_ERR("fp%d: cqe[%x]=[%x:%x:%x:%x]\n",
+				  i, j, cqe[0], cqe[1], cqe[2], cqe[3]);
 		}
 	}
 
@@ -589,8 +589,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		for (j = start; j != end; j = TX_BD(j + 1)) {
 			struct sw_tx_bd *sw_bd = &fp->tx_buf_ring[j];
 
-			BNX2X_ERR("packet[%x]=[%p,%x]\n", j,
-				  sw_bd->skb, sw_bd->first_bd);
+			BNX2X_ERR("fp%d: packet[%x]=[%p,%x]\n",
+				  i, j, sw_bd->skb, sw_bd->first_bd);
 		}
 
 		start = TX_BD(fp->tx_bd_cons - 10);
@@ -598,8 +598,8 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		for (j = start; j != end; j = TX_BD(j + 1)) {
 			u32 *tx_bd = (u32 *)&fp->tx_desc_ring[j];
 
-			BNX2X_ERR("tx_bd[%x]=[%x:%x:%x:%x]\n",
-				  j, tx_bd[0], tx_bd[1], tx_bd[2], tx_bd[3]);
+			BNX2X_ERR("fp%d: tx_bd[%x]=[%x:%x:%x:%x]\n",
+				  i, j, tx_bd[0], tx_bd[1], tx_bd[2], tx_bd[3]);
 		}
 	}
 
@@ -3667,7 +3667,7 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 		bnx2x_emac_stats_update(bp);
 
 	else { /* unreached */
-		BNX2X_ERR("stats updated by dmae but no MAC active\n");
+		BNX2X_ERR("stats updated by DMAE but no MAC active\n");
 		return -1;
 	}
 
-- 
1.5.4.3




