From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: mvpp2: use phy_ethtool_{get|set}_link_ksettings
Date: Tue, 28 Jun 2016 00:08:12 +0200
Message-ID: <1467065292-20996-2-git-send-email-tremyfr@gmail.com>
References: <1467065292-20996-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mw@semihalf.com, jszhang@marvell.com,
	amitoj1606@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36039 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbcF0WIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 18:08:21 -0400
In-Reply-To: <1467065292-20996-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/marvell/mvpp2.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 18477fe..0b04717 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5813,24 +5813,6 @@ static int mvpp2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 /* Ethtool methods */
 
-/* Get settings (phy address, speed) for ethtools */
-static int mvpp2_ethtool_get_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
-/* Set settings (phy address, speed) for ethtools */
-static int mvpp2_ethtool_set_settings(struct net_device *dev,
-				      struct ethtool_cmd *cmd)
-{
-	if (!dev->phydev)
-		return -ENODEV;
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
 /* Set interrupt coalescing for ethtools */
 static int mvpp2_ethtool_set_coalesce(struct net_device *dev,
 				      struct ethtool_coalesce *c)
@@ -5965,13 +5947,13 @@ static const struct net_device_ops mvpp2_netdev_ops = {
 
 static const struct ethtool_ops mvpp2_eth_tool_ops = {
 	.get_link	= ethtool_op_get_link,
-	.get_settings	= mvpp2_ethtool_get_settings,
-	.set_settings	= mvpp2_ethtool_set_settings,
 	.set_coalesce	= mvpp2_ethtool_set_coalesce,
 	.get_coalesce	= mvpp2_ethtool_get_coalesce,
 	.get_drvinfo	= mvpp2_ethtool_get_drvinfo,
 	.get_ringparam	= mvpp2_ethtool_get_ringparam,
 	.set_ringparam	= mvpp2_ethtool_set_ringparam,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 /* Driver initialization */
-- 
1.7.4.4
