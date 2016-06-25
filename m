From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: dwc_eth_qos: use phy_ethtool_{get|set}_link_ksettings
Date: Sat, 25 Jun 2016 23:05:16 +0200
Message-ID: <1466888716-31222-2-git-send-email-tremyfr@gmail.com>
References: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: lars.persson@axis.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36088 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbcFYVFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 17:05:33 -0400
In-Reply-To: <1466888716-31222-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c |   26 ++------------------------
 1 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 094234f..c14fa91 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2524,28 +2524,6 @@ dwceqos_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *s)
 	return s;
 }
 
-static int
-dwceqos_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_gset(phydev, ecmd);
-}
-
-static int
-dwceqos_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
-{
-	struct phy_device *phydev = ndev->phydev;
-
-	if (!phydev)
-		return -ENODEV;
-
-	return phy_ethtool_sset(phydev, ecmd);
-}
-
 static void
 dwceqos_get_drvinfo(struct net_device *ndev, struct ethtool_drvinfo *ed)
 {
@@ -2764,8 +2742,6 @@ static void dwceqos_set_msglevel(struct net_device *ndev, u32 msglevel)
 }
 
 static struct ethtool_ops dwceqos_ethtool_ops = {
-	.get_settings   = dwceqos_get_settings,
-	.set_settings   = dwceqos_set_settings,
 	.get_drvinfo    = dwceqos_get_drvinfo,
 	.get_link       = ethtool_op_get_link,
 	.get_pauseparam = dwceqos_get_pauseparam,
@@ -2779,6 +2755,8 @@ static struct ethtool_ops dwceqos_ethtool_ops = {
 	.set_eee        = dwceqos_set_eee,
 	.get_msglevel   = dwceqos_get_msglevel,
 	.set_msglevel   = dwceqos_set_msglevel,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
 static struct net_device_ops netdev_ops = {
-- 
1.7.4.4
