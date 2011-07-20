From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 46/47] vlan: kill ndo_vlan_rx_register
Date: Wed, 20 Jul 2011 16:54:48 +0200
Message-ID: <1311173689-17419-47-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7520 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752393Ab1GTO4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:20 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

has no users so remove it

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |    8 --------
 net/8021q/vlan.c          |    4 ----
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 52c4e38..98bcacc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -768,12 +768,6 @@ struct netdev_tc_txq {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
- * void (*ndo_vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
- *	If device support VLAN receive acceleration
- *	(ie. dev->features & NETIF_F_HW_VLAN_RX), then this function is called
- *	when vlan groups for the device changes.  Note: grp is NULL
- *	if no vlan's groups are being used.
- *
  * void (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
  *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
  *	this function is called when a VLAN id is registered.
@@ -892,8 +886,6 @@ struct net_device_ops {
 						     struct rtnl_link_stats64 *storage);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
-	void			(*ndo_vlan_rx_register)(struct net_device *dev,
-						        struct vlan_group *grp);
 	void			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
 						       unsigned short vid);
 	void			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d24c464..8970ba1 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -134,8 +134,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		vlan_gvrp_uninit_applicant(real_dev);
 
 		rcu_assign_pointer(real_dev->vlgrp, NULL);
-		if (ops->ndo_vlan_rx_register)
-			ops->ndo_vlan_rx_register(real_dev, NULL);
 
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
@@ -207,8 +205,6 @@ int register_vlan_dev(struct net_device *dev)
 	grp->nr_vlans++;
 
 	if (ngrp) {
-		if (ops->ndo_vlan_rx_register && (real_dev->features & NETIF_F_HW_VLAN_RX))
-			ops->ndo_vlan_rx_register(real_dev, ngrp);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-- 
1.7.6

