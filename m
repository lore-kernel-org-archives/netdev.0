From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] fix ne driver link error
Date: Tue, 29 Jul 2008 22:29:25 +0900
Message-ID: <20080729222925.37232c47.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo30.po.2iij.NET ([210.128.50.51]:12645 "EHLO
	mfo30.po.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbYG2Nie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 09:38:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ne driver is required 8390p.

drivers/built-in.o: In function `ne_probe1':
ne.c:(.init.text+0x25c8): undefined reference to `NS8390_init'

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/net/ne.c linux/drivers/net/ne.c
--- linux-orig/drivers/net/ne.c	2008-07-25 16:43:41.905549705 +0900
+++ linux/drivers/net/ne.c	2008-07-26 17:18:44.150322098 +0900
@@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_d
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -794,7 +794,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev,1);
 			break;
 		}
 
@@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform
 
 	if (netif_running(dev)) {
 		ne_reset_8390(dev);
-		NS8390_init(dev, 1);
+		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
 	}
 	return 0;
