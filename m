From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/7][BNX2]: Remove CTX_WR macro.
Date: Tue, 29 Jan 2008 16:19:47 -0800
Message-ID: <1201652387.19087.13.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2024 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbYA2Xjg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 18:39:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Remove CTX_WR macro.

The CTX_WR macro is unnecessary and obfuscates the code. 

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8e9fe48..8af63b4 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2237,7 +2237,7 @@ bnx2_init_context(struct bnx2 *bp)
 
 			/* Zero out the context. */
 			for (offset = 0; offset < PHY_CTX_SIZE; offset += 4)
-				CTX_WR(bp, vcid_addr, offset, 0);
+				bnx2_ctx_wr(bp, vcid_addr, offset, 0);
 		}
 	}
 }
@@ -4523,6 +4523,7 @@ static void
 bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
 {
 	u32 val, offset0, offset1, offset2, offset3;
+	u32 cid_addr = GET_CID_ADDR(cid);
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		offset0 = BNX2_L2CTX_TYPE_XI;
@@ -4536,16 +4537,16 @@ bnx2_init_tx_context(struct bnx2 *bp, u32 cid)
 		offset3 = BNX2_L2CTX_TBDR_BHADDR_LO;
 	}
 	val = BNX2_L2CTX_TYPE_TYPE_L2 | BNX2_L2CTX_TYPE_SIZE_L2;
-	CTX_WR(bp, GET_CID_ADDR(cid), offset0, val);
+	bnx2_ctx_wr(bp, cid_addr, offset0, val);
 
 	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
-	CTX_WR(bp, GET_CID_ADDR(cid), offset1, val);
+	bnx2_ctx_wr(bp, cid_addr, offset1, val);
 
 	val = (u64) bp->tx_desc_mapping >> 32;
-	CTX_WR(bp, GET_CID_ADDR(cid), offset2, val);
+	bnx2_ctx_wr(bp, cid_addr, offset2, val);
 
 	val = (u64) bp->tx_desc_mapping & 0xffffffff;
-	CTX_WR(bp, GET_CID_ADDR(cid), offset3, val);
+	bnx2_ctx_wr(bp, cid_addr, offset3, val);
 }
 
 static void
@@ -4615,21 +4616,21 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
 
-	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
+	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
 	if (bp->rx_pg_ring_size) {
 		bnx2_init_rxbd_rings(bp->rx_pg_desc_ring,
 				     bp->rx_pg_desc_mapping,
 				     PAGE_SIZE, bp->rx_max_pg_ring);
 		val = (bp->rx_buf_use_size << 16) | PAGE_SIZE;
-		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, val);
-		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_RBDC_KEY,
+		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, val);
+		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_RBDC_KEY,
 		       BNX2_L2CTX_RBDC_JUMBO_KEY);
 
 		val = (u64) bp->rx_pg_desc_mapping[0] >> 32;
-		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_HI, val);
+		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_HI, val);
 
 		val = (u64) bp->rx_pg_desc_mapping[0] & 0xffffffff;
-		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
+		bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
 
 		if (CHIP_NUM(bp) == CHIP_NUM_5709)
 			REG_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
@@ -4638,13 +4639,13 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
 	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
 	val |= 0x02 << 8;
-	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
+	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
 
 	val = (u64) bp->rx_desc_mapping[0] >> 32;
-	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
+	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 
 	val = (u64) bp->rx_desc_mapping[0] & 0xffffffff;
-	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
+	bnx2_ctx_wr(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 
 	ring_prod = prod = bnapi->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index fb3c019..c5fe340 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6814,13 +6814,6 @@ struct bnx2 {
 #define REG_WR16(bp, offset, val)				\
 	writew(val, bp->regview + offset)
 
-/* Indirect context access.  Unlike the MBQ_WR, these macros will not
- * trigger a chip event. */
-static void bnx2_ctx_wr(struct bnx2 *bp, u32 cid_addr, u32 offset, u32 val);
-
-#define CTX_WR(bp, cid_addr, offset, val)			\
-	bnx2_ctx_wr(bp, cid_addr, offset, val)
-
 struct cpu_reg {
 	u32 mode;
 	u32 mode_value_halt;


