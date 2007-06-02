From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH] since the definition of dst_discard_in and dst_discard_out
	are the same,
Date: Fri, 01 Jun 2007 19:08:51 -0700 (PDT)
Message-ID: <4660d133.4d65d79b.64d5.72fc@mx.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:56023 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758694AbXFBCIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 22:08:53 -0400
Received: by wa-out-1112.google.com with SMTP id j4so732079wah
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 19:08:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

they should merged into one

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/core/dst.c |   17 ++++-------------
 1 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..c6a0587 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -111,13 +111,7 @@ out:
 	spin_unlock(&dst_lock);
 }
 
-static int dst_discard_in(struct sk_buff *skb)
-{
-	kfree_skb(skb);
-	return 0;
-}
-
-static int dst_discard_out(struct sk_buff *skb)
+static int dst_discard(struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return 0;
@@ -138,8 +132,7 @@ void * dst_alloc(struct dst_ops * ops)
 	dst->ops = ops;
 	dst->lastuse = jiffies;
 	dst->path = dst;
-	dst->input = dst_discard_in;
-	dst->output = dst_discard_out;
+	dst->input = dst->output = dst_discard;
 #if RT_CACHE_DEBUG >= 2
 	atomic_inc(&dst_total);
 #endif
@@ -153,8 +146,7 @@ static void ___dst_free(struct dst_entry * dst)
 	   protocol module is unloaded.
 	 */
 	if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
-		dst->input = dst_discard_in;
-		dst->output = dst_discard_out;
+		dst->input = dst->output = dst_discard;
 	}
 	dst->obsolete = 2;
 }
@@ -242,8 +234,7 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 		return;
 
 	if (!unregister) {
-		dst->input = dst_discard_in;
-		dst->output = dst_discard_out;
+		dst->input = dst->output = dst_discard;
 	} else {
 		dst->dev = &loopback_dev;
 		dev_hold(&loopback_dev);
-- 
1.4.4.2

