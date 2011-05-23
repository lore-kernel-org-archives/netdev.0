From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/5] net: Remove prefetches from SKB list handlers.
Date: Sun, 22 May 2011 20:56:37 -0400 (EDT)
Message-ID: <20110522.205637.2279556631543204260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953Ab1EWA4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:56:39 -0400
Received: from localhost (cpe-66-108-115-211.nyc.res.rr.com [66.108.115.211])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4N0ubB6005466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:56:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Noticed by Linus.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8276815..09901fd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1783,7 +1783,7 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 
 #define skb_queue_walk(queue, skb) \
 		for (skb = (queue)->next;					\
-		     prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
+		     (skb != (struct sk_buff *)(queue));			\
 		     skb = skb->next)
 
 #define skb_queue_walk_safe(queue, skb, tmp)					\
@@ -1792,7 +1792,7 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 		     skb = tmp, tmp = skb->next)
 
 #define skb_queue_walk_from(queue, skb)						\
-		for (; prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
+		for (; (skb != (struct sk_buff *)(queue));			\
 		     skb = skb->next)
 
 #define skb_queue_walk_from_safe(queue, skb, tmp)				\
@@ -1802,7 +1802,7 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 
 #define skb_queue_reverse_walk(queue, skb) \
 		for (skb = (queue)->prev;					\
-		     prefetch(skb->prev), (skb != (struct sk_buff *)(queue));	\
+		     (skb != (struct sk_buff *)(queue));			\
 		     skb = skb->prev)
 
 #define skb_queue_reverse_walk_safe(queue, skb, tmp)				\
-- 
1.7.4.4

