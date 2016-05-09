From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v3 1/3] net: phy: add phy_ethtool_{get|set}_link_ksettings
Date: Tue, 10 May 2016 00:19:41 +0200
Message-ID: <1462832383-25541-2-git-send-email-tremyfr@gmail.com>
References: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, f.fainelli@gmail.com, davem@davemloft.net,
	decot@googlers.com, ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethtool callbacks {get|set}_link_ksettings are often the same, so
we add two generics functions phy_ethtool_{get|set}_link_ksettings
to avoid writing severals times the same function.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/phy/phy.c |   24 ++++++++++++++++++++++++
 include/linux/phy.h   |    4 ++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 6f221c8..603e8db 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1347,3 +1347,27 @@ void phy_ethtool_get_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol)
 		phydev->drv->get_wol(phydev, wol);
 }
 EXPORT_SYMBOL(phy_ethtool_get_wol);
+
+int phy_ethtool_get_link_ksettings(struct net_device *ndev,
+				   struct ethtool_link_ksettings *cmd)
+{
+	struct phy_device *phydev = ndev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_ksettings_get(phydev, cmd);
+}
+EXPORT_SYMBOL(phy_ethtool_get_link_ksettings);
+
+int phy_ethtool_set_link_ksettings(struct net_device *ndev,
+				   const struct ethtool_link_ksettings *cmd)
+{
+	struct phy_device *phydev = ndev->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_ksettings_set(phydev, cmd);
+}
+EXPORT_SYMBOL(phy_ethtool_set_link_ksettings);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index be3f83b..2d24b28 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -829,6 +829,10 @@ int phy_ethtool_get_eee(struct phy_device *phydev, struct ethtool_eee *data);
 int phy_ethtool_set_wol(struct phy_device *phydev, struct ethtool_wolinfo *wol);
 void phy_ethtool_get_wol(struct phy_device *phydev,
 			 struct ethtool_wolinfo *wol);
+int phy_ethtool_get_link_ksettings(struct net_device *ndev,
+				   struct ethtool_link_ksettings *cmd);
+int phy_ethtool_set_link_ksettings(struct net_device *ndev,
+				   const struct ethtool_link_ksettings *cmd);
 
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
-- 
1.7.4.4
