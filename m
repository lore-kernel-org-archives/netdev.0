From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 3/7] bnx2x: decrease indentation in bnx2x_rx_int()
Date: Tue, 30 Aug 2011 16:30:42 +0200
Message-ID: <1314714646-3642-4-git-send-email-mschmidt@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754534Ab1H3ObM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:12 -0400
In-Reply-To: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For better readability decrease the indentation in bnx2x_rx_int().
'else' is unnecessary when the positive branch ends with a 'goto'.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  194 +++++++++++------------
 1 files changed, 92 insertions(+), 102 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 448e301..f1fea58 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -624,135 +624,125 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 		if (unlikely(CQE_TYPE_SLOW(cqe_fp_type))) {
 			bnx2x_sp_event(fp, cqe);
 			goto next_cqe;
+		}
 
 		/* this is an rx packet */
-		} else {
-			rx_buf = &fp->rx_buf_ring[bd_cons];
-			skb = rx_buf->skb;
-			prefetch(skb);
+		rx_buf = &fp->rx_buf_ring[bd_cons];
+		skb = rx_buf->skb;
+		prefetch(skb);
 
-			if (!CQE_TYPE_FAST(cqe_fp_type)) {
+		if (!CQE_TYPE_FAST(cqe_fp_type)) {
 #ifdef BNX2X_STOP_ON_ERROR
-				/* sanity check */
-				if (fp->disable_tpa &&
-				    (CQE_TYPE_START(cqe_fp_type) ||
-				     CQE_TYPE_STOP(cqe_fp_type)))
-					BNX2X_ERR("START/STOP packet while "
-						  "disable_tpa type %x\n",
-						  CQE_TYPE(cqe_fp_type));
+			/* sanity check */
+			if (fp->disable_tpa &&
+			    (CQE_TYPE_START(cqe_fp_type) ||
+			     CQE_TYPE_STOP(cqe_fp_type)))
+				BNX2X_ERR("START/STOP packet while "
+					  "disable_tpa type %x\n",
+					  CQE_TYPE(cqe_fp_type));
 #endif
 
-				if (CQE_TYPE_START(cqe_fp_type)) {
-					u16 queue = cqe_fp->queue_index;
-					DP(NETIF_MSG_RX_STATUS,
-					   "calling tpa_start on queue %d\n",
-					   queue);
+			if (CQE_TYPE_START(cqe_fp_type)) {
+				u16 queue = cqe_fp->queue_index;
+				DP(NETIF_MSG_RX_STATUS,
+				   "calling tpa_start on queue %d\n", queue);
 
-					bnx2x_tpa_start(fp, queue, skb,
-							bd_cons, bd_prod,
-							cqe_fp);
+				bnx2x_tpa_start(fp, queue, skb,
+						bd_cons, bd_prod, cqe_fp);
 
-					/* Set Toeplitz hash for LRO skb */
-					bnx2x_set_skb_rxhash(bp, cqe, skb);
+				/* Set Toeplitz hash for LRO skb */
+				bnx2x_set_skb_rxhash(bp, cqe, skb);
 
-					goto next_rx;
+				goto next_rx;
 
-				} else {
-					u16 queue =
-						cqe->end_agg_cqe.queue_index;
-					DP(NETIF_MSG_RX_STATUS,
-					   "calling tpa_stop on queue %d\n",
-					   queue);
+			} else {
+				u16 queue =
+					cqe->end_agg_cqe.queue_index;
+				DP(NETIF_MSG_RX_STATUS,
+				   "calling tpa_stop on queue %d\n", queue);
 
-					bnx2x_tpa_stop(bp, fp, queue,
-						       &cqe->end_agg_cqe,
-						       comp_ring_cons);
+				bnx2x_tpa_stop(bp, fp, queue, &cqe->end_agg_cqe,
+					       comp_ring_cons);
 #ifdef BNX2X_STOP_ON_ERROR
-					if (bp->panic)
-						return 0;
+				if (bp->panic)
+					return 0;
 #endif
 
-					bnx2x_update_sge_prod(fp, cqe_fp);
-					goto next_cqe;
-				}
+				bnx2x_update_sge_prod(fp, cqe_fp);
+				goto next_cqe;
 			}
-			/* non TPA */
-			len = le16_to_cpu(cqe_fp->pkt_len);
-			pad = cqe_fp->placement_offset;
-			dma_sync_single_for_cpu(&bp->pdev->dev,
+		}
+		/* non TPA */
+		len = le16_to_cpu(cqe_fp->pkt_len);
+		pad = cqe_fp->placement_offset;
+		dma_sync_single_for_cpu(&bp->pdev->dev,
 					dma_unmap_addr(rx_buf, mapping),
-						       pad + RX_COPY_THRESH,
-						       DMA_FROM_DEVICE);
-			prefetch(((char *)(skb)) + L1_CACHE_BYTES);
+					pad + RX_COPY_THRESH, DMA_FROM_DEVICE);
+		prefetch(((char *)(skb)) + L1_CACHE_BYTES);
 
-			/* is this an error packet? */
-			if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
+		/* is this an error packet? */
+		if (unlikely(cqe_fp_flags & ETH_RX_ERROR_FALGS)) {
+			DP(NETIF_MSG_RX_ERR, "ERROR  flags %x  rx packet %u\n",
+			   cqe_fp_flags, sw_comp_cons);
+			fp->eth_q_stats.rx_err_discard_pkt++;
+			goto reuse_rx;
+		}
+
+		/*
+		 * Since we don't have a jumbo ring,
+		 * copy small packets if mtu > 1500
+		 */
+		if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
+		    (len <= RX_COPY_THRESH)) {
+			struct sk_buff *new_skb;
+
+			new_skb = netdev_alloc_skb(bp->dev, len + pad);
+			if (new_skb == NULL) {
 				DP(NETIF_MSG_RX_ERR,
-				   "ERROR  flags %x  rx packet %u\n",
-				   cqe_fp_flags, sw_comp_cons);
-				fp->eth_q_stats.rx_err_discard_pkt++;
+				   "ERROR  packet dropped "
+				   "because of alloc failure\n");
+				fp->eth_q_stats.rx_skb_alloc_failed++;
 				goto reuse_rx;
 			}
 
-			/* Since we don't have a jumbo ring
-			 * copy small packets if mtu > 1500
-			 */
-			if ((bp->dev->mtu > ETH_MAX_PACKET_SIZE) &&
-			    (len <= RX_COPY_THRESH)) {
-				struct sk_buff *new_skb;
-
-				new_skb = netdev_alloc_skb(bp->dev, len + pad);
-				if (new_skb == NULL) {
-					DP(NETIF_MSG_RX_ERR,
-					   "ERROR  packet dropped "
-					   "because of alloc failure\n");
-					fp->eth_q_stats.rx_skb_alloc_failed++;
-					goto reuse_rx;
-				}
-
-				/* aligned copy */
-				skb_copy_from_linear_data_offset(skb, pad,
-						    new_skb->data + pad, len);
-				skb_reserve(new_skb, pad);
-				skb_put(new_skb, len);
+			/* aligned copy */
+			skb_copy_from_linear_data_offset(skb, pad,
+						new_skb->data + pad, len);
+			skb_reserve(new_skb, pad);
+			skb_put(new_skb, len);
 
-				bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
+			bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
 
-				skb = new_skb;
+			skb = new_skb;
 
-			} else
-			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
-				dma_unmap_single(&bp->pdev->dev,
-					dma_unmap_addr(rx_buf, mapping),
-						 fp->rx_buf_size,
-						 DMA_FROM_DEVICE);
-				skb_reserve(skb, pad);
-				skb_put(skb, len);
+		} else if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(rx_buf, mapping),
+					 fp->rx_buf_size, DMA_FROM_DEVICE);
+			skb_reserve(skb, pad);
+			skb_put(skb, len);
 
