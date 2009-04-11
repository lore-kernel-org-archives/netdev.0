From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 08/11] mac89x0: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:43:11 +0400
Message-ID: <20090411174311.GH16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:21255 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbZDKRnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:43:21 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1586548ywb.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:43:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/mac89x0.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 380a1a5..384e072 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -168,6 +168,17 @@ writereg(struct net_device *dev, int portno, int value)
 	nubus_writew(swab16(value), dev->mem_start + portno);
 }
 
+static const struct net_device_ops mac89x0_netdev_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_start_xmit		= net_send_packet,
+	.ndo_get_stats		= net_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_set_mac_address	= set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 /* Probe for the CS8900 card in slot E.  We won't bother looking
    anywhere else until we have a really good reason to do so. */
 struct net_device * __init mac89x0_probe(int unit)
@@ -280,12 +291,7 @@ struct net_device * __init mac89x0_probe(int unit)
 
 	printk(" IRQ %d ADDR %pM\n", dev->irq, dev->dev_addr);
 
-	dev->open		= net_open;
-	dev->stop		= net_close;
-	dev->hard_start_xmit = net_send_packet;
-	dev->get_stats	= net_get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->set_mac_address = &set_mac_address;
+	dev->netdev_ops		= &mac89x0_netdev_ops;
 
 	err = register_netdev(dev);
 	if (err)
