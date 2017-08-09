From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next] net: skb_needs_check() removes CHECKSUM_NONE check for tx.
Date: Wed,  9 Aug 2017 05:04:37 -0700
Message-ID: <1502280278-9970-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34209 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752589AbdHIMFF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:05:05 -0400
Received: by mail-pf0-f196.google.com with SMTP id t86so5985235pfe.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:05:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts the commit 6e7bc478c9a0
("net: skb_needs_check() accepts CHECKSUM_NONE for tx"),
because we removed the UFO support.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1d75499add72..1024d3741d12 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2731,8 +2731,7 @@ EXPORT_SYMBOL(skb_mac_gso_segment);
 static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
 {
 	if (tx_path)
-		return skb->ip_summed != CHECKSUM_PARTIAL &&
-		       skb->ip_summed != CHECKSUM_NONE;
+		return skb->ip_summed != CHECKSUM_PARTIAL;
 
 	return skb->ip_summed == CHECKSUM_NONE;
 }
-- 
2.13.4
