From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: constify netif_is_* helpers net_device param
Date: Fri,  4 Dec 2015 15:01:31 +0100
Message-ID: <1449237691-17962-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36197 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbLDOBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 09:01:35 -0500
Received: by wmww144 with SMTP id w144so63072987wmw.1
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 06:01:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As suggested by Eric, these helpers should have const dev param.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/if_vlan.h   |  2 +-
 include/linux/netdevice.h | 22 +++++++++++-----------
 net/core/dev.c            |  2 +-
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 67ce5bd..05f5879 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -73,7 +73,7 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
-static inline bool is_vlan_dev(struct net_device *dev)
+static inline bool is_vlan_dev(const struct net_device *dev)
 {
         return dev->priv_flags & IFF_802_1Q_VLAN;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3efe017..1bb21ff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3661,7 +3661,7 @@ extern u8 netdev_rss_key[NETDEV_RSS_KEY_LEN];
 void netdev_rss_key_fill(void *buffer, size_t len);
 
 int dev_get_nest_level(struct net_device *dev,
-		       bool (*type_check)(struct net_device *dev));
+		       bool (*type_check)(const struct net_device *dev));
 int skb_checksum_help(struct sk_buff *skb);
 struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 				  netdev_features_t features, bool tx_path);
@@ -3858,32 +3858,32 @@ static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 protocol,
 	skb->mac_len = mac_len;
 }
 
-static inline bool netif_is_macvlan(struct net_device *dev)
+static inline bool netif_is_macvlan(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACVLAN;
 }
 
-static inline bool netif_is_macvlan_port(struct net_device *dev)
+static inline bool netif_is_macvlan_port(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_MACVLAN_PORT;
 }
 
-static inline bool netif_is_ipvlan(struct net_device *dev)
+static inline bool netif_is_ipvlan(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_IPVLAN_SLAVE;
 }
 
-static inline bool netif_is_ipvlan_port(struct net_device *dev)
+static inline bool netif_is_ipvlan_port(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_IPVLAN_MASTER;
 }
 
-static inline bool netif_is_bond_master(struct net_device *dev)
+static inline bool netif_is_bond_master(const struct net_device *dev)
 {
 	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_BONDING;
 }
 
-static inline bool netif_is_bond_slave(struct net_device *dev)
+static inline bool netif_is_bond_slave(const struct net_device *dev)
 {
 	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_BONDING;
 }
@@ -3918,22 +3918,22 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
-static inline bool netif_is_team_master(struct net_device *dev)
+static inline bool netif_is_team_master(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_TEAM;
 }
 
-static inline bool netif_is_team_port(struct net_device *dev)
+static inline bool netif_is_team_port(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_TEAM_PORT;
 }
 
-static inline bool netif_is_lag_master(struct net_device *dev)
+static inline bool netif_is_lag_master(const struct net_device *dev)
 {
 	return netif_is_bond_master(dev) || netif_is_team_master(dev);
 }
 
-static inline bool netif_is_lag_port(struct net_device *dev)
+static inline bool netif_is_lag_port(const struct net_device *dev)
 {
 	return netif_is_bond_slave(dev) || netif_is_team_port(dev);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index d1706e8..e5c3954 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5734,7 +5734,7 @@ EXPORT_SYMBOL(netdev_lower_dev_get_private);
 
 
 int dev_get_nest_level(struct net_device *dev,
-		       bool (*type_check)(struct net_device *dev))
+		       bool (*type_check)(const struct net_device *dev))
 {
 	struct net_device *lower = NULL;
 	struct list_head *iter;
-- 
1.9.3
