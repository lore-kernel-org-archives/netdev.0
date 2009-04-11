From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH 02/11] tsi108_eth: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:37:59 +0400
Message-ID: <20090411173759.GB16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:44311 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbZDKRiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:38:07 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1786903qwh.37
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:38:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/tsi108_eth.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index bb43e7f..0f78f99 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1561,6 +1561,18 @@ static const struct ethtool_ops tsi108_ethtool_ops = {
 	.set_settings	= tsi108_set_settings,
 };
 
+static const struct net_device_ops tsi108_netdev_ops = {
+	.ndo_open		= tsi108_open,
+	.ndo_stop		= tsi108_close,
+	.ndo_start_xmit		= tsi108_send_packet,
+	.ndo_set_multicast_list	= tsi108_set_rx_mode,
+	.ndo_get_stats		= tsi108_get_stats,
+	.ndo_do_ioctl		= tsi108_do_ioctl,
+	.ndo_set_mac_address	= tsi108_set_mac,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static int
 tsi108_init_one(struct platform_device *pdev)
 {
@@ -1616,14 +1628,8 @@ tsi108_init_one(struct platform_device *pdev)
 	data->phy_type = einfo->phy_type;
 	data->irq_num = einfo->irq_num;
 	data->id = pdev->id;
-	dev->open = tsi108_open;
-	dev->stop = tsi108_close;
-	dev->hard_start_xmit = tsi108_send_packet;
-	dev->set_mac_address = tsi108_set_mac;
-	dev->set_multicast_list = tsi108_set_rx_mode;
-	dev->get_stats = tsi108_get_stats;
 	netif_napi_add(dev, &data->napi, tsi108_poll, 64);
-	dev->do_ioctl = tsi108_do_ioctl;
+	dev->netdev_ops = &tsi108_netdev_ops;
 	dev->ethtool_ops = &tsi108_ethtool_ops;
 
 	/* Apparently, the Linux networking code won't use scatter-gather
