From: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH] mwifiex: add __GFP_REPEAT to skb allocation call
Date: Tue, 29 Mar 2016 12:47:20 +0800
Message-ID: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, snanda-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"single skb allocation failure" happens when system is under heavy
memory pressure.  Add __GFP_REPEAT to skb allocation call so kernel
attempts to reclaim pages and retry the allocation.

Signed-off-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/wireless/marvell/mwifiex/sdio.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index b2c839a..c64989c 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -1124,7 +1124,8 @@ static void mwifiex_deaggr_sdio_pkt(struct mwifiex_adapter *adapter,
 			break;
 		}
 		skb_deaggr = mwifiex_alloc_dma_align_buf(pkt_len,
-							 GFP_KERNEL | GFP_DMA);
+							 GFP_KERNEL | GFP_DMA |
+							 __GFP_REPEAT);
 		if (!skb_deaggr)
 			break;
 		skb_put(skb_deaggr, pkt_len);
@@ -1374,7 +1375,8 @@ static int mwifiex_sdio_card_to_host_mp_aggr(struct mwifiex_adapter *adapter,
 			/* copy pkt to deaggr buf */
 			skb_deaggr = mwifiex_alloc_dma_align_buf(len_arr[pind],
 								 GFP_KERNEL |
-								 GFP_DMA);
+								 GFP_DMA |
+								 __GFP_REPEAT);
 			if (!skb_deaggr) {
 				mwifiex_dbg(adapter, ERROR, "skb allocation failure\t"
 					    "drop pkt len=%d type=%d\n",
@@ -1416,7 +1418,8 @@ rx_curr_single:
 		mwifiex_dbg(adapter, INFO, "info: RX: port: %d, rx_len: %d\n",
 			    port, rx_len);
 
-		skb = mwifiex_alloc_dma_align_buf(rx_len, GFP_KERNEL | GFP_DMA);
+		skb = mwifiex_alloc_dma_align_buf(rx_len, GFP_KERNEL | GFP_DMA |
+						  __GFP_REPEAT);
 		if (!skb) {
 			mwifiex_dbg(adapter, ERROR,
 				    "single skb allocated fail,\t"
@@ -1521,7 +1524,8 @@ static int mwifiex_process_int_status(struct mwifiex_adapter *adapter)
 		rx_len = (u16) (rx_blocks * MWIFIEX_SDIO_BLOCK_SIZE);
 		mwifiex_dbg(adapter, INFO, "info: rx_len = %d\n", rx_len);
 
-		skb = mwifiex_alloc_dma_align_buf(rx_len, GFP_KERNEL | GFP_DMA);
+		skb = mwifiex_alloc_dma_align_buf(rx_len, GFP_KERNEL | GFP_DMA |
+						  __GFP_REPEAT);
 		if (!skb)
 			return -1;
 
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
