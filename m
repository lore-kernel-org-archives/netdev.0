From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/8] tg3: Remove 4G_DMA_BNDRY_BUG flag
Date: Mon, 13 Jun 2011 16:38:57 -0700
Message-ID: <1308008342-21030-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2435 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab1FMXiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all chips have this bug, the flag checks become useless code.
This patch removes the flag.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   14 +++-----------
 drivers/net/tg3.h |    1 -
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 488bcf9..765f3dc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5822,8 +5822,7 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
 		 */
-		} else if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
-			   tg3_4g_overflow_test(new_addr, new_skb->len)) {
+		} else if (tg3_4g_overflow_test(new_addr, new_skb->len)) {
 			pci_unmap_single(tp->pdev, new_addr, new_skb->len,
 					 PCI_DMA_TODEVICE);
 			ret = -1;
@@ -6018,8 +6017,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (tg3_flag(tp, SHORT_DMA_BUG) && len <= 8)
 		would_hit_hwbug = 1;
 
-	if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
-	    tg3_4g_overflow_test(mapping, len))
+	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
 	if (tg3_40bit_overflow_test(tp, mapping, len))
@@ -6055,8 +6053,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			    len <= 8)
 				would_hit_hwbug = 1;
 
-			if (tg3_flag(tp, 4G_DMA_BNDRY_BUG) &&
-			    tg3_4g_overflow_test(mapping, len))
+			if (tg3_4g_overflow_test(mapping, len))
 				would_hit_hwbug = 1;
 
 			if (tg3_40bit_overflow_test(tp, mapping, len))
@@ -13701,11 +13698,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
-	/* All chips can get confused if TX buffers
-	 * straddle the 4GB address boundary.
-	 */
-	tg3_flag_set(tp, 4G_DMA_BNDRY_BUG);
-
 	if (tg3_flag(tp, 5755_PLUS))
 		tg3_flag_set(tp, SHORT_DMA_BUG);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 4f5dbf6..fc33566 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2896,7 +2896,6 @@ enum TG3_FLAGS {
 	TG3_FLAG_NO_NVRAM,
 	TG3_FLAG_ENABLE_RSS,
 	TG3_FLAG_ENABLE_TSS,
-	TG3_FLAG_4G_DMA_BNDRY_BUG,
 	TG3_FLAG_SHORT_DMA_BUG,
 	TG3_FLAG_USE_JUMBO_BDFLAG,
 	TG3_FLAG_L1PLLPD_EN,
-- 
1.7.3.4


