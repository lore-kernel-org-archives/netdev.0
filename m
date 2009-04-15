From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 02/26] cpmac: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:36 +0400
Message-ID: <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:38634 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbZDOWxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:06 -0400
Received: by bwz17 with SMTP id 17so114630bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:03 -0700 (PDT)
In-Reply-To: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/cpmac.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 3f476c7..af305c0 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1093,6 +1093,19 @@ static int cpmac_stop(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops cpmac_netdev_ops = {
+	.ndo_open		= cpmac_open,
+	.ndo_stop		= cpmac_stop,
+	.ndo_start_xmit		= cpmac_start_xmit,
+	.ndo_tx_timeout		= cpmac_tx_timeout,
+	.ndo_set_multicast_list	= cpmac_set_multicast_list,
+	.ndo_so_ioctl		= cpmac_ioctl,
+	.ndo_set_config		= cpmac_config,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int external_switch;
 
 static int __devinit cpmac_probe(struct platform_device *pdev)
@@ -1143,14 +1156,8 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	dev->irq = platform_get_irq_byname(pdev, "irq");
 
-	dev->open               = cpmac_open;
-	dev->stop               = cpmac_stop;
-	dev->set_config         = cpmac_config;
-	dev->hard_start_xmit    = cpmac_start_xmit;
-	dev->do_ioctl           = cpmac_ioctl;
-	dev->set_multicast_list = cpmac_set_multicast_list;
-	dev->tx_timeout         = cpmac_tx_timeout;
-	dev->ethtool_ops        = &cpmac_ethtool_ops;
+	dev->netdev_ops = &cpmac_netdev_ops;
+	dev->ethtool_ops = &cpmac_ethtool_ops;
 
 	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
 
-- 
1.6.2.3

