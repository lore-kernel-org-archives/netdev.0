From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 4/6] ep93xx_eth: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:28:06 +0400
Message-ID: <20090410032806.GB29233@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:58984 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760623AbZDJD2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:28:11 -0400
Received: by fg-out-1718.google.com with SMTP id e12so281933fga.17
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:28:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also make ep93xx_dev_alloc static.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/arm/ep93xx_eth.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index cc77087..4173677 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -770,7 +770,18 @@ static struct ethtool_ops ep93xx_ethtool_ops = {
 	.get_link		= ep93xx_get_link,
 };
 
-struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
+static const struct net_device_ops ep93xx_netdev_ops = {
+	.ndo_open		= ep93xx_open,
+	.ndo_stop		= ep93xx_close,
+	.ndo_start_xmit		= ep93xx_xmit,
+	.ndo_get_stats		= ep93xx_get_stats,
+	.ndo_do_ioctl		= ep93xx_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
+static struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 {
 	struct net_device *dev;
 
@@ -780,12 +791,8 @@ struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 
 	memcpy(dev->dev_addr, data->dev_addr, ETH_ALEN);
 
-	dev->get_stats = ep93xx_get_stats;
 	dev->ethtool_ops = &ep93xx_ethtool_ops;
-	dev->hard_start_xmit = ep93xx_xmit;
-	dev->open = ep93xx_open;
-	dev->stop = ep93xx_close;
-	dev->do_ioctl = ep93xx_ioctl;
+	dev->netdev_ops = &ep93xx_netdev_ops;
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 
