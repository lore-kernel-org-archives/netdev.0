From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/2] amd-xgbe: Remove the adjustments needed for
 fixed speed
Date: Mon, 14 Jul 2014 14:05:52 -0500
Message-ID: <20140714190552.23626.93428.stgit@tlendack-t1.amdoffice.net>
References: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns-bn1lp0143.outbound.protection.outlook.com ([207.46.163.143]:3924
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756890AbaGNTF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2014 15:05:59 -0400
In-Reply-To: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the addition of entries in the phy speed/duplex settings
array to support KR and KX mode, the work-around to add/remove
baseT settings to run at a fixed speed is no longer needed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   10 ----------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    4 ----
 2 files changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 8909f2b..f740526 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -331,16 +331,6 @@ static int xgbe_set_settings(struct net_device *netdev,
 	     (cmd->duplex != DUPLEX_FULL)))
 		goto unlock;
 
-	if (cmd->autoneg == AUTONEG_ENABLE) {
-		/* Clear settings needed to force speeds */
-		phydev->supported &= ~SUPPORTED_1000baseT_Full;
-		phydev->supported &= ~SUPPORTED_10000baseT_Full;
-	} else {
-		/* Add settings needed to force speed */
-		phydev->supported |= SUPPORTED_1000baseT_Full;
-		phydev->supported |= SUPPORTED_10000baseT_Full;
-	}
-
 	cmd->advertising &= phydev->supported;
 	if ((cmd->autoneg == AUTONEG_ENABLE) && !cmd->advertising)
 		goto unlock;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index ea7a5d6..225f22d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -375,10 +375,6 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 
 	phydev->autoneg = pdata->default_autoneg;
 	if (phydev->autoneg == AUTONEG_DISABLE) {
-		/* Add settings needed to force speed */
-		phydev->supported |= SUPPORTED_1000baseT_Full;
-		phydev->supported |= SUPPORTED_10000baseT_Full;
-
 		phydev->speed = pdata->default_speed;
 		phydev->duplex = DUPLEX_FULL;
 
