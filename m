From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 23/45] ibmtr: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:20 -0800
Message-ID: <20090109230138.406678573@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42211 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960AbZAIXR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:57 -0500
Content-Disposition: inline; filename=ibmtr-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tokenring/ibmtr.c	2009-01-09 13:54:29.000000000 -0800
+++ b/drivers/net/tokenring/ibmtr.c	2009-01-09 13:55:28.000000000 -0800
@@ -815,17 +815,21 @@ static unsigned char __devinit get_sram_
 
 /*****************************************************************************/
 
+static const struct net_device_ops trdev_netdev_ops = {
+	.ndo_open		= tok_open,
+	.ndo_stop		= tok_close,
+	.ndo_start_xmit		= tok_send_packet,
+	.ndo_set_multicast_list = tok_set_multicast_list,
+	.ndo_change_mtu		= ibmtr_change_mtu,
+};
+
 static int __devinit trdev_init(struct net_device *dev)
 {
 	struct tok_info *ti = netdev_priv(dev);
 
 	SET_PAGE(ti->srb_page);
         ti->open_failure = NO    ;
-	dev->open = tok_open;
-	dev->stop = tok_close;
-	dev->hard_start_xmit = tok_send_packet;
-	dev->set_multicast_list = tok_set_multicast_list;
-	dev->change_mtu = ibmtr_change_mtu;
+ 	dev->netdev_ops = &trdev_netdev_ops;
 
 	return 0;
 }


