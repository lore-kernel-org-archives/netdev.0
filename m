From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] switchdev: s/swdev_/switchdev_/
Date: Mon, 13 Apr 2015 16:14:35 +0200
Message-ID: <1428934475-15349-3-git-send-email-jiri@resnulli.us>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	f.fainelli@gmail.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34252 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279AbbDMOOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:14:43 -0400
Received: by wgso17 with SMTP id o17so82531818wgs.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:14:42 -0700 (PDT)
In-Reply-To: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turned out that "switchdev" sticks. So just unify all releated terms to
use this prefix.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 37 +++++++++++++++++----------------
 include/linux/netdevice.h            |  2 +-
 include/net/switchdev.h              | 30 +++++++++++++--------------
 net/dsa/slave.c                      |  8 ++++----
 net/switchdev/switchdev.c            | 40 ++++++++++++++++++------------------
 5 files changed, 59 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 6d31aeb..23372dd 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4220,8 +4220,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
  * swdev interface
  ********************/
 
-static int rocker_port_swdev_parent_id_get(struct net_device *dev,
-					   struct netdev_phys_item_id *psid)
+static int rocker_port_switchdev_parent_id_get(struct net_device *dev,
+					       struct netdev_phys_item_id *psid)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker *rocker = rocker_port->rocker;
@@ -4231,18 +4231,19 @@ static int rocker_port_swdev_parent_id_get(struct net_device *dev,
 	return 0;
 }
 
-static int rocker_port_swdev_port_stp_update(struct net_device *dev, u8 state)
+static int rocker_port_switchdev_port_stp_update(struct net_device *dev,
+						 u8 state)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 
 	return rocker_port_stp_update(rocker_port, state);
 }
 
-static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type,
-					  u32 nlflags, u32 tb_id)
+static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
+					      __be32 dst, int dst_len,
+					      struct fib_info *fi,
+					      u8 tos, u8 type,
+					      u32 nlflags, u32 tb_id)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = 0;
@@ -4251,10 +4252,10 @@ static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
 				    fi, tb_id, flags);
 }
 
-static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type, u32 tb_id)
+static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
+					      __be32 dst, int dst_len,
+					      struct fib_info *fi,
+					      u8 tos, u8 type, u32 tb_id)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int flags = ROCKER_OP_FLAG_REMOVE;
@@ -4263,11 +4264,11 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
 				    fi, tb_id, flags);
 }
 
