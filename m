From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 19/20] batman-adv: Prefix soft-interface local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:43 +0200
Message-ID: <1340607284-29950-20-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30519 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2FYGyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:53 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c |   80 ++++++++++++++++++++-------------------
 1 file changed, 41 insertions(+), 39 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index af676b8..2de1d74 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -37,23 +37,23 @@
 #include "bridge_loop_avoidance.h"
 
 
-static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
-static void bat_get_drvinfo(struct net_device *dev,
-			    struct ethtool_drvinfo *info);
-static u32 bat_get_msglevel(struct net_device *dev);
-static void bat_set_msglevel(struct net_device *dev, u32 value);
-static u32 bat_get_link(struct net_device *dev);
+static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static void batadv_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info);
+static u32 batadv_get_msglevel(struct net_device *dev);
+static void batadv_set_msglevel(struct net_device *dev, u32 value);
+static u32 batadv_get_link(struct net_device *dev);
 static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data);
 static void batadv_get_ethtool_stats(struct net_device *dev,
 				     struct ethtool_stats *stats, u64 *data);
 static int batadv_get_sset_count(struct net_device *dev, int stringset);
 
-static const struct ethtool_ops bat_ethtool_ops = {
-	.get_settings = bat_get_settings,
-	.get_drvinfo = bat_get_drvinfo,
-	.get_msglevel = bat_get_msglevel,
-	.set_msglevel = bat_set_msglevel,
-	.get_link = bat_get_link,
+static const struct ethtool_ops batadv_ethtool_ops = {
+	.get_settings = batadv_get_settings,
+	.get_drvinfo = batadv_get_drvinfo,
+	.get_msglevel = batadv_get_msglevel,
+	.set_msglevel = batadv_set_msglevel,
+	.get_link = batadv_get_link,
 	.get_strings = batadv_get_strings,
 	.get_ethtool_stats = batadv_get_ethtool_stats,
 	.get_sset_count = batadv_get_sset_count,
@@ -78,25 +78,25 @@ int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 	return 0;
 }
 
-static int interface_open(struct net_device *dev)
+static int batadv_interface_open(struct net_device *dev)
 {
 	netif_start_queue(dev);
 	return 0;
 }
 
-static int interface_release(struct net_device *dev)
+static int batadv_interface_release(struct net_device *dev)
 {
 	netif_stop_queue(dev);
 	return 0;
 }
 
-static struct net_device_stats *interface_stats(struct net_device *dev)
+static struct net_device_stats *batadv_interface_stats(struct net_device *dev)
 {
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	return &bat_priv->stats;
 }
 
-static int interface_set_mac_addr(struct net_device *dev, void *p)
+static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct bat_priv *bat_priv = netdev_priv(dev);
 	struct sockaddr *addr = p;
@@ -116,7 +116,7 @@ static int interface_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int interface_change_mtu(struct net_device *dev, int new_mtu)
+static int batadv_interface_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* check ranges */
 	if ((new_mtu < 68) || (new_mtu > batadv_hardif_min_mtu(dev)))
@@ -127,7 +127,8 @@ static int interface_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
+static int batadv_interface_tx(struct sk_buff *skb,
+			       struct net_device *soft_iface)
 {
 	struct ethhdr *ethhdr = (struct ethhdr *)skb->data;
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
@@ -323,23 +324,23 @@ out:
 	return;
 }
 
-static const struct net_device_ops bat_netdev_ops = {
-	.ndo_open = interface_open,
-	.ndo_stop = interface_release,
-	.ndo_get_stats = interface_stats,
-	.ndo_set_mac_address = interface_set_mac_addr,
-	.ndo_change_mtu = interface_change_mtu,
-	.ndo_start_xmit = interface_tx,
+static const struct net_device_ops batadv_netdev_ops = {
+	.ndo_open = batadv_interface_open,
+	.ndo_stop = batadv_interface_release,
+	.ndo_get_stats = batadv_interface_stats,
+	.ndo_set_mac_address = batadv_interface_set_mac_addr,
+	.ndo_change_mtu = batadv_interface_change_mtu,
+	.ndo_start_xmit = batadv_interface_tx,
 	.ndo_validate_addr = eth_validate_addr
 };
 
-static void interface_setup(struct net_device *dev)
+static void batadv_interface_setup(struct net_device *dev)
 {
 	struct bat_priv *priv = netdev_priv(dev);
 
 	ether_setup(dev);
 
-	dev->netdev_ops = &bat_netdev_ops;
+	dev->netdev_ops = &batadv_netdev_ops;
 	dev->destructor = free_netdev;
 	dev->tx_queue_len = 0;
 
@@ -353,7 +354,7 @@ static void interface_setup(struct net_device *dev)
 	/* generate random address */
 	eth_hw_addr_random(dev);
 
-	SET_ETHTOOL_OPS(dev, &bat_ethtool_ops);
+	SET_ETHTOOL_OPS(dev, &batadv_ethtool_ops);
 
 	memset(priv, 0, sizeof(*priv));
 }
@@ -364,7 +365,8 @@ struct net_device *batadv_softif_create(const char *name)
 	struct bat_priv *bat_priv;
 	int ret;
 
-	soft_iface = alloc_netdev(sizeof(*bat_priv), name, interface_setup);
+	soft_iface = alloc_netdev(sizeof(*bat_priv), name,
+				  batadv_interface_setup);
 
 	if (!soft_iface)
 		goto out;
@@ -456,14 +458,14 @@ void batadv_softif_destroy(struct net_device *soft_iface)
 
 int batadv_softif_is_valid(const struct net_device *net_dev)
 {
-	if (net_dev->netdev_ops->ndo_start_xmit == interface_tx)
+	if (net_dev->netdev_ops->ndo_start_xmit == batadv_interface_tx)
 		return 1;
 
 	return 0;
 }
 
 /* ethtool */
-static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	cmd->supported = 0;
 	cmd->advertising = 0;
@@ -479,8 +481,8 @@ static int bat_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return 0;
 }
 
-static void bat_get_drvinfo(struct net_device *dev,
-			    struct ethtool_drvinfo *info)
+static void batadv_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
 {
 	strcpy(info->driver, "B.A.T.M.A.N. advanced");
 	strcpy(info->version, SOURCE_VERSION);
@@ -488,16 +490,16 @@ static void bat_get_drvinfo(struct net_device *dev,
 	strcpy(info->bus_info, "batman");
 }
 
-static u32 bat_get_msglevel(struct net_device *dev)
+static u32 batadv_get_msglevel(struct net_device *dev)
 {
 	return -EOPNOTSUPP;
 }
 
-static void bat_set_msglevel(struct net_device *dev, u32 value)
+static void batadv_set_msglevel(struct net_device *dev, u32 value)
 {
 }
 
-static u32 bat_get_link(struct net_device *dev)
+static u32 batadv_get_link(struct net_device *dev)
 {
 	return 1;
 }
@@ -508,7 +510,7 @@ static u32 bat_get_link(struct net_device *dev)
  */
 static const struct {
 	const char name[ETH_GSTRING_LEN];
-} bat_counters_strings[] = {
+} batadv_counters_strings[] = {
 	{ "forward" },
 	{ "forward_bytes" },
 	{ "mgmt_tx" },
@@ -527,8 +529,8 @@ static void batadv_get_strings(struct net_device *dev, uint32_t stringset,
 			       uint8_t *data)
 {
 	if (stringset == ETH_SS_STATS)
-		memcpy(data, bat_counters_strings,
-		       sizeof(bat_counters_strings));
+		memcpy(data, batadv_counters_strings,
+		       sizeof(batadv_counters_strings));
 }
 
 static void batadv_get_ethtool_stats(struct net_device *dev,
-- 
1.7.9.4
