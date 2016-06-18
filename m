From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: nb8800: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 18 Jun 2016 23:16:55 +0200
Message-ID: <1466284615-7045-2-git-send-email-tremyfr@gmail.com>
References: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: mans@mansr.com, davem@davemloft.net, sf84@laposte.net,
	arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36574 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcFRVRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 17:17:07 -0400
In-Reply-To: <1466284615-7045-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/aurora/nb8800.c |   24 ++----------------------
 1 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 4989d31..dc2c35d 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -1035,26 +1035,6 @@ static const struct net_device_ops nb8800_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static int nb8800_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, cmd);
-}
-
-static int nb8800_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct phy_device *phydev = dev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, cmd);
-}
-
 static int nb8800_nway_reset(struct net_device *dev)
 {
 	struct phy_device *phydev = dev->phydev;
@@ -1183,8 +1163,6 @@ static void nb8800_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops nb8800_ethtool_ops = {
-	.get_settings		= nb8800_get_settings,
-	.set_settings		= nb8800_set_settings,
 	.nway_reset		= nb8800_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_pauseparam		= nb8800_get_pauseparam,
@@ -1192,6 +1170,8 @@ static const struct ethtool_ops nb8800_ethtool_ops = {
 	.get_sset_count		= nb8800_get_sset_count,
 	.get_strings		= nb8800_get_strings,
 	.get_ethtool_stats	= nb8800_get_ethtool_stats,
+	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
+	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
 };
 
 static int nb8800_hw_init(struct net_device *dev)
-- 
1.7.4.4
