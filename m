From: David Miller <davem@davemloft.net>
Subject: [PATCH]: net: Add skb_queue_walk_from() and
 skb_queue_walk_from_safe().
Date: Tue, 23 Sep 2008 01:06:55 -0700 (PDT)
Message-ID: <20080923.010655.250864105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52462
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751926AbYIWIHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:07:07 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0BA0EC8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:06:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Add skb_queue_walk_from() and skb_queue_walk_from_safe().

These will be used by TCP write queue handling and elsewhere.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d2f1778..a19ea43 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1571,6 +1571,15 @@ static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
 		     skb != (struct sk_buff *)(queue);				\
 		     skb = tmp, tmp = skb->next)
 
+#define skb_queue_walk_from(queue, skb)						\
+		for (; prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
+		     skb = skb->next)
+
+#define skb_queue_walk_from_safe(queue, skb, tmp)				\
+		for (tmp = skb->next;						\
+		     skb != (struct sk_buff *)(queue);				\
+		     skb = tmp, tmp = skb->next)
+
 #define skb_queue_reverse_walk(queue, skb) \
 		for (skb = (queue)->prev;					\
 		     prefetch(skb->prev), (skb != (struct sk_buff *)(queue));	\
-- 
1.5.6.5

