From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: [PATCH v1] net: phy: Delete unused function phy_ethtool_gset
Date: Mon,  5 Jun 2017 10:18:40 +0300
Message-ID: <20170605071840.16492-1-yuval.shaia@oracle.com>
To: f.fainelli@gmail.com, andrew@lunn.ch, corbet@lwn.net,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51749 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbdFEHTD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 03:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's unused, so remove it.

Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>
---
v0 -> v1:
	* Add commit message
	* Update Documentation/networking/phy.txt
	* Modify commit header message
---
 Documentation/networking/phy.txt |  1 -
 drivers/net/phy/phy.c            | 24 ------------------------
 include/linux/phy.h              |  1 -
 3 files changed, 26 deletions(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 16f90d8..bdec0f7 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -295,7 +295,6 @@ Doing it all yourself
    settings in the PHY.
 
  int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
- int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 
    Ethtool convenience functions.
 
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 9c372bf..8e26af5 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -484,30 +484,6 @@ int phy_ethtool_ksettings_set(struct phy_device *phydev,
 }
 EXPORT_SYMBOL(phy_ethtool_ksettings_set);
 
-int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
-{
-	cmd->supported = phydev->supported;
-
-	cmd->advertising = phydev->advertising;
-	cmd->lp_advertising = phydev->lp_advertising;
-
-	ethtool_cmd_speed_set(cmd, phydev->speed);
-	cmd->duplex = phydev->duplex;
-	if (phydev->interface == PHY_INTERFACE_MODE_MOCA)
-		cmd->port = PORT_BNC;
-	else
-		cmd->port = PORT_MII;
-	cmd->phy_address = phydev->mdio.addr;
-	cmd->transceiver = phy_is_internal(phydev) ?
-		XCVR_INTERNAL : XCVR_EXTERNAL;
-	cmd->autoneg = phydev->autoneg;
-	cmd->eth_tp_mdix_ctrl = phydev->mdix_ctrl;
-	cmd->eth_tp_mdix = phydev->mdix;
-
-	return 0;
-}
-EXPORT_SYMBOL(phy_ethtool_gset);
-
 void phy_ethtool_ksettings_get(struct phy_device *phydev,
 			       struct ethtool_link_ksettings *cmd)
 {
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 4ec07a6..804851c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -843,7 +843,6 @@ void phy_start_machine(struct phy_device *phydev);
 void phy_stop_machine(struct phy_device *phydev);
 void phy_trigger_machine(struct phy_device *phydev, bool sync);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
-int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 void phy_ethtool_ksettings_get(struct phy_device *phydev,
 			       struct ethtool_link_ksettings *cmd);
 int phy_ethtool_ksettings_set(struct phy_device *phydev,
-- 
2.9.4
