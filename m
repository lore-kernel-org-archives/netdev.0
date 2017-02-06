From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] net: remove ndo_neigh_{construct,destroy} from stacked devices
Date: Mon,  6 Feb 2017 16:20:14 +0100
Message-ID: <1486394417-8011-6-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34577 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752553AbdBFPU0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:26 -0500
Received: by mail-wm0-f66.google.com with SMTP id c85so22521566wmi.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:25 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In commit 18bfb924f000 ("net: introduce default neigh_construct/destroy
ndo calls for L2 upper devices") we added these ndos to stacked devices
such as team and bond, so that calls will be propagated to mlxsw.

However, previous commit removed the reliance on these ndos and no new
users of these ndos have appeared since above mentioned commit. We can
therefore safely remove this dead code.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c |  2 --
 drivers/net/team/team.c         |  2 --
 include/linux/netdevice.h       |  4 ----
 net/8021q/vlan_dev.c            |  2 --
 net/bridge/br_device.c          |  2 --
 net/core/dev.c                  | 44 -----------------------------------------
 6 files changed, 56 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e6af047..6321f12 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4145,8 +4145,6 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
-	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= switchdev_port_bridge_dellink,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a371176..4a24b5d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2001,8 +2001,6 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_add_slave		= team_add_slave,
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
-	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
-	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink	= switchdev_port_bridge_setlink,
 	.ndo_bridge_getlink	= switchdev_port_bridge_getlink,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 014fbe2..58afbd1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3888,10 +3888,6 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
 				   struct net_device *lower_dev);
 void netdev_lower_state_changed(struct net_device *lower_dev,
 				void *lower_state_info);
-int netdev_default_l2upper_neigh_construct(struct net_device *dev,
-					   struct neighbour *n);
-void netdev_default_l2upper_neigh_destroy(struct net_device *dev,
-					  struct neighbour *n);
 
 /* RSS keys are 40 or 52 bytes long */
 #define NETDEV_RSS_KEY_LEN 52
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 116455a..e97ab82 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -791,8 +791,6 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
 #endif
 	.ndo_fix_features	= vlan_dev_fix_features,
-	.ndo_neigh_construct	= netdev_default_l2upper_neigh_construct,
-	.ndo_neigh_destroy	= netdev_default_l2upper_neigh_destroy,
 	.ndo_fdb_add		= switchdev_port_fdb_add,
 	.ndo_fdb_del		= switchdev_port_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 6c46d1b..5ba0b55 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -347,8 +347,6 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_add_slave		 = br_add_slave,
 	.ndo_del_slave		 = br_del_slave,
 	.ndo_fix_features        = br_fix_features,
-	.ndo_neigh_construct	 = netdev_default_l2upper_neigh_construct,
-	.ndo_neigh_destroy	 = netdev_default_l2upper_neigh_destroy,
 	.ndo_fdb_add		 = br_fdb_add,
 	.ndo_fdb_del		 = br_fdb_delete,
 	.ndo_fdb_dump		 = br_fdb_dump,
diff --git a/net/core/dev.c b/net/core/dev.c
index 404d2e6..3e1a601 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6111,50 +6111,6 @@ void netdev_lower_state_changed(struct net_device *lower_dev,
 }
 EXPORT_SYMBOL(netdev_lower_state_changed);
 
-int netdev_default_l2upper_neigh_construct(struct net_device *dev,
-					   struct neighbour *n)
-{
-	struct net_device *lower_dev, *stop_dev;
-	struct list_head *iter;
-	int err;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		if (!lower_dev->netdev_ops->ndo_neigh_construct)
-			continue;
-		err = lower_dev->netdev_ops->ndo_neigh_construct(lower_dev, n);
-		if (err) {
-			stop_dev = lower_dev;
-			goto rollback;
-		}
-	}
-	return 0;
-
-rollback:
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		if (lower_dev == stop_dev)
-			break;
-		if (!lower_dev->netdev_ops->ndo_neigh_destroy)
-			continue;
-		lower_dev->netdev_ops->ndo_neigh_destroy(lower_dev, n);
-	}
-	return err;
-}
-EXPORT_SYMBOL_GPL(netdev_default_l2upper_neigh_construct);
-
-void netdev_default_l2upper_neigh_destroy(struct net_device *dev,
-					  struct neighbour *n)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		if (!lower_dev->netdev_ops->ndo_neigh_destroy)
-			continue;
-		lower_dev->netdev_ops->ndo_neigh_destroy(lower_dev, n);
-	}
-}
-EXPORT_SYMBOL_GPL(netdev_default_l2upper_neigh_destroy);
-
 static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
-- 
2.7.4
