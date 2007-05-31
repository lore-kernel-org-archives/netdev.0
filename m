From: Rankle_ <crquan@gmail.com>
Subject: [git patch] since the definition of dst_discard_in and dst_discard_out
 are the same,,they should merged into one
Date: Thu, 31 May 2007 15:26:54 +0800
Message-ID: <465E78BE.6010807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.230]:1430 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665AbXEaH1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 03:27:01 -0400
Received: by nz-out-0506.google.com with SMTP id n1so75850nzf
        for <netdev@vger.kernel.org>; Thu, 31 May 2007 00:27:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From 30d6996860f7e5589d1bce10404bbcfd6592c9de Mon Sep 17 00:00:00 2001
From: Denis Cheng <crquan@gmail.com>
Date: Thu, 31 May 2007 15:21:58 +0800
Subject: [PATCH] since the definition of dst_discard_in and 
dst_discard_out are the same,
they should merged into one

Signed-off-by: Denis Cheng <crquan@gmail.com>

diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..c6a0587 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -111,13 +111,7 @@ out:
     spin_unlock(&dst_lock);
 }
 
-static int dst_discard_in(struct sk_buff *skb)
-{
-    kfree_skb(skb);
-    return 0;
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
-    dst->input = dst_discard_in;
-    dst->output = dst_discard_out;
+    dst->input = dst->output = dst_discard;
 #if RT_CACHE_DEBUG >= 2
     atomic_inc(&dst_total);
 #endif
@@ -153,8 +146,7 @@ static void ___dst_free(struct dst_entry * dst)
        protocol module is unloaded.
      */
     if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
-        dst->input = dst_discard_in;
-        dst->output = dst_discard_out;
+        dst->input = dst->output = dst_discard;
     }
     dst->obsolete = 2;
 }
@@ -242,8 +234,7 @@ static inline void dst_ifdown(struct dst_entry *dst, 
struct net_device *dev,
         return;
 
     if (!unregister) {
-        dst->input = dst_discard_in;
-        dst->output = dst_discard_out;
+        dst->input = dst->output = dst_discard;
     } else {
         dst->dev = &loopback_dev;
         dev_hold(&loopback_dev);
