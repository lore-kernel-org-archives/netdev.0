From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 19/30] netdev: ibmlana convert to net_device_ops
Date: Thu, 26 Mar 2009 18:11:33 -0700
Message-ID: <20090327011256.318547048@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49177 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763149AbZC0Bba (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:31:30 -0400
Content-Disposition: inline; filename=ibmlana.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ibmlana.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/ibmlana.c	2009-03-26 16:13:19.166599803 -0700
@@ -905,6 +905,17 @@ static char *ibmlana_adapter_names[] __d
 	NULL
 };
 
+
+static const struct net_device_ops ibmlana_netdev_ops = {
+	.ndo_open 		= ibmlana_open,
+	.ndo_stop 		= ibmlana_close,
+	.ndo_start_xmit		= ibmlana_tx,
+	.ndo_set_multicast_list = ibmlana_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __devinit ibmlana_init_one(struct device *kdev)
 {
 	struct mca_device *mdev = to_mca_device(kdev);
@@ -973,11 +984,7 @@ static int __devinit ibmlana_init_one(st
 	mca_device_set_claim(mdev, 1);
 
 	/* set methods */
-
-	dev->open = ibmlana_open;
-	dev->stop = ibmlana_close;
-	dev->hard_start_xmit = ibmlana_tx;
-	dev->set_multicast_list = ibmlana_set_multicast_list;
+	dev->netdev_ops = &ibmlana_netdev_ops;
 	dev->flags |= IFF_MULTICAST;
 
 	/* copy out MAC address */


