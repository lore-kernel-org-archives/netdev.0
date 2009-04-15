From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH] macb: Add support of the netpoll API
Date: Wed, 15 Apr 2009 15:46:58 +0200
Message-ID: <20090415154658.40e3639a@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Michael Opdenacker <michael@free-electrons.com>
To: hskinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.76.200]:45882 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbZDON6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 09:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb: Add support of the netpoll API

With this patch in place, I'm successfully able to use the netconsole
mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
CPU, which in terms of Ethernet controller is supported by the macb
driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/macb.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

Index: linux/drivers/net/macb.c
===================================================================
--- linux.orig/drivers/net/macb.c
+++ linux/drivers/net/macb.c
@@ -616,6 +616,19 @@
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void macb_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	macb_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
@@ -1184,6 +1197,9 @@
 	dev->do_ioctl = macb_ioctl;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = macb_poll_controller;
+#endif
 
 	dev->base_addr = regs->start;
 


-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
