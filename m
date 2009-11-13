From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 14/20] tg3: rename rx_[std|jmb]_ptr
Date: Fri, 13 Nov 2009 15:03:46 -0800
Message-ID: <1258153432-7036-15-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4579 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932483AbZKMXE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 18:04:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A later patch is going to add consumer indicies for the producer rings.
To keep things readable, this patch renames rx_[std|jmb]_ptr to
rx_[std|jmb]_prod_idx.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   16 ++++++++--------
 drivers/net/tg3.h |    4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 00e7e14..59a715a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4564,13 +4564,13 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 			ri = &tpr->rx_std_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
-			post_ptr = &tpr->rx_std_ptr;
+			post_ptr = &tpr->rx_std_prod_idx;
 			rx_std_posted++;
 		} else if (opaque_key == RXD_OPAQUE_RING_JUMBO) {
 			ri = &tpr->rx_jmb_buffers[desc_idx];
 			dma_addr = pci_unmap_addr(ri, mapping);
 			skb = ri->skb;
-			post_ptr = &tpr->rx_jmb_ptr;
+			post_ptr = &tpr->rx_jmb_prod_idx;
 		} else
 			goto next_pkt_nopost;
 
@@ -4687,12 +4687,12 @@ next_pkt_nopost:
 
 	/* Refill RX ring(s). */
 	if (work_mask & RXD_OPAQUE_RING_STD) {
-		sw_idx = tpr->rx_std_ptr % TG3_RX_RING_SIZE;
+		sw_idx = tpr->rx_std_prod_idx % TG3_RX_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
 	if (work_mask & RXD_OPAQUE_RING_JUMBO) {
-		sw_idx = tpr->rx_jmb_ptr % TG3_RX_JUMBO_RING_SIZE;
+		sw_idx = tpr->rx_jmb_prod_idx % TG3_RX_JUMBO_RING_SIZE;
 		tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
 			     sw_idx);
 	}
@@ -7509,14 +7509,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_MAXLEN_FLAGS, val);
 
-	tpr->rx_std_ptr = tp->rx_pending;
+	tpr->rx_std_prod_idx = tp->rx_pending;
 	tw32_rx_mbox(MAILBOX_RCV_STD_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tpr->rx_std_ptr);
+		     tpr->rx_std_prod_idx);
 
-	tpr->rx_jmb_ptr = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
+	tpr->rx_jmb_prod_idx = (tp->tg3_flags & TG3_FLAG_JUMBO_RING_ENABLE) ?
 			  tp->rx_jumbo_pending : 0;
 	tw32_rx_mbox(MAILBOX_RCV_JUMBO_PROD_IDX + TG3_64BIT_REG_LOW,
-		     tpr->rx_jmb_ptr);
+		     tpr->rx_jmb_prod_idx);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717) {
 		tw32(STD_REPLENISH_LWM, 32);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 42fefa1..e0b86ba 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2570,8 +2570,8 @@ struct tg3_ethtool_stats {
 };
 
 struct tg3_rx_prodring_set {
-	u32				rx_std_ptr;
-	u32				rx_jmb_ptr;
+	u32				rx_std_prod_idx;
+	u32				rx_jmb_prod_idx;
 	struct tg3_rx_buffer_desc	*rx_std;
 	struct tg3_ext_rx_buffer_desc	*rx_jmb;
 	struct ring_info		*rx_std_buffers;
-- 
1.6.4.4


