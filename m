From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 03/11] tc35815: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:38:54 +0400
Message-ID: <20090411173854.GC16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:1040 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616AbZDKRjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:39:02 -0400
Received: by an-out-0708.google.com with SMTP id d14so1349651and.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:39:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/tc35815.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index d91e95b..0ce2db6 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -862,6 +862,22 @@ static int __devinit tc35815_init_dev_addr(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops tc35815_netdev_ops = {
+	.ndo_open		= tc35815_open,
+	.ndo_stop		= tc35815_close,
+	.ndo_start_xmit		= tc35815_send_packet,
+	.ndo_get_stats		= tc35815_get_stats,
+	.ndo_set_multicast_list	= tc35815_set_multicast_list,
+	.ndo_tx_timeout		= tc35815_tx_timeout,
+	.ndo_do_ioctl		= tc35815_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= tc35815_poll_controller,
+#endif
+};
+
 static int __devinit tc35815_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
@@ -904,21 +920,12 @@ static int __devinit tc35815_init_one(struct pci_dev *pdev,
 	ioaddr = pcim_iomap_table(pdev)[1];
 
 	/* Initialize the device structure. */
-	dev->open = tc35815_open;
-	dev->hard_start_xmit = tc35815_send_packet;
-	dev->stop = tc35815_close;
-	dev->get_stats = tc35815_get_stats;
-	dev->set_multicast_list = tc35815_set_multicast_list;
-	dev->do_ioctl = tc35815_ioctl;
+	dev->netdev_ops = &tc35815_netdev_ops;
 	dev->ethtool_ops = &tc35815_ethtool_ops;
-	dev->tx_timeout = tc35815_tx_timeout;
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
 #ifdef TC35815_NAPI
 	netif_napi_add(dev, &lp->napi, tc35815_poll, NAPI_WEIGHT);
 #endif
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = tc35815_poll_controller;
-#endif
 
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long)ioaddr;
