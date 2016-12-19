From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net 1/2] net: netcp: ethss: fix errors in ethtool ops
Date: Mon, 19 Dec 2016 17:55:56 -0500
Message-ID: <1482188157-24490-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: WingMan Kwok <w-kwok2@ti.com>

In ethtool ops, it needs to retrieve the corresponding
ethss module (gbe or xgbe) from the net_device structure.
Prior to this patch, the retrieving procedure only
checks for the gbe module.  This patch fixes the issue
by checking the xgbe module if the net_device structure
does not correspond to the gbe module.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index c7e547e..a31931c 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -1746,6 +1746,17 @@ static void keystone_set_msglevel(struct net_device *ndev, u32 value)
 	netcp->msg_enable = value;
 }
 
+static struct gbe_intf *keystone_get_intf_data(struct netcp_intf *netcp)
+{
+	struct gbe_intf *gbe_intf;
+
+	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	if (!gbe_intf)
+		gbe_intf = netcp_module_get_intf_data(&xgbe_module, netcp);
+
+	return gbe_intf;
+}
+
 static void keystone_get_stat_strings(struct net_device *ndev,
 				      uint32_t stringset, uint8_t *data)
 {
@@ -1754,7 +1765,7 @@ static void keystone_get_stat_strings(struct net_device *ndev,
 	struct gbe_priv *gbe_dev;
 	int i;
 
-	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	gbe_intf = keystone_get_intf_data(netcp);
 	if (!gbe_intf)
 		return;
 	gbe_dev = gbe_intf->gbe_dev;
@@ -1778,7 +1789,7 @@ static int keystone_get_sset_count(struct net_device *ndev, int stringset)
 	struct gbe_intf *gbe_intf;
 	struct gbe_priv *gbe_dev;
 
-	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	gbe_intf = keystone_get_intf_data(netcp);
 	if (!gbe_intf)
 		return -EINVAL;
 	gbe_dev = gbe_intf->gbe_dev;
@@ -1896,7 +1907,7 @@ static void keystone_get_ethtool_stats(struct net_device *ndev,
 	struct gbe_intf *gbe_intf;
 	struct gbe_priv *gbe_dev;
 
-	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	gbe_intf = keystone_get_intf_data(netcp);
 	if (!gbe_intf)
 		return;
 
@@ -1920,7 +1931,7 @@ static int keystone_get_link_ksettings(struct net_device *ndev,
 	if (!phy)
 		return -EINVAL;
 
-	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	gbe_intf = keystone_get_intf_data(netcp);
 	if (!gbe_intf)
 		return -EINVAL;
 
@@ -1953,7 +1964,7 @@ static int keystone_set_link_ksettings(struct net_device *ndev,
 	if (!phy)
 		return -EINVAL;
 
-	gbe_intf = netcp_module_get_intf_data(&gbe_module, netcp);
+	gbe_intf = keystone_get_intf_data(netcp);
 	if (!gbe_intf)
 		return -EINVAL;
 
-- 
1.9.1
