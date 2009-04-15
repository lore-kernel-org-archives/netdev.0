From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 24/26] sgiseeq: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:58 +0400
Message-ID: <1239835980-22502-24-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-4-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-5-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-6-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-7-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-8-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-9-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-10-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-13-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-14-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-15-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-16-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-17-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-18-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-19-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-20-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-21-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-22-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-23-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:46923 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756477AbZDOWxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:32 -0400
Received: by mu-out-0910.google.com with SMTP id g7so51282muf.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:32 -0700 (PDT)
In-Reply-To: <1239835980-22502-23-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/sgiseeq.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 97d6856..5fb88ca 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -709,6 +709,17 @@ static inline void setup_rx_ring(struct net_device *dev,
 	dma_sync_desc_dev(dev, &buf[i]);
 }
 
+static const struct net_device_ops sgiseeq_netdev_ops = {
+	.ndo_open		= sgiseeq_open,
+	.ndo_stop		= sgiseeq_close,
+	.ndo_start_xmit		= sgiseeq_start_xmit,
+	.ndo_tx_timeout		= timeout,
+	.ndo_set_multicast_list	= sgiseeq_set_multicast,
+	.ndo_set_mac_address	= sgiseeq_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
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
+	dev->netdev_ops		= &sgiseeq_netdev_ops;
 	dev->watchdog_timeo	= (200 * HZ) / 1000;
-	dev->set_multicast_list	= sgiseeq_set_multicast;
-	dev->set_mac_address	= sgiseeq_set_mac_address;
 	dev->irq		= irq;
 
 	if (register_netdev(dev)) {
-- 
1.6.2.3

