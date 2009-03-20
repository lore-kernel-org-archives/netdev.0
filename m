From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sungem: missing net_device_ops
Date: Thu, 19 Mar 2009 23:53:13 -0700
Message-ID: <20090319235313.300e51a9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45556 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbZCTGxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 02:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sungem driver only got partially converted to net_device_ops.
Since this could cause bugs, please push this to 2.6.29

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sungem.c	2009-03-19 23:42:39.988903014 -0700
+++ b/drivers/net/sungem.c	2009-03-19 23:43:47.282840042 -0700
@@ -2998,8 +2998,11 @@ static const struct net_device_ops gem_n
 	.ndo_do_ioctl		= gem_ioctl,
 	.ndo_tx_timeout		= gem_tx_timeout,
 	.ndo_change_mtu		= gem_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address    = gem_set_mac_address,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller    = gem_poll_controller,
+#endif
 };
 
 static int __devinit gem_init_one(struct pci_dev *pdev,
@@ -3161,10 +3164,6 @@ static int __devinit gem_init_one(struct
 	dev->watchdog_timeo = 5 * HZ;
 	dev->irq = pdev->irq;
 	dev->dma = 0;
-	dev->set_mac_address = gem_set_mac_address;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = gem_poll_controller;
-#endif
 
 	/* Set that now, in case PM kicks in now */
 	pci_set_drvdata(pdev, dev);
