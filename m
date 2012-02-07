From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] e1000e: minor whitespace and indentation cleanup
Date: Tue,  7 Feb 2012 04:33:58 -0800
Message-ID: <1328618038-5008-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40692 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172Ab2BGMeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:16 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Cleanup of some whitespace and indentation of a single code block.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    4 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  |   76 ++++++++++++++------------
 2 files changed, 43 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 0e64cc4..5061d4d 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -280,8 +280,8 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 
 #define er16flash(reg)		__er16flash(hw, (reg))
 #define er32flash(reg)		__er32flash(hw, (reg))
-#define ew16flash(reg,val)	__ew16flash(hw, (reg), (val))
-#define ew32flash(reg,val)	__ew32flash(hw, (reg), (val))
+#define ew16flash(reg, val)	__ew16flash(hw, (reg), (val))
+#define ew32flash(reg, val)	__ew32flash(hw, (reg), (val))
 
 static void e1000_toggle_lanphypc_value_ich8lan(struct e1000_hw *hw)
 {
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2ac1164..293a760 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1267,43 +1267,49 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 		skb_put(skb, length);
 
 		{
-		/*
-		 * this looks ugly, but it seems compiler issues make it
-		 * more efficient than reusing j
-		 */
-		int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
-
-		/*
-		 * page alloc/put takes too long and effects small packet
-		 * throughput, so unsplit small packets and save the alloc/put
-		 * only valid in softirq (napi) context to call kmap_*
-		 */
-		if (l1 && (l1 <= copybreak) &&
-		    ((length + l1) <= adapter->rx_ps_bsize0)) {
-			u8 *vaddr;
-
-			ps_page = &buffer_info->ps_pages[0];
+			/*
+			 * this looks ugly, but it seems compiler issues make
+			 * it more efficient than reusing j
+			 */
+			int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
 
 			/*
-			 * there is no documentation about how to call
-			 * kmap_atomic, so we can't hold the mapping
-			 * very long
+			 * page alloc/put takes too long and effects small
+			 * packet throughput, so unsplit small packets and
+			 * save the alloc/put only valid in softirq (napi)
+			 * context to call kmap_*
 			 */
-			dma_sync_single_for_cpu(&pdev->dev, ps_page->dma,
-						PAGE_SIZE, DMA_FROM_DEVICE);
-			vaddr = kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
-			memcpy(skb_tail_pointer(skb), vaddr, l1);
-			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
-			dma_sync_single_for_device(&pdev->dev, ps_page->dma,
-						   PAGE_SIZE, DMA_FROM_DEVICE);
-
-			/* remove the CRC */
-			if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
-				l1 -= 4;
-
-			skb_put(skb, l1);
-			goto copydone;
-		} /* if */
+			if (l1 && (l1 <= copybreak) &&
+			    ((length + l1) <= adapter->rx_ps_bsize0)) {
+				u8 *vaddr;
+
+				ps_page = &buffer_info->ps_pages[0];
+
+				/*
+				 * there is no documentation about how to call
+				 * kmap_atomic, so we can't hold the mapping
+				 * very long
+				 */
+				dma_sync_single_for_cpu(&pdev->dev,
+							ps_page->dma,
+							PAGE_SIZE,
+							DMA_FROM_DEVICE);
+				vaddr = kmap_atomic(ps_page->page,
+						    KM_SKB_DATA_SOFTIRQ);
+				memcpy(skb_tail_pointer(skb), vaddr, l1);
+				kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+				dma_sync_single_for_device(&pdev->dev,
+							   ps_page->dma,
+							   PAGE_SIZE,
+							   DMA_FROM_DEVICE);
+
+				/* remove the CRC */
+				if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
+					l1 -= 4;
+
+				skb_put(skb, l1);
+				goto copydone;
+			} /* if */
 		}
 
 		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
@@ -4969,7 +4975,7 @@ static int e1000_maybe_stop_tx(struct e1000_ring *tx_ring, int size)
 	return __e1000_maybe_stop_tx(tx_ring, size);
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
+#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1)
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev)
 {
-- 
1.7.7.6
