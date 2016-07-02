From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: cavium: octeon: use phy_ethtool_{get|set}_link_ksettings
Date: Sat,  2 Jul 2016 23:37:00 +0200
Message-ID: <1467495420-23359-2-git-send-email-tremyfr@gmail.com>
References: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, ivecera@redhat.com,
	a@unstable.cc, fw@strlen.de, david.daney@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35679 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbcGBVhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 17:37:22 -0400
In-Reply-To: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c |   25 +--------------------
 1 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index de678e6..e8bc15b 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -1346,27 +1346,6 @@ static void octeon_mgmt_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->bus_info, "N/A", sizeof(info->bus_info));
 }
 
-static int octeon_mgmt_get_settings(struct net_device *netdev,
-				    struct ethtool_cmd *cmd)
-{
-	if (netdev->phydev)
-		return phy_ethtool_gset(netdev->phydev, cmd);
-
-	return -EOPNOTSUPP;
-}
-
-static int octeon_mgmt_set_settings(struct net_device *netdev,
-				    struct ethtool_cmd *cmd)
-{
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	if (netdev->phydev)
-		return phy_ethtool_sset(netdev->phydev, cmd);
-
-	return -EOPNOTSUPP;
-}
-
 static int octeon_mgmt_nway_reset(struct net_device *dev)
 {
 	if (!capable(CAP_NET_ADMIN))
@@ -1380,10 +1359,10 @@ static int octeon_mgmt_nway_reset(struct net_device *dev)
 
 static const struct ethtool_ops octeon_mgmt_ethtool_ops = {
 	.get_drvinfo = octeon_mgmt_get_drvinfo,
-	.get_settings = octeon_mgmt_get_settings,
-	.set_settings = octeon_mgmt_set_settings,
 	.nway_reset = octeon_mgmt_nway_reset,
 	.get_link = ethtool_op_get_link,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops octeon_mgmt_ops = {
-- 
1.7.4.4
