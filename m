From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 05/12] vlan: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:04 +0200
Message-ID: <1427987231-3669-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56602 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbDBPHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:24 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Patrick McHardy <kaber@trash.net>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/8021q/vlan_dev.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8b5ab9033b41..01d7ba840df8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -538,7 +538,6 @@ static int vlan_dev_init(struct net_device *dev)
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~(IFF_UP | IFF_PROMISC | IFF_ALLMULTI |
 					  IFF_MASTER | IFF_SLAVE);
-	dev->iflink = real_dev->ifindex;
 	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
@@ -733,6 +732,13 @@ static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
+static int vlan_dev_get_iflink(const struct net_device *dev)
+{
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+
+	return real_dev->ifindex;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
@@ -769,6 +775,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 #endif
 	.ndo_fix_features	= vlan_dev_fix_features,
 	.ndo_get_lock_subclass  = vlan_dev_get_lock_subclass,
+	.ndo_get_iflink		= vlan_dev_get_iflink,
 };
 
 static void vlan_dev_free(struct net_device *dev)
-- 
2.2.2
