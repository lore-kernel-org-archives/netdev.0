From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] etherh: build fix for net-next
Date: Tue, 2 Dec 2008 07:58:50 -0800
Message-ID: <20081202075850.036421a2@extreme>
References: <20081201212931.GB18511@flint.arm.linux.org.uk>
	<20081201153030.235a8c84@extreme>
	<4934B7B5.9010004@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell King <rmk@arm.linux.org.uk>, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44911 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbYLBP6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 10:58:54 -0500
In-Reply-To: <4934B7B5.9010004@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix build of ARM etherh driver with new net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/arm/etherh.c	2008-12-01 15:24:01.000000000 -0800
+++ b/drivers/net/arm/etherh.c	2008-12-01 15:27:32.000000000 -0800
@@ -637,6 +637,21 @@ static const struct ethtool_ops etherh_e
 	.get_drvinfo	= etherh_get_drvinfo,
 };
 
+static const struct net_device_ops etherh_netdev_ops = {
+	.ndo_open		= etherh_open,
+	.ndo_stop		= etherh_close,
+	.ndo_set_config		= etherh_set_config,
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ei_poll,
+#endif
+};
+
 static u32 etherh_regoffsets[16];
 static u32 etherm_regoffsets[16];
 
@@ -663,9 +678,7 @@ etherh_probe(struct expansion_card *ec, 
 
 	SET_NETDEV_DEV(dev, &ec->dev);
 
-	dev->open		= etherh_open;
-	dev->stop		= etherh_close;
-	dev->set_config		= etherh_set_config;
+	dev->netdev_ops		= &etherh_netdev_ops;
 	dev->irq		= ec->irq;
 	dev->ethtool_ops	= &etherh_ethtool_ops;
 
--- a/drivers/net/arm/Makefile	2008-12-02 07:48:13.000000000 -0800
+++ b/drivers/net/arm/Makefile	2008-12-02 07:48:56.000000000 -0800
@@ -4,7 +4,7 @@
 #
 
 obj-$(CONFIG_ARM_AM79C961A)	+= am79c961a.o
-obj-$(CONFIG_ARM_ETHERH)	+= etherh.o
+obj-$(CONFIG_ARM_ETHERH)	+= etherh.o ../8390.o
 obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
