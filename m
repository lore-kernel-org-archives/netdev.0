From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19 3/4] AT91RM9200 Ethernet: Add netpoll / netconsole
	support
Date: 05 Dec 2006 15:33:05 +0200
Message-ID: <1165325584.12510.93.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:3628 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968190AbWLENmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 08:42:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds netpoll / netconsole support.

Original patch from Bill Gatliff.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Tue Dec  5 14:09:01 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Tue Dec  5 11:56:55 2006
@@ -923,6 +923,17 @@
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void at91ether_poll_controller(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	at91ether_interrupt(dev->irq, dev);
+	local_irq_restore(flags);
+}
+#endif
+
 /*
  * Initialize the ethernet interface
  */
@@ -972,6 +983,9 @@
 	dev->set_mac_address = set_mac_address;
 	dev->ethtool_ops = &at91ether_ethtool_ops;
 	dev->do_ioctl = at91ether_ioctl;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = at91ether_poll_controller;
+#endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 



