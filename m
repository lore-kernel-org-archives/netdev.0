From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next] net: skb_needs_check() removes CHECKSUM_UNNECESSARY check for tx.
Date: Thu, 10 Aug 2017 20:16:29 -0700
Message-ID: <1502421389-20152-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35146 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdHKDQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 23:16:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id j68so2322297pfc.2
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 20:16:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we remove the UFO support, we will also remove the
CHECKSUM_UNNECESSARY check in skb_needs_check().

Cc: Willem de Bruijn <willemb@google.com>
Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3f69f6e..1024d37 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2731,8 +2731,7 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 {
 	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL &&
-		       skb->ip_summed != CHECKSUM_UNNECESSARY;
+		return skb->ip_summed != CHECKSUM_PARTIAL;
 
 	return skb->ip_summed == CHECKSUM_NONE;
 }
-- 
1.8.3.1
