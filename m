From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: [PATCH v2 net-next 2/4] net: phy: update the mdix_ctrl with correct value.
Date: Tue, 29 Nov 2016 15:16:47 +0530
Message-ID: <1480412809-6122-3-git-send-email-Raju.Lakkaraju@microsemi.com>
References: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <Allan.Nielsen@microsemi.com>,
        <andrew@lunn.ch>, Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0059.outbound.protection.outlook.com ([104.47.32.59]:15753
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756101AbcK2KCS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:02:18 -0500
In-Reply-To: <1480412809-6122-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

Update the mdix and mdix_ctrl with corresponding ethtool configuration
parameters.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
---
 drivers/net/phy/phy.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 73adbaa..ee7e1aa 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -389,7 +389,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	phydev->duplex = cmd->duplex;
 
-	phydev->mdix = cmd->eth_tp_mdix_ctrl;
+	phydev->mdix_ctrl = cmd->eth_tp_mdix_ctrl;
 
 	/* Restart the PHY */
 	phy_start_aneg(phydev);
@@ -443,7 +443,7 @@ int phy_ethtool_ksettings_set(struct phy_device *phydev,
 
 	phydev->duplex = duplex;
 
-	phydev->mdix = cmd->base.eth_tp_mdix_ctrl;
+	phydev->mdix_ctrl = cmd->base.eth_tp_mdix_ctrl;
 
 	/* Restart the PHY */
 	phy_start_aneg(phydev);
@@ -469,7 +469,8 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 	cmd->transceiver = phy_is_internal(phydev) ?
 		XCVR_INTERNAL : XCVR_EXTERNAL;
 	cmd->autoneg = phydev->autoneg;
-	cmd->eth_tp_mdix_ctrl = phydev->mdix;
+	cmd->eth_tp_mdix_ctrl = phydev->mdix_ctrl;
+	cmd->eth_tp_mdix = phydev->mdix;
 
 	return 0;
 }
@@ -496,7 +497,8 @@ int phy_ethtool_ksettings_get(struct phy_device *phydev,
 
 	cmd->base.phy_address = phydev->mdio.addr;
 	cmd->base.autoneg = phydev->autoneg;
-	cmd->base.eth_tp_mdix_ctrl = phydev->mdix;
+	cmd->base.eth_tp_mdix_ctrl = phydev->mdix_ctrl;
+	cmd->base.eth_tp_mdix = phydev->mdix;
 
 	return 0;
 }
-- 
2.7.4
