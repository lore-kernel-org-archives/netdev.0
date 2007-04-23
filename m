From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/5 2.6.21-rc7] skb: introduce skb_queue_walk_safe()
Date: Mon, 23 Apr 2007 17:01:03 +0100
Message-ID: <200704231601.l3NG13pH030160@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33736 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbXDWQBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 12:01:44 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1Hg0yx-0002Dl-A9
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 11:01:39 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3NG13FJ030166
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 17:01:03 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3NG13pH030160
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 17:01:03 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SKB]: Introduce skb_queue_walk_safe()

This patch provides a method for walking skb lists while inserting or
removing skbs from the list.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc7/include/linux/skbuff.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/skbuff.h
+++ linux-2.6.21-rc7/include/linux/skbuff.h
@@ -1299,6 +1299,11 @@ static inline int pskb_trim_rcsum(struct
 		     prefetch(skb->next), (skb != (struct sk_buff *)(queue));	\
 		     skb = skb->next)
 
+#define skb_queue_walk_safe(queue, skb, tmp)					\
+		for (skb = (queue)->next, tmp = skb->next;			\
+		     skb != (struct sk_buff *)(queue);				\
+		     skb = tmp, tmp = skb->next)
+
 #define skb_queue_reverse_walk(queue, skb) \
 		for (skb = (queue)->prev;					\
 		     prefetch(skb->prev), (skb != (struct sk_buff *)(queue));	\
