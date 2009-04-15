From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/5] a2065: convert to net_device_ops
Date: Wed, 15 Apr 2009 08:30:21 +0400
Message-ID: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:43042 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbZDOEaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:30:35 -0400
Received: by fxm2 with SMTP id 2so2713444fxm.37
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 21:30:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/a2065.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/a2065.c b/drivers/net/a2065.c
index d0d0c2f..02f64d5 100644
--- a/drivers/net/a2065.c
+++ b/drivers/net/a2065.c
@@ -692,6 +692,17 @@ static struct zorro_driver a2065_driver = {
 	.remove		= __devexit_p(a2065_remove_one),
 };
 
+static const struct net_device_ops lance_netdev_ops = {
+	.ndo_open		= lance_open,
+	.ndo_stop		= lance_close,
+	.ndo_start_xmit		= lance_start_xmit,
+	.ndo_tx_timeout		= lance_tx_timeout,
+	.ndo_set_multicast_list	= lance_set_multicast,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __devinit a2065_init_one(struct zorro_dev *z,
 				    const struct zorro_device_id *ent)
 {
@@ -753,12 +764,8 @@ static int __devinit a2065_init_one(struct zorro_dev *z,
 	priv->rx_ring_mod_mask = RX_RING_MOD_MASK;
 	priv->tx_ring_mod_mask = TX_RING_MOD_MASK;
 
-	dev->open = &lance_open;
-	dev->stop = &lance_close;
-	dev->hard_start_xmit = &lance_start_xmit;
-	dev->tx_timeout = &lance_tx_timeout;
+	dev->netdev_ops = &lance_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
-	dev->set_multicast_list = &lance_set_multicast;
 	dev->dma = 0;
 
 	init_timer(&priv->multicast_timer);
-- 
1.6.2.3

