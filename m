From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] fs_enet: fix polling
Date: Sun, 2 Nov 2008 17:49:59 +0300
Message-ID: <20081102144959.GA10869@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
	Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:31190 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbYKBOqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 09:46:51 -0500
Received: by ey-out-2122.google.com with SMTP id 6so708664eyi.37
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2008 06:46:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. compile fix for irqreturn_t type change
2. restore ->poll_controller after CONFIG_PPC_CPM_NEW_BINDING transition

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1099,7 +1099,9 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	ndev->stop = fs_enet_close;
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
-
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller = fs_enet_netpoll;
+#endif
 	if (fpi->use_napi)
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
@@ -1209,7 +1211,7 @@ static void __exit fs_cleanup(void)
 static void fs_enet_netpoll(struct net_device *dev)
 {
        disable_irq(dev->irq);
-       fs_enet_interrupt(dev->irq, dev, NULL);
+       fs_enet_interrupt(dev->irq, dev);
        enable_irq(dev->irq);
 }
 #endif
