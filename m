From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 23/26] sb1250-mac: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:57 +0400
Message-ID: <1239835980-22502-23-git-send-email-a.beregalov@gmail.com>
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
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:22291 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756706AbZDOWxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:31 -0400
Received: by fk-out-0910.google.com with SMTP id 18so54609fkq.5
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:31 -0700 (PDT)
In-Reply-To: <1239835980-22502-22-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/sb1250-mac.c |   29 +++++++++++++++++------------
 1 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index ce7551e..aaeebf5 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2271,6 +2271,21 @@ static int sb1250_change_mtu(struct net_device *_dev, int new_mtu)
 	return 0;
 }
 
+static const struct net_device_ops sbmac_netdev_ops = {
+	.ndo_open		= sbmac_open,
+	.ndo_stop		= sbmac_close,
+	.ndo_start_xmit		= sbmac_start_tx,
+	.ndo_set_multicast_list	= sbmac_set_rx_mode,
+	.ndo_tx_timeout		= sbmac_tx_timeout,
+	.ndo_do_ioctl		= sbmac_mii_ioctl,
+	.ndo_change_mtu		= sb1250_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= sbmac_netpoll,
+#endif
+};
+
 /**********************************************************************
  *  SBMAC_INIT(dev)
  *
@@ -2327,21 +2342,11 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 
 	spin_lock_init(&(sc->sbm_lock));
 
-	dev->open               = sbmac_open;
-	dev->hard_start_xmit    = sbmac_start_tx;
-	dev->stop               = sbmac_close;
-	dev->set_multicast_list = sbmac_set_rx_mode;
-	dev->do_ioctl           = sbmac_mii_ioctl;
-	dev->tx_timeout         = sbmac_tx_timeout;
-	dev->watchdog_timeo     = TX_TIMEOUT;
+	dev->netdev_ops = &sbmac_netdev_ops;
+	dev->watchdog_timeo = TX_TIMEOUT;
 
 	netif_napi_add(dev, &sc->napi, sbmac_poll, 16);
 
-	dev->change_mtu         = sb1250_change_mtu;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = sbmac_netpoll;
-#endif
-
 	dev->irq		= UNIT_INT(idx);
 
 	/* This is needed for PASS2 for Rx H/W checksum feature */
-- 
1.6.2.3

