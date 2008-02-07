From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 4/7] PS3: gelic: remove duplicated ethtool handlers
Date: Thu, 07 Feb 2008 19:58:20 +0900
Message-ID: <20080207195809.AD49.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	geoffrey.levand@am.sony.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW3.Sony.CO.JP ([137.153.0.15]:61040 "EHLO mgw3.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757180AbYBGK62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 05:58:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PS3: gelic: remove duplicated ethtool handlers

Remove some ethtool handlers, which duplicate functionality that was already
provided by the common ethtool handlers.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |   43 +++----------------------------------------
 1 file changed, 3 insertions(+), 40 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1196,28 +1196,6 @@ static int gelic_ether_get_settings(stru
 	return 0;
 }
 
-static u32 gelic_ether_get_link(struct net_device *netdev)
-{
-	struct gelic_card *card = netdev_priv(netdev);
-	int status;
-	u64 v1, v2;
-	int link;
-
-	status = lv1_net_control(bus_id(card), dev_id(card),
-				 GELIC_LV1_GET_ETH_PORT_STATUS,
-				 GELIC_LV1_VLAN_TX_ETHERNET, 0, 0,
-				 &v1, &v2);
-	if (status)
-		return 0; /* link down */
-
-	if (v1 & GELIC_LV1_ETHER_LINK_UP)
-		link = 1;
-	else
-		link = 0;
-
-	return link;
-}
-
 static int gelic_net_nway_reset(struct net_device *netdev)
 {
 	if (netif_running(netdev)) {
@@ -1227,21 +1205,6 @@ static int gelic_net_nway_reset(struct n
 	return 0;
 }
 
-static u32 gelic_net_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) != 0;
-}
-
-static int gelic_net_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |= NETIF_F_IP_CSUM;
-	else
-		netdev->features &= ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
 static u32 gelic_net_get_rx_csum(struct net_device *netdev)
 {
 	struct gelic_card *card = netdev_priv(netdev);
@@ -1260,10 +1223,10 @@ static int gelic_net_set_rx_csum(struct 
 static struct ethtool_ops gelic_net_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
 	.get_settings	= gelic_ether_get_settings,
-	.get_link	= gelic_ether_get_link,
+	.get_link	= ethtool_op_get_link,
 	.nway_reset	= gelic_net_nway_reset,
-	.get_tx_csum	= gelic_net_get_tx_csum,
-	.set_tx_csum	= gelic_net_set_tx_csum,
+	.get_tx_csum	= ethtool_op_get_tx_csum,
+	.set_tx_csum	= ethtool_op_set_tx_csum,
 	.get_rx_csum	= gelic_net_get_rx_csum,
 	.set_rx_csum	= gelic_net_set_rx_csum,
 };


