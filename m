From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.19] AT91RM9200 Ethernet update 2
Date: 04 Dec 2006 14:42:08 +0200
Message-ID: <1165236128.4606.104.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:10 "EHLO
	za-gw.sanpeople.com") by vger.kernel.org with ESMTP id S936572AbWLDMvy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 07:51:54 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds NetPoll / NetConsole support to the Atmel AT91RM9200
Ethernet driver.

Original patch from Bill Gatliff.


Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
--- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Mon Dec  4 14:27:21 2006
+++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:33:35 2006
@@ -925,6 +925,17 @@
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void at91ether_poll_controller(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	at91ether_interrupt(dev->irq, dev, NULL);
+	local_irq_restore(flags);
+}
+#endif
+
 /*
  * Initialize the ethernet interface
  */
@@ -974,6 +985,9 @@
 	dev->set_mac_address = set_mac_address;
 	dev->ethtool_ops = &at91ether_ethtool_ops;
 	dev->do_ioctl = at91ether_ioctl;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = at91ether_poll_controller;
+#endif
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 



