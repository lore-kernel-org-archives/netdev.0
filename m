From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 8/8] net: Use IS_ENABLED() in netdevice.h as
 appropriate
Date: Sat, 26 Nov 2011 00:40:26 +0000
Message-ID: <1322268026.2839.391.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34321 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab1KZAkc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:40:32 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/netdevice.h |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 87f7353..ac9a4b9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -144,22 +144,20 @@ static inline bool dev_xmit_complete(int rc)
  *	used.
  */
 
-#if defined(CONFIG_WLAN) || defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+#if defined(CONFIG_WLAN) || IS_ENABLED(CONFIG_AX25)
 # if defined(CONFIG_MAC80211_MESH)
 #  define LL_MAX_HEADER 128
 # else
 #  define LL_MAX_HEADER 96
 # endif
-#elif defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
+#elif IS_ENABLED(CONFIG_TR)
 # define LL_MAX_HEADER 48
 #else
 # define LL_MAX_HEADER 32
 #endif
 
-#if !defined(CONFIG_NET_IPIP) && !defined(CONFIG_NET_IPIP_MODULE) && \
-    !defined(CONFIG_NET_IPGRE) &&  !defined(CONFIG_NET_IPGRE_MODULE) && \
-    !defined(CONFIG_IPV6_SIT) && !defined(CONFIG_IPV6_SIT_MODULE) && \
-    !defined(CONFIG_IPV6_TUNNEL) && !defined(CONFIG_IPV6_TUNNEL_MODULE)
+#if !IS_ENABLED(CONFIG_NET_IPIP) && !IS_ENABLED(CONFIG_NET_IPGRE) && \
+    !IS_ENABLED(CONFIG_IPV6_SIT) && !IS_ENABLED(CONFIG_IPV6_TUNNEL)
 #define MAX_HEADER LL_MAX_HEADER
 #else
 #define MAX_HEADER (LL_MAX_HEADER + 48)
@@ -922,7 +920,7 @@ struct net_device_ops {
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
 	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
 	int			(*ndo_fcoe_ddp_setup)(struct net_device *dev,
@@ -937,7 +935,7 @@ struct net_device_ops {
 						       unsigned int sgc);
 #endif
 
-#if defined(CONFIG_LIBFCOE) || defined(CONFIG_LIBFCOE_MODULE)
+#if IS_ENABLED(CONFIG_LIBFCOE)
 #define NETDEV_FCOE_WWNN 0
 #define NETDEV_FCOE_WWPN 1
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
@@ -1076,7 +1074,7 @@ struct net_device {
 
 	/* Protocol specific pointers */
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 	struct vlan_group __rcu	*vlgrp;		/* VLAN group */
 #endif
 #if IS_ENABLED(CONFIG_NET_DSA)
@@ -1242,7 +1240,7 @@ struct net_device {
 	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
 	u8 prio_tc_map[TC_BITMASK + 1];
 
-#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#if IS_ENABLED(CONFIG_FCOE)
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
-- 
1.7.7.3
