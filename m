From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 16/21] net: add a possibility to get private from netdev_adjacent->list
Date: Mon,  2 Sep 2013 23:39:20 +0200
Message-ID: <1378157965-17537-17-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab3IBVjf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:35 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be useful to get first/last element.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 20afdf98..bde2244 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2819,6 +2819,7 @@ extern void *netdev_lower_neigh_get_next_private_rcu(struct net_device *dev,
 	     priv; \
 	     priv = netdev_lower_neigh_get_next_private_rcu(dev, &(iter)))
 
+extern void *netdev_adjacent_get_private(struct list_head *adj_list);
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 1b9862b..6df11a0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4530,6 +4530,16 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
 }
 EXPORT_SYMBOL(netdev_master_upper_dev_get);
 
+void *netdev_adjacent_get_private(struct list_head *adj_list)
+{
+	struct netdev_adjacent *adj;
+
+	adj = list_entry(adj_list, struct netdev_adjacent, list);
+
+	return adj->private;
+}
+EXPORT_SYMBOL(netdev_adjacent_get_private);
+
 /* netdev_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
  * @iter: list_head ** of the current position
-- 
1.8.4
