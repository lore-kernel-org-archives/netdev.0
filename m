From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 2/3] ethtool: Add common functions for get and set settings
Date: Mon, 13 Jun 2016 14:07:55 +0800
Message-ID: <1465798076-176393-3-git-send-email-lidongpo@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Dongpo Li <lidongpo@hisilicon.com>
To: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, most drivers only support get and set PHY settings
by PHY ethtool API. For those drivers, it's better to
supply common functions for get_settings and set_settings.
This patch adds common functions implementation.

Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 include/linux/ethtool.h |  2 ++
 net/core/ethtool.c      | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9ded8c6..e114db9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -82,6 +82,8 @@ struct net_device;
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
 int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti);
+int ethtool_op_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+int ethtool_op_set_settings(struct net_device *dev, struct ethtool_cmd *cmd);
 
 /**
  * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f403481..270b6d1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -50,6 +50,27 @@ int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *info)
 }
 EXPORT_SYMBOL(ethtool_op_get_ts_info);
 
+int ethtool_op_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(dev->phydev, cmd);
+}
+EXPORT_SYMBOL(ethtool_op_get_settings);
+
+int ethtool_op_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(dev->phydev, cmd);
+}
+EXPORT_SYMBOL(ethtool_op_set_settings);
+
 /* Handlers for each ethtool command */
 
 #define ETHTOOL_DEV_FEATURE_WORDS	((NETDEV_FEATURE_COUNT + 31) / 32)
-- 
2.8.2
