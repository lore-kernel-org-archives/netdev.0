From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 3/4] net: Add safe reverse SKB queue walkers.
Date: Tue, 05 Oct 2010 19:52:34 -0700 (PDT)
Message-ID: <20101005.195234.189715887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758450Ab0JFCwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 22:52:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6043424C087
	for <netdev@vger.kernel.org>; Tue,  5 Oct 2010 19:52:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0b53c43..6c3181c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1788,6 +1788,15 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
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
1.7.2.3

