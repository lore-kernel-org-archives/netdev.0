From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: remove some sparse warnings
Date: Wed, 04 Feb 2015 13:37:44 -0800
Message-ID: <1423085864.31870.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:50356 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932669AbbBDVhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:37:46 -0500
Received: by mail-ie0-f176.google.com with SMTP id at20so5515001iec.7
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 13:37:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

netdev_adjacent_add_links() and netdev_adjacent_del_links()
are static.

queue->qdisc has __rcu annotation, need to use RCU_INIT_POINTER()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c87a2264a02b..7fe82929f509 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5294,7 +5294,7 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
-void netdev_adjacent_add_links(struct net_device *dev)
+static void netdev_adjacent_add_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
@@ -5319,7 +5319,7 @@ void netdev_adjacent_add_links(struct net_device *dev)
 	}
 }
 
-void netdev_adjacent_del_links(struct net_device *dev)
+static void netdev_adjacent_del_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
 
@@ -6627,7 +6627,7 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 	if (!queue)
 		return NULL;
 	netdev_init_one_queue(dev, queue, NULL);
-	queue->qdisc = &noop_qdisc;
+	RCU_INIT_POINTER(queue->qdisc, &noop_qdisc);
 	queue->qdisc_sleeping = &noop_qdisc;
 	rcu_assign_pointer(dev->ingress_queue, queue);
 #endif
