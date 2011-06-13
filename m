From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Remove 40BIT_DMA_LIMIT_BUG
Date: Mon, 13 Jun 2011 16:38:56 -0700
Message-ID: <1308008342-21030-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3148 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755371Ab1FMXiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2011 19:38:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the 40BIT_DMA_LIMIT_BUG flag.  There already exists a
flag for this purpose (TG3_FLAG_40BIT_DMA_BUG) and was already being
used in the correct spot.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    8 ++------
 drivers/net/tg3.h |    1 -
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e8f16c5..488bcf9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6022,8 +6022,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	    tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
-	if (tg3_flag(tp, 40BIT_DMA_LIMIT_BUG) &&
-	    tg3_40bit_overflow_test(tp, mapping, len))
+	if (tg3_40bit_overflow_test(tp, mapping, len))
 		would_hit_hwbug = 1;
 
 	if (tg3_flag(tp, 5701_DMA_BUG))
@@ -6060,8 +6059,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			    tg3_4g_overflow_test(mapping, len))
 				would_hit_hwbug = 1;
 
-			if (tg3_flag(tp, 40BIT_DMA_LIMIT_BUG) &&
-			    tg3_40bit_overflow_test(tp, mapping, len))
+			if (tg3_40bit_overflow_test(tp, mapping, len))
 				would_hit_hwbug = 1;
 
 			if (tg3_flag(tp, HW_TSO_1) ||
@@ -13710,8 +13708,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (tg3_flag(tp, 5755_PLUS))
 		tg3_flag_set(tp, SHORT_DMA_BUG);
-	else
-		tg3_flag_set(tp, 40BIT_DMA_LIMIT_BUG);
 
 	if (tg3_flag(tp, 5717_PLUS))
 		tg3_flag_set(tp, LRG_PROD_RING_CAP);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 3c113c1..4f5dbf6 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2897,7 +2897,6 @@ enum TG3_FLAGS {
 	TG3_FLAG_ENABLE_RSS,
 	TG3_FLAG_ENABLE_TSS,
 	TG3_FLAG_4G_DMA_BNDRY_BUG,
-	TG3_FLAG_40BIT_DMA_LIMIT_BUG,
 	TG3_FLAG_SHORT_DMA_BUG,
 	TG3_FLAG_USE_JUMBO_BDFLAG,
 	TG3_FLAG_L1PLLPD_EN,
-- 
1.7.3.4


