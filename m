From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] net: make skb_dst_pop routine static
Date: Tue, 12 May 2015 18:29:44 +0800
Message-ID: <1431426584-13603-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40791 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbbELKbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 06:31:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As xfrm_output_one() is the only caller of skb_dst_pop(), we should
make skb_dst_pop() localized.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/net/dst.h      |   12 ------------
 net/xfrm/xfrm_output.c |   12 ++++++++++++
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 22aa93f..2bc73f8a 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -349,18 +349,6 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev,
 	__skb_tunnel_rx(skb, dev, net);
 }
 
-/* Children define the path of the packet through the
- * Linux networking.  Thus, destinations are stackable.
- */
-
-static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
-{
-	struct dst_entry *child = dst_clone(skb_dst(skb)->child);
-
-	skb_dst_drop(skb);
-	return child;
-}
-
 int dst_discard_sk(struct sock *sk, struct sk_buff *skb);
 static inline int dst_discard(struct sk_buff *skb)
 {
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index fbcedbe..68ada2c 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -38,6 +38,18 @@ static int xfrm_skb_check_space(struct sk_buff *skb)
 	return pskb_expand_head(skb, nhead, ntail, GFP_ATOMIC);
 }
 
+/* Children define the path of the packet through the
+ * Linux networking.  Thus, destinations are stackable.
+ */
+
+static struct dst_entry *skb_dst_pop(struct sk_buff *skb)
+{
+	struct dst_entry *child = dst_clone(skb_dst(skb)->child);
+
+	skb_dst_drop(skb);
+	return child;
+}
+
 static int xfrm_output_one(struct sk_buff *skb, int err)
 {
 	struct dst_entry *dst = skb_dst(skb);
-- 
1.7.9.5
