From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 45/47] macvlan: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:47 +0200
Message-ID: <1311173689-17419-46-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383Ab1GTO4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:19 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_vlan_rx_register is no longer in use in any driver so remove it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cc67cbe..ba631fc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -510,17 +510,6 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 	return stats;
 }
 
-static void macvlan_vlan_rx_register(struct net_device *dev,
-				     struct vlan_group *grp)
-{
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct net_device *lowerdev = vlan->lowerdev;
-	const struct net_device_ops *ops = lowerdev->netdev_ops;
-
-	if (ops->ndo_vlan_rx_register)
-		ops->ndo_vlan_rx_register(lowerdev, grp);
-}
-
 static void macvlan_vlan_rx_add_vid(struct net_device *dev,
 				    unsigned short vid)
 {
@@ -575,7 +564,6 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
 	.ndo_get_stats64	= macvlan_dev_get_stats64,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_vlan_rx_register	= macvlan_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= macvlan_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= macvlan_vlan_rx_kill_vid,
 };
-- 
1.7.6

