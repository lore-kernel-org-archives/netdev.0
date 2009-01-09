From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 05/45] lec: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:02 -0800
Message-ID: <20090109230137.077316321@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42308 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304AbZAIXSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:15 -0500
Content-Disposition: inline; filename=lec-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/atm/lec.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

--- a/net/atm/lec.c	2009-01-09 10:15:14.000000000 -0800
+++ b/net/atm/lec.c	2009-01-09 10:15:23.000000000 -0800
@@ -667,17 +667,19 @@ static void lec_set_multicast_list(struc
 	return;
 }
 
+static const struct net_device_ops lec_netdev_ops = {
+	.ndo_open		= lec_open,
+	.ndo_stop		= lec_close,
+	.ndo_start_xmit		= lec_start_xmit,
+	.ndo_change_mtu		= lec_change_mtu,
+	.ndo_tx_timeout		= lec_tx_timeout,
+	.ndo_set_multicast_list	= lec_set_multicast_list,
+};
+
+
 static void lec_init(struct net_device *dev)
 {
-	dev->change_mtu = lec_change_mtu;
-	dev->open = lec_open;
-	dev->stop = lec_close;
-	dev->hard_start_xmit = lec_start_xmit;
-	dev->tx_timeout = lec_tx_timeout;
-
-	dev->get_stats = lec_get_stats;
-	dev->set_multicast_list = lec_set_multicast_list;
-	dev->do_ioctl = NULL;
+	dev->netdev_ops = &lec_netdev_ops;
 	printk("%s: Initialized!\n", dev->name);
 }
 


