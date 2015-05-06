From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 2/2] gianfar: Enable changing mac addr when if up
Date: Wed, 6 May 2015 18:07:30 +0300
Message-ID: <1430924850-2871-2-git-send-email-claudiu.manoil@freescale.com>
References: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0140.outbound.protection.outlook.com ([157.56.111.140]:59273
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752081AbbEFPHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 11:07:47 -0400
In-Reply-To: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use device flag IFF_LIVE_ADDR_CHANGE to signal that
the device supports changing the hardware address when
the device is running.
This allows eth_mac_addr() to change the mac address
also when the network device's interface is open.
This capability is required by certain applications,
like bonding mode 6 (Adaptive Load Balancing).

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3c84e5a..ff87502 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -516,6 +516,15 @@ static struct net_device_stats *gfar_get_stats(struct net_device *dev)
 	return &dev->stats;
 }
 
+static int gfar_set_mac_addr(struct net_device *dev, void *p)
+{
+	eth_mac_addr(dev, p);
+
+	gfar_set_mac_for_addr(dev, 0, dev->dev_addr);
+
+	return 0;
+}
+
 static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_open = gfar_enet_open,
 	.ndo_start_xmit = gfar_start_xmit,
@@ -526,7 +535,7 @@ static const struct net_device_ops gfar_netdev_ops = {
 	.ndo_tx_timeout = gfar_timeout,
 	.ndo_do_ioctl = gfar_ioctl,
 	.ndo_get_stats = gfar_get_stats,
-	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_set_mac_address = gfar_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = gfar_netpoll,
@@ -1411,6 +1420,8 @@ static int gfar_probe(struct platform_device *ofdev)
 		dev->features |= NETIF_F_HW_VLAN_CTAG_RX;
 	}
 
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+
 	gfar_init_addr_hash_table(priv);
 
 	/* Insert receive time stamps into padding alignment bytes */
-- 
1.7.11.7
