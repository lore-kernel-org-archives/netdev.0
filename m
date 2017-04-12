From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 1/8] ftgmac100: Add ethtool n-way reset call
Date: Thu, 13 Apr 2017 08:44:36 +1000
Message-ID: <20170412224443.17906-2-benh@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33726 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754818AbdDLWqN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:46:13 -0400
In-Reply-To: <20170412224443.17906-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 796b37e..bbeb8e7 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1043,11 +1043,11 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
 }
 
-static int ftgmac100_nway_reset(struct net_device *ndev)
+static int ftgmac100_nway_reset(struct net_device *netdev)
 {
-	if (!ndev->phydev)
+	if (!netdev->phydev)
 		return -ENXIO;
-	return phy_start_aneg(ndev->phydev);
+	return phy_start_aneg(netdev->phydev);
 }
 
 static void ftgmac100_get_ringparam(struct net_device *netdev,
@@ -1088,6 +1088,7 @@ static const struct ethtool_ops ftgmac100_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
 	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
+	.nway_reset		= ftgmac100_nway_reset,
 	.get_ringparam		= ftgmac100_get_ringparam,
 	.set_ringparam		= ftgmac100_set_ringparam,
 };
-- 
2.9.3
