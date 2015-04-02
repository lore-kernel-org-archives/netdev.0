From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 09/12] dsa: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:08 +0200
Message-ID: <1427987231-3669-10-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56630 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234AbbDBPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:26 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/dsa/slave.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3597724ec3d8..827cda560a55 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -55,13 +55,11 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 
 
 /* slave device handling ****************************************************/
-static int dsa_slave_init(struct net_device *dev)
+static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	dev->iflink = p->parent->dst->master_netdev->ifindex;
-
-	return 0;
+	return p->parent->dst->master_netdev->ifindex;
 }
 
 static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
@@ -664,7 +662,6 @@ static const struct ethtool_ops dsa_slave_ethtool_ops = {
 };
 
 static const struct net_device_ops dsa_slave_netdev_ops = {
-	.ndo_init		= dsa_slave_init,
 	.ndo_open	 	= dsa_slave_open,
 	.ndo_stop		= dsa_slave_close,
 	.ndo_start_xmit		= dsa_slave_xmit,
@@ -675,6 +672,7 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_fdb_del		= dsa_slave_fdb_del,
 	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
+	.ndo_get_iflink		= dsa_slave_get_iflink,
 };
 
 static const struct swdev_ops dsa_slave_swdev_ops = {
-- 
2.2.2
