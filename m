From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/14] bnxt_en: Refactor TPA code path.
Date: Thu, 29 Dec 2016 12:13:35 -0500
Message-ID: <1483031624-20076-6-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34288 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcL2ROE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:04 -0500
Received: by mail-pg0-f50.google.com with SMTP id y62so116419947pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:04 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call tcp_gro_complete() in the common code path instead of the chip-
specific method.  The newer 5731x method is missing the call.

Signed-off-by: Michael Chan <michael.chan@broadcmo.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4a8059f..0654c3f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1127,7 +1127,6 @@ static struct sk_buff *bnxt_gro_func_5730x(struct bnxt_tpa_info *tpa_info,
 		dev_kfree_skb_any(skb);
 		return NULL;
 	}
-	tcp_gro_complete(skb);
 
 	if (nw_off) { /* tunnel */
 		struct udphdr *uh = NULL;
@@ -1177,6 +1176,8 @@ static inline struct sk_buff *bnxt_gro_skb(struct bnxt *bp,
 		       RX_TPA_END_CMP_PAYLOAD_OFFSET) >>
 		      RX_TPA_END_CMP_PAYLOAD_OFFSET_SHIFT;
 	skb = bp->gro_func(tpa_info, payload_off, TPA_END_GRO_TS(tpa_end), skb);
+	if (likely(skb))
+		tcp_gro_complete(skb);
 #endif
 	return skb;
 }
-- 
1.8.3.1