-			} else {
-				DP(NETIF_MSG_RX_ERR,
-				   "ERROR  packet dropped because "
-				   "of alloc failure\n");
-				fp->eth_q_stats.rx_skb_alloc_failed++;
+		} else {
+			DP(NETIF_MSG_RX_ERR,
+			   "ERROR  packet dropped because of alloc failure\n");
+			fp->eth_q_stats.rx_skb_alloc_failed++;
 reuse_rx:
-				bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
-				goto next_rx;
-			}
-
-			skb->protocol = eth_type_trans(skb, bp->dev);
+			bnx2x_reuse_rx_skb(fp, bd_cons, bd_prod);
+			goto next_rx;
+		}
 
-			/* Set Toeplitz hash for a none-LRO skb */
-			bnx2x_set_skb_rxhash(bp, cqe, skb);
+		skb->protocol = eth_type_trans(skb, bp->dev);
 
-			skb_checksum_none_assert(skb);
+		/* Set Toeplitz hash for a none-LRO skb */
+		bnx2x_set_skb_rxhash(bp, cqe, skb);
 
-			if (bp->dev->features & NETIF_F_RXCSUM) {
+		skb_checksum_none_assert(skb);
 
-				if (likely(BNX2X_RX_CSUM_OK(cqe)))
-					skb->ip_summed = CHECKSUM_UNNECESSARY;
-				else
-					fp->eth_q_stats.hw_csum_err++;
-			}
+		if (bp->dev->features & NETIF_F_RXCSUM) {
+			if (likely(BNX2X_RX_CSUM_OK(cqe)))
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				fp->eth_q_stats.hw_csum_err++;
 		}
 
 		skb_record_rx_queue(skb, fp->index);
-- 
1.7.6
