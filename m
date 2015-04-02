From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 07/12] ipvlan: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:06 +0200
Message-ID: <1427987231-3669-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56626 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbbDBPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:26 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 2950c3780230..1701ede2df89 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -114,7 +114,6 @@ static int ipvlan_init(struct net_device *dev)
 	dev->features = phy_dev->features & IPVLAN_FEATURES;
 	dev->features |= NETIF_F_LLTX;
 	dev->gso_max_size = phy_dev->gso_max_size;
-	dev->iflink = phy_dev->ifindex;
 	dev->hard_header_len = phy_dev->hard_header_len;
 
 	ipvlan_set_lockdep_class(dev);
@@ -305,6 +304,13 @@ static int ipvlan_vlan_rx_kill_vid(struct net_device *dev, __be16 proto,
 	return 0;
 }
 
+static int ipvlan_get_iflink(const struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan = netdev_priv(dev);
+
+	return ipvlan->phy_dev->ifindex;
+}
+
 static const struct net_device_ops ipvlan_netdev_ops = {
 	.ndo_init		= ipvlan_init,
 	.ndo_uninit		= ipvlan_uninit,
@@ -317,6 +323,7 @@ static const struct net_device_ops ipvlan_netdev_ops = {
 	.ndo_get_stats64	= ipvlan_get_stats64,
 	.ndo_vlan_rx_add_vid	= ipvlan_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= ipvlan_vlan_rx_kill_vid,
+	.ndo_get_iflink		= ipvlan_get_iflink,
 };
 
 static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
-- 
2.2.2
