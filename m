From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 2/4] net: ethoc: implement ethtool get/set settings
Date: Wed, 29 Jan 2014 23:56:35 +0400
Message-ID: <1391025397-14965-3-git-send-email-jcmvbkbc@gmail.com>
References: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 6de6352..9518023 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -900,7 +900,31 @@ out:
 	return NETDEV_TX_OK;
 }
 
+static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phy;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(phydev, cmd);
+}
+
+static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phy;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, cmd);
+}
+
 const struct ethtool_ops ethoc_ethtool_ops = {
+	.get_settings = ethoc_get_settings,
+	.set_settings = ethoc_set_settings,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ethtool_op_get_ts_info,
 };
-- 
1.8.1.4
