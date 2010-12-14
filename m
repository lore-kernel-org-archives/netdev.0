From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: use NUMA_NO_NODE instead of the magic number -1
Date: Tue, 14 Dec 2010 21:09:15 +0800
Message-ID: <1292332155-25151-1-git-send-email-xiaosuo@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:57761 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305Ab0LNNJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 08:09:41 -0500
Received: by pva4 with SMTP id 4so94359pva.19
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 05:09:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    2 +-
 net/core/net-sysfs.c      |    3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d31bc3c..56c38bb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -530,7 +530,7 @@ static inline int netdev_queue_numa_node_read(const struct netdev_queue *q)
 #if defined(CONFIG_XPS) && defined(CONFIG_NUMA)
 	return q->numa_node;
 #else
-	return -1;
+	return NUMA_NO_NODE;
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index d28b3a0..004024c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5116,7 +5116,7 @@ static void netdev_init_one_queue(struct net_device *dev,
 	spin_lock_init(&queue->_xmit_lock);
 	netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev->type);
 	queue->xmit_lock_owner = -1;
-	netdev_queue_numa_node_write(queue, -1);
+	netdev_queue_numa_node_write(queue, NUMA_NO_NODE);
 	queue->dev = dev;
 }
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 85e8b53..e23c01b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1009,7 +1009,8 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	if (dev_maps)
 		call_rcu(&dev_maps->rcu, xps_dev_maps_release);
 
-	netdev_queue_numa_node_write(queue, (numa_node >= 0) ? numa_node : -1);
+	netdev_queue_numa_node_write(queue, (numa_node >= 0) ? numa_node :
+					    NUMA_NO_NODE);
 
 	mutex_unlock(&xps_map_mutex);
 
