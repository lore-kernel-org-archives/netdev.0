From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 7/8] net: deinline some functions
Date: Thu, 08 Mar 2007 12:52:21 -0800
Message-ID: <20070308205306.161028935@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35786 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933315AbXCHUym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:42 -0500
Content-Disposition: inline; filename=core-deinline.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several functions are marked inline or forced inline, but it
would be better to let the compiler decide.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/core/dev.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- net-2.6.22.orig/net/core/dev.c	2007-03-07 13:12:17.000000000 -0800
+++ net-2.6.22/net/core/dev.c	2007-03-07 14:50:51.000000000 -0800
@@ -1676,9 +1676,9 @@
 	}
 }
 
-static __inline__ int deliver_skb(struct sk_buff *skb,
-				  struct packet_type *pt_prev,
-				  struct net_device *orig_dev)
+static inline int deliver_skb(struct sk_buff *skb,
+			      struct packet_type *pt_prev,
+			      struct net_device *orig_dev)
 {
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
@@ -2068,7 +2068,7 @@
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
  */
-static __inline__ struct net_device *dev_get_idx(loff_t pos)
+static struct net_device *dev_get_idx(loff_t pos)
 {
 	struct net_device *dev;
 	loff_t i;
@@ -2839,7 +2839,7 @@
 static DEFINE_SPINLOCK(net_todo_list_lock);
 static struct list_head net_todo_list = LIST_HEAD_INIT(net_todo_list);
 
-static inline void net_set_todo(struct net_device *dev)
+static void net_set_todo(struct net_device *dev)
 {
 	spin_lock(&net_todo_list_lock);
 	list_add_tail(&dev->todo_list, &net_todo_list);

--
Stephen Hemminger <shemminger@linux-foundation.org>

