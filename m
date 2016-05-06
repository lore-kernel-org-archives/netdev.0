From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: phy: add ethtool_phy_{get|set}_link_ksettings
Date: Sat,  7 May 2016 01:18:48 +0200
Message-ID: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, fugang.duan@nxp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36069 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758281AbcEFXTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 19:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callback {get|set}_link_ksettings are often defined
in a very close way. There are mainly two differences in
those callback:
- the name of the netdev private structure
- the name of the struct phydev in the private structure

We add two defines ethtool_phy_{get|set}_link_ksettings
to avoid writing severals times almost the same function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 include/linux/phy.h |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index be3f83b..e4a79fa 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -830,6 +830,52 @@ int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
 
+/**
+ * ethtool_phy_get_link_ksettings() - Helper macro for get_link_ksettings
+ * @name: name of the driver
+ * @private: name of the private structure in the net device
+ * @phy: name of the phydev variable in the private structure
+ *
+ * Helper macro for the callback get_link_ksettings which
+ * simply call phy_ethtool_ksettings_get.
+ */
+#define ethtool_phy_get_link_ksettings(name, private, phy)		\
+	static int							\
+	name##_get_link_ksettings(struct net_device *ndev,		\
+				  struct ethtool_link_ksettings *cmd)	\
+	{								\
+		struct private *priv = netdev_priv(ndev);		\
+		struct phy_device *phydev = priv->phy;			\
+									\
+		if (!phydev)						\
+			return -ENODEV;					\
+									\
+		return phy_ethtool_ksettings_get(phydev, cmd);		\
+	}
+
+/**
+ * ethtool_phy_set_link_ksettings() - Helper macro for set_link_ksettings
+ * @name: name of the driver
+ * @private: name of the private structure in the net device
+ * @phy: name of the phydev variable in the private structure
+ *
+ * Helper macro for the callback set_link_ksettings which
+ * simply call phy_ethtool_ksettings_set.
+ */
+#define ethtool_phy_set_link_ksettings(name, private, phy)		\
+	static int							\
+	name##_set_link_ksettings(struct net_device *ndev,		\
+				  const struct ethtool_link_ksettings *cmd) \
+	{								\
+		struct private *priv = netdev_priv(ndev);		\
+		struct phy_device *phydev = priv->phy;			\
+									\
+		if (!phydev)						\
+			return -ENODEV;					\
+									\
+		return phy_ethtool_ksettings_set(phydev, cmd);		\
+	}
+
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
-- 
1.7.4.4
