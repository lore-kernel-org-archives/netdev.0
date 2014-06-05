From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH v2 5/6] pch_gbe: reset PHY before first configuration
Date: Thu,  5 Jun 2014 10:53:06 +0200
Message-ID: <1401958387-8154-5-git-send-email-alexander.stein@systec-electronic.com>
References: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Daniel Krueger <daniel.krueger@systec-electronic.com>,
	netdev@vger.kernel.org,
	Alexander Stein <alexander.stein@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:42849 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751630AbaFEIyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:54:53 -0400
In-Reply-To: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Krueger <daniel.krueger@systec-electronic.com>

It is a good idea to perform a PHY software reset, but is should be done
before performing the first configuration.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index 3fa9a8f..dc9f0d3 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -316,6 +316,8 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	if (ret)
 		netdev_err(adapter->netdev, "Error: mii_ethtool_gset\n");
 
+	pch_gbe_phy_sw_reset(hw);
+
 	ethtool_cmd_speed_set(&cmd, hw->mac.link_speed);
 	cmd.duplex = hw->mac.link_duplex;
 	cmd.advertising = hw->phy.autoneg_advertised;
@@ -324,8 +326,6 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	if (ret)
 		netdev_err(adapter->netdev, "Error: mii_ethtool_sset\n");
 
-	pch_gbe_phy_sw_reset(hw);
-
 	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
-- 
1.8.5.5
