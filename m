From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v5 08/11] drivers: net: xgene: ethtool: Use phy_ethtool_gset and sset
Date: Thu,  7 Jul 2016 16:02:56 -0700
Message-ID: <1467932579-14320-9-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changed SGMII 1G get_settings to use phy_ethtool_gset.
Changed SGMII 1G set_settings to use phy_ethtool_sset.

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
---
 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
index 416d6eb..22a7b26 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
@@ -65,8 +65,15 @@ static int xgene_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 
 		return phy_ethtool_gset(phydev, cmd);
 	} else if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
-		cmd->supported = SUPPORTED_1000baseT_Full |
-				 SUPPORTED_Autoneg | SUPPORTED_MII;
+		if (pdata->mdio_driver) {
+			if (!phydev)
+				return -ENODEV;
+
+			return phy_ethtool_gset(phydev, cmd);
+		}
+
+		cmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+				 SUPPORTED_MII;
 		cmd->advertising = cmd->supported;
 		ethtool_cmd_speed_set(cmd, SPEED_1000);
 		cmd->duplex = DUPLEX_FULL;
@@ -92,12 +99,21 @@ static int xgene_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
 	struct phy_device *phydev = pdata->phy_dev;
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {
-		if (phydev == NULL)
+		if (!phydev)
 			return -ENODEV;
 
 		return phy_ethtool_sset(phydev, cmd);
 	}
 
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_SGMII) {
+		if (pdata->mdio_driver) {
+			if (!phydev)
+				return -ENODEV;
+
+			return phy_ethtool_sset(phydev, cmd);
+		}
+	}
+
 	return -EINVAL;
 }
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
