From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH v2 4/6] pch_gbe: remove unnecessary PHY resets
Date: Thu,  5 Jun 2014 10:53:05 +0200
Message-ID: <1401958387-8154-4-git-send-email-alexander.stein@systec-electronic.com>
References: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:42840 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751125AbaFEIys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:54:48 -0400
In-Reply-To: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

Those PHY software resets destroy the painfully made PHY settings.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c | 2 --
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c     | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 826f0cc..fbfac98 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -111,8 +111,6 @@ static int pch_gbe_set_settings(struct net_device *netdev,
 	u32 speed = ethtool_cmd_speed(ecmd);
 	int ret;
 
-	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
-
 	/* when set_settings() is called with a ethtool_cmd previously
 	 * filled by get_settings() on a down link, speed is -1: */
 	if (speed == UINT_MAX) {
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index a5cad5e..3fa9a8f 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -320,7 +320,6 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	cmd.duplex = hw->mac.link_duplex;
 	cmd.advertising = hw->phy.autoneg_advertised;
 	cmd.autoneg = hw->mac.autoneg;
-	pch_gbe_phy_write_reg_miic(hw, MII_BMCR, BMCR_RESET);
 	ret = mii_ethtool_sset(&adapter->mii, &cmd);
 	if (ret)
 		netdev_err(adapter->netdev, "Error: mii_ethtool_sset\n");
-- 
1.8.5.5
