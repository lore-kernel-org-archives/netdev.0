From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 12/26] korina: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:46 +0400
Message-ID: <1239835980-22502-12-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:48714 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360AbZDOWxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:19 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so121386fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:18 -0700 (PDT)
In-Reply-To: <1239835980-22502-11-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/korina.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 38d6649..dc23856 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1081,6 +1081,21 @@ static int korina_close(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops korina_netdev_ops = {
+	.ndo_open		= korina_open,
+	.ndo_stop		= korina_close,
+	.ndo_start_xmit		= korina_send_packet,
+	.ndo_set_multicast_list	= korina_multicast_list,
+	.ndo_tx_timeout		= korina_tx_timeout,
+	.ndo_do_ioctl		= korina_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= korina_poll_controller,
+#endif
+};
+
 static int korina_probe(struct platform_device *pdev)
 {
 	struct korina_device *bif = platform_get_drvdata(pdev);
@@ -1149,17 +1164,9 @@ static int korina_probe(struct platform_device *pdev)
 	dev->irq = lp->rx_irq;
 	lp->dev = dev;
 
-	dev->open = korina_open;
-	dev->stop = korina_close;
-	dev->hard_start_xmit = korina_send_packet;
-	dev->set_multicast_list = &korina_multicast_list;
+	dev->netdev_ops = &korina_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = korina_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->do_ioctl = &korina_ioctl;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = korina_poll_controller;
-#endif
 	netif_napi_add(dev, &lp->napi, korina_poll, 64);
 
 	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
-- 
1.6.2.3

