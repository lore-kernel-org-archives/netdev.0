From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 06/12] macvlan: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:05 +0200
Message-ID: <1427987231-3669-7-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56622 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbbDBPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:25 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/macvlan.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b5e3320ca506..b227a13f6473 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -786,7 +786,6 @@ static int macvlan_init(struct net_device *dev)
 	dev->hw_features	|= NETIF_F_LRO;
 	dev->vlan_features	= lowerdev->vlan_features & MACVLAN_FEATURES;
 	dev->gso_max_size	= lowerdev->gso_max_size;
-	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
 
 	macvlan_set_lockdep_class(dev);
@@ -995,6 +994,13 @@ static void macvlan_dev_netpoll_cleanup(struct net_device *dev)
 }
 #endif	/* CONFIG_NET_POLL_CONTROLLER */
 
+static int macvlan_dev_get_iflink(const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	return vlan->lowerdev->ifindex;
+}
+
 static const struct ethtool_ops macvlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= macvlan_ethtool_get_settings,
@@ -1025,6 +1031,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_netpoll_setup	= macvlan_dev_netpoll_setup,
 	.ndo_netpoll_cleanup	= macvlan_dev_netpoll_cleanup,
 #endif
+	.ndo_get_iflink		= macvlan_dev_get_iflink,
 };
 
 void macvlan_common_setup(struct net_device *dev)
-- 
2.2.2
