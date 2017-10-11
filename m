From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] vxge: Clean up unused variables in vxge-traffic
Date: Wed, 11 Oct 2017 20:26:58 +0100
Message-ID: <1507750018-7131-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delete unused channel variables in vxge-traffic.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
index 5f630a2..0c3b5de 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
@@ -1209,9 +1209,6 @@ void vxge_hw_ring_rxd_pre_post(struct __vxge_hw_ring *ring, void *rxdh)
 void vxge_hw_ring_rxd_post_post(struct __vxge_hw_ring *ring, void *rxdh)
 {
 	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
-	struct __vxge_hw_channel *channel;
-
-	channel = &ring->channel;
 
 	rxdp->control_0	= VXGE_HW_RING_RXD_LIST_OWN_ADAPTER;
 
@@ -1359,11 +1356,8 @@ enum vxge_hw_status vxge_hw_ring_rxd_next_completed(
 enum vxge_hw_status vxge_hw_ring_handle_tcode(
 	struct __vxge_hw_ring *ring, void *rxdh, u8 t_code)
 {
-	struct __vxge_hw_channel *channel;
 	enum vxge_hw_status status = VXGE_HW_OK;
 
-	channel = &ring->channel;
-
 	/* If the t_code is not supported and if the
 	 * t_code is other than 0x5 (unparseable packet
 	 * such as unknown UPV6 header), Drop it !!!
@@ -1399,10 +1393,6 @@ enum vxge_hw_status vxge_hw_ring_handle_tcode(
 static void __vxge_hw_non_offload_db_post(struct __vxge_hw_fifo *fifo,
 	u64 txdl_ptr, u32 num_txds, u32 no_snoop)
 {
-	struct __vxge_hw_channel *channel;
-
-	channel = &fifo->channel;
-
 	writeq(VXGE_HW_NODBW_TYPE(VXGE_HW_NODBW_TYPE_NODBW) |
 		VXGE_HW_NODBW_LAST_TXD_NUMBER(num_txds) |
 		VXGE_HW_NODBW_GET_NO_SNOOP(no_snoop),
@@ -1506,9 +1496,6 @@ void vxge_hw_fifo_txdl_buffer_set(struct __vxge_hw_fifo *fifo,
 {
 	struct __vxge_hw_fifo_txdl_priv *txdl_priv;
 	struct vxge_hw_fifo_txd *txdp, *txdp_last;
-	struct __vxge_hw_channel *channel;
-
-	channel = &fifo->channel;
 
 	txdl_priv = __vxge_hw_fifo_txdl_priv(fifo, txdlh);
 	txdp = (struct vxge_hw_fifo_txd *)txdlh  +  txdl_priv->frags;
@@ -1554,9 +1541,6 @@ void vxge_hw_fifo_txdl_post(struct __vxge_hw_fifo *fifo, void *txdlh)
 	struct __vxge_hw_fifo_txdl_priv *txdl_priv;
 	struct vxge_hw_fifo_txd *txdp_last;
 	struct vxge_hw_fifo_txd *txdp_first;
-	struct __vxge_hw_channel *channel;
-
-	channel = &fifo->channel;
 
 	txdl_priv = __vxge_hw_fifo_txdl_priv(fifo, txdlh);
 	txdp_first = txdlh;
@@ -1672,10 +1656,7 @@ enum vxge_hw_status vxge_hw_fifo_handle_tcode(struct __vxge_hw_fifo *fifo,
 					      void *txdlh,
 					      enum vxge_hw_fifo_tcode t_code)
 {
-	struct __vxge_hw_channel *channel;
-
 	enum vxge_hw_status status = VXGE_HW_OK;
-	channel = &fifo->channel;
 
 	if (((t_code & 0x7) < 0) || ((t_code & 0x7) > 0x4)) {
 		status = VXGE_HW_ERR_INVALID_TCODE;
-- 
2.7.4
