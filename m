From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] skb: make skb_recycle_check() return a bool value
Date: Thu, 27 May 2010 22:33:23 +0800
Message-ID: <1274970803-8051-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f176.google.com ([209.85.222.176]:52980 "EHLO
	mail-pz0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757707Ab0E0Og4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 10:36:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make skb_recycle_check() return a bool value

make skb_recycle_check() return a bool value

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/skbuff.h |    2 +-
 net/core/skbuff.c      |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7cdfb4d..bf243fc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -501,7 +501,7 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, -1);
 }
 
-extern int skb_recycle_check(struct sk_buff *skb, int skb_size);
+extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
 
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c543dd2..d430876 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -482,22 +482,22 @@ EXPORT_SYMBOL(consume_skb);
  *	reference count dropping and cleans up the skbuff as if it
  *	just came from __alloc_skb().
  */
-int skb_recycle_check(struct sk_buff *skb, int skb_size)
+bool skb_recycle_check(struct sk_buff *skb, int skb_size)
 {
 	struct skb_shared_info *shinfo;
 
 	if (irqs_disabled())
-		return 0;
+		return false;
 
 	if (skb_is_nonlinear(skb) || skb->fclone != SKB_FCLONE_UNAVAILABLE)
-		return 0;
+		return false;
 
 	skb_size = SKB_DATA_ALIGN(skb_size + NET_SKB_PAD);
 	if (skb_end_pointer(skb) - skb->head < skb_size)
-		return 0;
+		return false;
 
 	if (skb_shared(skb) || skb_cloned(skb))
-		return 0;
+		return false;
 
 	skb_release_head_state(skb);
 
@@ -509,7 +509,7 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
 	skb->data = skb->head + NET_SKB_PAD;
 	skb_reset_tail_pointer(skb);
 
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL(skb_recycle_check);
 
