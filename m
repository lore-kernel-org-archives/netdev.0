From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: use kcalloc in netdev_queue alloc
Date: Mon, 21 Jul 2008 11:19:33 -0700
Message-ID: <20080721111933.4cdad67f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:59085 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899AbYGUSTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 14:19:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor nit, use size_t for allocation size and kcalloc to allocate
an array. Probably makes no actual code difference.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-07-21 11:13:29.000000000 -0700
+++ b/net/core/dev.c	2008-07-21 11:15:12.000000000 -0700
@@ -4198,7 +4198,7 @@ struct net_device *alloc_netdev_mq(int s
 {
 	struct netdev_queue *tx;
 	struct net_device *dev;
-	int alloc_size;
+	size_t alloc_size;
 	void *p;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
@@ -4218,7 +4218,7 @@ struct net_device *alloc_netdev_mq(int s
 		return NULL;
 	}
 
-	tx = kzalloc(sizeof(struct netdev_queue) * queue_count, GFP_KERNEL);
+	tx = kcalloc(queue_count, sizeof(struct netdev_queue), GFP_KERNEL);
 	if (!tx) {
 		printk(KERN_ERR "alloc_netdev: Unable to allocate "
 		       "tx qdiscs.\n");
