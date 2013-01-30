From: Yan Burman <yanb@mellanox.com>
Subject: [PATCH net-next] net/vxlan: Add ethtool drvinfo
Date: Wed, 30 Jan 2013 11:43:07 +0200
Message-ID: <1359538987-17659-1-git-send-email-yanb@mellanox.com>
Cc: Yan Burman <yanb@mellanox.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:56291 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754183Ab3A3JnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 04:43:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement ethtool get_drvinfo.

Signed-off-by: Yan Burman <yanb@mellanox.com>
---
 drivers/net/vxlan.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 656230e..72485b9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -29,6 +29,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/hash.h>
+#include <linux/ethtool.h>
 #include <net/arp.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
@@ -1271,6 +1272,18 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static void vxlan_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->version, VXLAN_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->driver, "vxlan", sizeof(drvinfo->driver));
+}
+
+static const struct ethtool_ops vxlan_ethtool_ops = {
+	.get_drvinfo	= vxlan_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+};
+
 static int vxlan_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
@@ -1348,6 +1361,8 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 		vxlan->port_max = ntohs(p->high);
 	}
 
+	SET_ETHTOOL_OPS(dev, &vxlan_ethtool_ops);
+
 	err = register_netdevice(dev);
 	if (!err)
 		hlist_add_head_rcu(&vxlan->hlist, vni_head(net, vxlan->vni));
-- 
1.7.11.3
