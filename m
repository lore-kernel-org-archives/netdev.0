From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] switch sgiseeq to netdev_ops
Date: Fri,  1 May 2009 12:59:32 +0200 (CEST)
Message-ID: <20090501105932.7EC47C3C8B@solo.franken.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:44987 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbZEAMoz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 08:44:55 -0400
Received: from uucp (helo=solo.franken.de)
	by elvis.franken.de with local-bsmtp (Exim 3.36 #1)
	id 1LzqSv-0008QG-00
	for netdev@vger.kernel.org; Fri, 01 May 2009 12:59:37 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/sgiseeq.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 97d6856..ca1b109 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -709,6 +709,17 @@ static inline void setup_rx_ring(struct net_device *dev,
 	dma_sync_desc_dev(dev, &buf[i]);
 }
 
+static const struct net_device_ops sgiseeq_netdev_ops = {
+	.ndo_open               = sgiseeq_open,
+	.ndo_stop               = sgiseeq_close,
+	.ndo_start_xmit         = sgiseeq_start_xmit,
+	.ndo_tx_timeout         = timeout,
+	.ndo_set_multicast_list = sgiseeq_set_multicast,
+	.ndo_change_mtu         = eth_change_mtu,
+	.ndo_set_mac_address    = sgiseeq_set_mac_address,
+	.ndo_validate_addr      = eth_validate_addr,
+};
+
 static int __init sgiseeq_probe(struct platform_device *pdev)
 {
 	struct sgiseeq_platform_data *pd = pdev->dev.platform_data;
@@ -775,13 +786,8 @@ static int __init sgiseeq_probe(struct platform_device *pdev)
 			      SEEQ_CTRL_SFLAG | SEEQ_CTRL_ESHORT |
 			      SEEQ_CTRL_ENCARR;
 
-	dev->open		= sgiseeq_open;
-	dev->stop		= sgiseeq_close;
-	dev->hard_start_xmit	= sgiseeq_start_xmit;
-	dev->tx_timeout		= timeout;
+	dev->netdev_ops         = &sgiseeq_netdev_ops;
 	dev->watchdog_timeo	= (200 * HZ) / 1000;
-	dev->set_multicast_list	= sgiseeq_set_multicast;
-	dev->set_mac_address	= sgiseeq_set_mac_address;
 	dev->irq		= irq;
 
 	if (register_netdev(dev)) {
