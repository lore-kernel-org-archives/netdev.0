From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/26] net: add netif_is_team_master helper
Date: Tue,  1 Dec 2015 14:48:40 +0100
Message-ID: <1448977744-17930-3-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35099 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886AbbLANtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:11 -0500
Received: by wmuu63 with SMTP id u63so173623535wmu.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:10 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Similar to other helpers, caller can use this to find out if device is
team master.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team.c   | 1 +
 include/linux/netdevice.h | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 651d35e..d2f3ee8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2054,6 +2054,7 @@ static void team_setup(struct net_device *dev)
 	dev->flags |= IFF_MULTICAST;
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
 	dev->priv_flags |= IFF_NO_QUEUE;
+	dev->priv_flags |= IFF_TEAM;
 
 	/*
 	 * Indicate we support unicast address filtering. That way core won't
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7d2d1d7..cfb56e0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1271,6 +1271,7 @@ struct net_device_ops {
  * @IFF_NO_QUEUE: device can run without qdisc attached
  * @IFF_OPENVSWITCH: device is a Open vSwitch master
  * @IFF_L3MDEV_SLAVE: device is enslaved to an L3 master device
+ * @IFF_TEAM: device is a team device
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1297,6 +1298,7 @@ enum netdev_priv_flags {
 	IFF_NO_QUEUE			= 1<<21,
 	IFF_OPENVSWITCH			= 1<<22,
 	IFF_L3MDEV_SLAVE		= 1<<23,
+	IFF_TEAM			= 1<<24,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1323,6 +1325,7 @@ enum netdev_priv_flags {
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
 #define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
+#define IFF_TEAM			IFF_TEAM
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -3887,6 +3890,11 @@ static inline bool netif_is_ovs_master(const struct net_device *dev)
 	return dev->priv_flags & IFF_OPENVSWITCH;
 }
 
+static inline bool netif_is_team_master(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_TEAM;
+}
+
 /* This device needs to keep skb dst for qdisc enqueue or ndo_start_xmit() */
 static inline void netif_keep_dst(struct net_device *dev)
 {
-- 
1.9.3
