From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 18/27] net: add a possibility to get private from netdev_adjacent->list
Date: Wed, 25 Sep 2013 09:20:23 +0200
Message-ID: <1380093632-1842-19-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753252Ab3IYHU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:20:59 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will be useful to get first/last element.

CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    No changes.

 include/linux/netdevice.h |  1 +
 net/core/dev.c            | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 168974e..b4cfb63 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2850,6 +2850,7 @@ extern void *netdev_lower_get_next_private_rcu(struct net_device *dev,
 	     priv; \
 	     priv = netdev_lower_get_next_private_rcu(dev, &(iter)))
 
+extern void *netdev_adjacent_get_private(struct list_head *adj_list);
 extern struct net_device *netdev_master_upper_dev_get(struct net_device *dev);
 extern struct net_device *netdev_master_upper_dev_get_rcu(struct net_device *dev);
 extern int netdev_upper_dev_link(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 0aa844a..acc1181 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4466,6 +4466,16 @@ struct net_device *netdev_master_upper_dev_get(struct net_device *dev)
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
 /**
  * netdev_all_upper_get_next_dev_rcu - Get the next dev from upper list
  * @dev: device
-- 
1.8.4
