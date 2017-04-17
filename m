From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 1/9] ftgmac100: Add ethtool n-way reset call
Date: Tue, 18 Apr 2017 08:36:58 +1000
Message-ID: <20170417223706.16483-2-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51402 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753810AbdDQWk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:40:57 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A non-wired up implementation accidentally made its way in
a previous patch (Make ring sizes configurable via ethtool).

This removes it and wires up the generic phy_ethtool_nway_reset
instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v2. - Use phy_ethtool_nway_reset() instead of custom implementation
---
 drivers/net/ethernet/faraday/ftgmac100.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2153c5b..4cdd25a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1045,13 +1045,6 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
 }
 
-static int ftgmac100_nway_reset(struct net_device *ndev)
-{
-	if (!ndev->phydev)
-		return -ENXIO;
-	return phy_start_aneg(ndev->phydev);
-}
-
 static void ftgmac100_get_ringparam(struct net_device *netdev,
 				    struct ethtool_ringparam *ering)
 {
@@ -1090,6 +1083,7 @@ static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
+	.nway_reset		= phy_ethtool_nway_reset,
 	.get_ringparam		= ftgmac100_get_ringparam,
 	.set_ringparam		= ftgmac100_set_ringparam,
 };
-- 
2.9.3
