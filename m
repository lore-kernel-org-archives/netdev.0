From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] net: Add safe reverse SKB queue walkers.
Date: Thu, 20 Jan 2011 23:56:06 -0800 (PST)
Message-ID: <20110120.235606.191173896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55752
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752078Ab1AUHzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 02:55:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf221d6..6e946da 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1801,6 +1801,15 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 		     prefetch(skb->prev), (skb != (struct sk_buff *)(queue));	\
 		     skb = skb->prev)
 
+#define skb_queue_reverse_walk_safe(queue, skb, tmp)				\
+		for (skb = (queue)->prev, tmp = skb->prev;			\
+		     skb != (struct sk_buff *)(queue);				\
+		     skb = tmp, tmp = skb->prev)
+
+#define skb_queue_reverse_walk_from_safe(queue, skb, tmp)			\
+		for (tmp = skb->prev;						\
+		     skb != (struct sk_buff *)(queue);				\
+		     skb = tmp, tmp = skb->prev)
 
 static inline bool skb_has_frag_list(const struct sk_buff *skb)
 {
-- 
1.7.3.4

