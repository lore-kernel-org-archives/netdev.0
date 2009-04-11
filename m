From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 04/11] sun3_82586: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:39:58 +0400
Message-ID: <20090411173958.GD16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:25859 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbZDKRkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:40:04 -0400
Received: by qw-out-2122.google.com with SMTP id 8so1787466qwh.37
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:40:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/sun3_82586.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index e0d8477..a39c0b9 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -331,6 +331,18 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops sun3_82586_netdev_ops = {
+	.ndo_open		= sun3_82586_open,
+	.ndo_stop		= sun3_82586_close,
+	.ndo_start_xmit		= sun3_82586_send_packet,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_tx_timeout		= sun3_82586_timeout,
+	.ndo_get_stats		= sun3_82586_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
 {
 	int i, size, retval;
@@ -381,13 +393,8 @@ static int __init sun3_82586_probe1(struct net_device *dev,int ioaddr)
 
 	printk("Memaddr: 0x%lx, Memsize: %d, IRQ %d\n",dev->mem_start,size, dev->irq);
 
-	dev->open		= sun3_82586_open;
-	dev->stop		= sun3_82586_close;
-	dev->get_stats		= sun3_82586_get_stats;
-	dev->tx_timeout 	= sun3_82586_timeout;
+	dev->netdev_ops		= &sun3_82586_netdev_ops;
 	dev->watchdog_timeo	= HZ/20;
-	dev->hard_start_xmit 	= sun3_82586_send_packet;
-	dev->set_multicast_list = set_multicast_list;
 
 	dev->if_port 		= 0;
 	return 0;