-static const struct swdev_ops rocker_port_swdev_ops = {
-	.swdev_parent_id_get		= rocker_port_swdev_parent_id_get,
-	.swdev_port_stp_update		= rocker_port_swdev_port_stp_update,
-	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
-	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
+static const struct switchdev_ops rocker_port_switchdev_ops = {
+	.switchdev_parent_id_get	= rocker_port_switchdev_parent_id_get,
+	.switchdev_port_stp_update	= rocker_port_switchdev_port_stp_update,
+	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
+	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
 };
 
 /********************
@@ -4622,7 +4623,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
 	dev->ethtool_ops = &rocker_port_ethtool_ops;
-	dev->swdev_ops = &rocker_port_swdev_ops;
+	dev->switchdev_ops = &rocker_port_switchdev_ops;
 	netif_napi_add(dev, &rocker_port->napi_tx, rocker_port_poll_tx,
 		       NAPI_POLL_WEIGHT);
 	netif_napi_add(dev, &rocker_port->napi_rx, rocker_port_poll_rx,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 13acb3d..140fdc7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1564,7 +1564,7 @@ struct net_device {
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
 #ifdef CONFIG_NET_SWITCHDEV
-	const struct swdev_ops *swdev_ops;
+	const struct switchdev_ops *switchdev_ops;
 #endif
 
 	const struct header_ops *header_ops;
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 9b43228..1f6ee90 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -19,28 +19,28 @@ struct fib_info;
 /**
  * struct switchdev_ops - switchdev operations
  *
- * @swdev_parent_id_get: Called to get an ID of the switch chip this port
+ * @switchdev_parent_id_get: Called to get an ID of the switch chip this port
  *   is part of.  If driver implements this, it indicates that it
  *   represents a port of a switch chip.
  *
- * @swdev_port_stp_update: Called to notify switch device port of bridge
+ * @switchdev_port_stp_update: Called to notify switch device port of bridge
  *   port STP state change.
  *
- * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
+ * @switchdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
  *
- * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
+ * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
-struct swdev_ops {
-	int	(*swdev_parent_id_get)(struct net_device *dev,
-				       struct netdev_phys_item_id *psid);
-	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
-	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 nlflags,
-				      u32 tb_id);
-	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 tb_id);
+struct switchdev_ops {
+	int	(*switchdev_parent_id_get)(struct net_device *dev,
+					   struct netdev_phys_item_id *psid);
+	int	(*switchdev_port_stp_update)(struct net_device *dev, u8 state);
+	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
+					  int dst_len, struct fib_info *fi,
+					  u8 tos, u8 type, u32 nlflags,
+					  u32 tb_id);
+	int	(*switchdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
+					  int dst_len, struct fib_info *fi,
+					  u8 tos, u8 type, u32 tb_id);
 };
 
 enum switchdev_notifier_type {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 827cda56..aee5877 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -675,9 +675,9 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_get_iflink		= dsa_slave_get_iflink,
 };
 
-static const struct swdev_ops dsa_slave_swdev_ops = {
-	.swdev_parent_id_get = dsa_slave_parent_id_get,
-	.swdev_port_stp_update = dsa_slave_stp_update,
+static const struct switchdev_ops dsa_slave_switchdev_ops = {
+	.switchdev_parent_id_get	= dsa_slave_parent_id_get,
+	.switchdev_port_stp_update	= dsa_slave_stp_update,
 };
 
 static void dsa_slave_adjust_link(struct net_device *dev)
@@ -859,7 +859,7 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	eth_hw_addr_inherit(slave_dev, master);
 	slave_dev->tx_queue_len = 0;
 	slave_dev->netdev_ops = &dsa_slave_netdev_ops;
-	slave_dev->swdev_ops = &dsa_slave_swdev_ops;
+	slave_dev->switchdev_ops = &dsa_slave_switchdev_ops;
 
 	SET_NETDEV_DEV(slave_dev, parent);
 	slave_dev->dev.of_node = ds->pd->port_dn[port];
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 52613ed..b7f44a2 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -28,11 +28,11 @@
 int switchdev_parent_id_get(struct net_device *dev,
 			    struct netdev_phys_item_id *psid)
 {
-	const struct swdev_ops *ops = dev->swdev_ops;
+	const struct switchdev_ops *ops = dev->switchdev_ops;
 
-	if (!ops || !ops->swdev_parent_id_get)
+	if (!ops || !ops->switchdev_parent_id_get)
 		return -EOPNOTSUPP;
-	return ops->swdev_parent_id_get(dev, psid);
+	return ops->switchdev_parent_id_get(dev, psid);
 }
 EXPORT_SYMBOL_GPL(switchdev_parent_id_get);
 
@@ -46,13 +46,13 @@ EXPORT_SYMBOL_GPL(switchdev_parent_id_get);
  */
 int switchdev_port_stp_update(struct net_device *dev, u8 state)
 {
-	const struct swdev_ops *ops = dev->swdev_ops;
+	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
 	struct list_head *iter;
 	int err = -EOPNOTSUPP;
 
-	if (ops && ops->swdev_port_stp_update)
-		return ops->swdev_port_stp_update(dev, state);
+	if (ops && ops->switchdev_port_stp_update)
+		return ops->switchdev_port_stp_update(dev, state);
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
 		err = switchdev_port_stp_update(lower_dev, state);
@@ -239,17 +239,17 @@ EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_dellink);
 
 static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 {
-	const struct swdev_ops *ops = dev->swdev_ops;
+	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
 	struct net_device *port_dev;
 	struct list_head *iter;
 
 	/* Recusively search down until we find a sw port dev.
-	 * (A sw port dev supports swdev_parent_id_get).
+	 * (A sw port dev supports switchdev_parent_id_get).
 	 */
 
 	if (dev->features & NETIF_F_HW_SWITCH_OFFLOAD &&
-	    ops && ops->swdev_parent_id_get)
+	    ops && ops->switchdev_parent_id_get)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
@@ -313,7 +313,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	struct net_device *dev;
-	const struct swdev_ops *ops;
+	const struct switchdev_ops *ops;
 	int err = 0;
 
 	/* Don't offload route if using custom ip rules or if
@@ -331,12 +331,12 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
+	ops = dev->switchdev_ops;
 
-	if (ops->swdev_fib_ipv4_add) {
-		err = ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
-					      fi, tos, type, nlflags,
-					      tb_id);
+	if (ops->switchdev_fib_ipv4_add) {
+		err = ops->switchdev_fib_ipv4_add(dev, htonl(dst), dst_len,
+						  fi, tos, type, nlflags,
+						  tb_id);
 		if (!err)
 			fi->fib_flags |= RTNH_F_EXTERNAL;
 	}
@@ -361,7 +361,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id)
 {
 	struct net_device *dev;
-	const struct swdev_ops *ops;
+	const struct switchdev_ops *ops;
 	int err = 0;
 
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
@@ -370,11 +370,11 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
+	ops = dev->switchdev_ops;
 
-	if (ops->swdev_fib_ipv4_del) {
-		err = ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
-					      fi, tos, type, tb_id);
+	if (ops->switchdev_fib_ipv4_del) {
+		err = ops->switchdev_fib_ipv4_del(dev, htonl(dst), dst_len,
+						  fi, tos, type, tb_id);
 		if (!err)
 			fi->fib_flags &= ~RTNH_F_EXTERNAL;
 	}
-- 
1.9.3
