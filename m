From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] net: add netif_is_ovs_master helper with IFF_OPENVSWITCH private flag
Date: Wed, 26 Aug 2015 18:36:35 +0200
Message-ID: <1440606998-11072-4-git-send-email-jiri@resnulli.us>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33103 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752864AbbHZQgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 12:36:44 -0400
Received: by wijn1 with SMTP id n1so30110259wij.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 09:36:43 -0700 (PDT)
In-Reply-To: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add this helper so code can easily figure out if netdev is openswitch.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h            | 8 ++++++++
 net/openvswitch/vport-internal_dev.c | 2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index be625f4..0a884e6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1264,6 +1264,7 @@ struct net_device_ops {
  * @IFF_MACVLAN: Macvlan device
  * @IFF_VRF_MASTER: device is a VRF master
  * @IFF_NO_QUEUE: device can run without qdisc attached
+ * @IFF_VRF_OPENVSWITCH: device is a Open vSwitch master
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1293,6 +1294,7 @@ enum netdev_priv_flags {
 	IFF_IPVLAN_SLAVE		= 1<<24,
 	IFF_VRF_MASTER			= 1<<25,
 	IFF_NO_QUEUE			= 1<<26,
+	IFF_OPENVSWITCH			= 1<<27,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1322,6 +1324,7 @@ enum netdev_priv_flags {
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
 #define IFF_VRF_MASTER			IFF_VRF_MASTER
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
+#define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -3853,6 +3856,11 @@ static inline bool netif_is_bridge_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_EBRIDGE;
 }
 
+static inline bool netif_is_ovs_master(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_OPENVSWITCH;
+}
+
 static inline bool netif_index_is_vrf(struct net *net, int ifindex)
 {
 	bool rc = false;
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index c058bbf..80b3e12 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -135,7 +135,7 @@ static void do_setup(struct net_device *netdev)
 	netdev->netdev_ops = &internal_dev_netdev_ops;
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
-	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_OPENVSWITCH;
 	netdev->destructor = internal_dev_destructor;
 	netdev->ethtool_ops = &internal_dev_ethtool_ops;
 	netdev->rtnl_link_ops = &internal_dev_link_ops;
-- 
1.9.3
