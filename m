From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 15/42] hp100: update to net_device_ops
Date: Wed, 7 Jan 2009 17:48:58 -0800
Message-ID: <20090107174858.246c439f@extreme>
References: <20090107003316.784424362@vyatta.com>
	<20090107003347.155432544@vyatta.com>
	<20090107.173520.104922004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41236 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbZAHBtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 20:49:01 -0500
In-Reply-To: <20090107.173520.104922004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hp100.c	2009-01-06 15:51:25.736859949 -0800
+++ b/drivers/net/hp100.c	2009-01-06 16:04:57.553361920 -0800
@@ -425,6 +425,28 @@ struct net_device * __init hp100_probe(i
 }
 #endif /* !MODULE && CONFIG_ISA */
 
+static const struct net_device_ops hp100_bm_netdev_ops = {
+	.ndo_open		= hp100_open,
+	.ndo_stop		= hp100_close,
+	.ndo_start_xmit		= hp100_start_xmit_bm,
+	.ndo_get_stats 		= hp100_get_stats,
+	.ndo_set_multicast_list = hp100_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+static const struct net_device_ops hp100_netdev_ops = {
+	.ndo_open		= hp100_open,
+	.ndo_stop		= hp100_close,
+	.ndo_start_xmit		= hp100_start_xmit,
+	.ndo_get_stats 		= hp100_get_stats,
+	.ndo_set_multicast_list = hp100_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit hp100_probe1(struct net_device *dev, int ioaddr,
 				  u_char bus, struct pci_dev *pci_dev)
 {
@@ -657,16 +679,10 @@ static int __devinit hp100_probe1(struct
 	lp->virt_memory_size = virt_memory_size;
 	lp->rx_ratio = hp100_rx_ratio;	/* can be conf'd with insmod */
 
-	dev->open = hp100_open;
-	dev->stop = hp100_close;
-
 	if (lp->mode == 1)	/* busmaster */
-		dev->hard_start_xmit = hp100_start_xmit_bm;
+		dev->netdev_ops = &hp100_bm_netdev_ops;
 	else
-		dev->hard_start_xmit = hp100_start_xmit;
-
-	dev->get_stats = hp100_get_stats;
-	dev->set_multicast_list = &hp100_set_multicast_list;
+		dev->netdev_ops = &hp100_netdev_ops;
 
 	/* Ask the card for which IRQ line it is configured */
 	if (bus == HP100_BUS_PCI) {
