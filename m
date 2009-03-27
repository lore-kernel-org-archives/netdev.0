From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 10/30] tokenring: convert smctr to net_device_ops
Date: Thu, 26 Mar 2009 18:11:24 -0700
Message-ID: <20090327011255.674425030@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43178 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755906AbZC0B0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:26:38 -0400
Content-Disposition: inline; filename=smctr-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tokenring/smctr.c	2009-03-26 17:14:05.068620940 -0700
+++ b/drivers/net/tokenring/smctr.c	2009-03-26 17:14:08.818621219 -0700
@@ -124,7 +124,6 @@ static unsigned int smctr_get_num_rx_bdb
 static int smctr_get_physical_drop_number(struct net_device *dev);
 static __u8 *smctr_get_rx_pointer(struct net_device *dev, short queue);
 static int smctr_get_station_id(struct net_device *dev);
-static struct net_device_stats *smctr_get_stats(struct net_device *dev);
 static FCBlock *smctr_get_tx_fcb(struct net_device *dev, __u16 queue,
         __u16 bytes_count);
 static int smctr_get_upstream_neighbor_addr(struct net_device *dev);
@@ -3633,6 +3632,14 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops smctr_netdev_ops = {
+	.ndo_open          = smctr_open,
+	.ndo_stop          = smctr_close,
+	.ndo_start_xmit    = smctr_send_packet,
+	.ndo_tx_timeout	   = smctr_timeout,
+	.ndo_get_stats     = smctr_get_stats,
+	.ndo_set_multicast_list = smctr_set_multicast_list,
+};
 
 static int __init smctr_probe1(struct net_device *dev, int ioaddr)
 {
@@ -3683,13 +3690,8 @@ static int __init smctr_probe1(struct ne
                 (unsigned int)dev->base_addr,
                 dev->irq, tp->rom_base, tp->ram_base);
 
-        dev->open               = smctr_open;
-        dev->stop               = smctr_close;
-        dev->hard_start_xmit    = smctr_send_packet;
-        dev->tx_timeout		= smctr_timeout;
+	dev->netdev_ops = &smctr_netdev_ops;
         dev->watchdog_timeo	= HZ;
-        dev->get_stats          = smctr_get_stats;
-        dev->set_multicast_list = &smctr_set_multicast_list;
         return (0);
 
 out:


