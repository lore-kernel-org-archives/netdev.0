From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: pasemi_mac: use phy_ethtool_{get|set}_link_ksettings
Date: Thu, 14 Jul 2016 23:44:53 +0200
Message-ID: <1468532693-456-2-git-send-email-tremyfr@gmail.com>
References: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: olof@lixom.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35584 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbcGNVpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 17:45:04 -0400
In-Reply-To: <1468532693-456-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c |   28 +--------------------
 1 files changed, 2 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
index e99cf42..d0afc2b 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac_ethtool.c
@@ -62,30 +62,6 @@ static struct {
 	{ "tx-1024-1518-byte-packets" },
 };
 
-static int
-pasemi_mac_ethtool_get_settings(struct net_device *netdev,
-			       struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = netdev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int
-pasemi_mac_ethtool_set_settings(struct net_device *netdev,
-			       struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = netdev->phydev;
-
-	if (!phydev)
-		return -EOPNOTSUPP;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static u32
 pasemi_mac_ethtool_get_msglevel(struct net_device *netdev)
 {
@@ -143,8 +119,6 @@ static void pasemi_mac_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 const struct ethtool_ops pasemi_mac_ethtool_ops = {
-	.get_settings		= pasemi_mac_ethtool_get_settings,
-	.set_settings		= pasemi_mac_ethtool_set_settings,
 	.get_msglevel		= pasemi_mac_ethtool_get_msglevel,
 	.set_msglevel		= pasemi_mac_ethtool_set_msglevel,
 	.get_link		= ethtool_op_get_link,
@@ -152,5 +126,7 @@ const struct ethtool_ops pasemi_mac_ethtool_ops = {
 	.get_strings		= pasemi_mac_get_strings,
 	.get_sset_count		= pasemi_mac_get_sset_count,
 	.get_ethtool_stats	= pasemi_mac_get_ethtool_stats,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
-- 
1.7.4.4
