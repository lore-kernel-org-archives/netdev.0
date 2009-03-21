From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 53/77] sbni: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:20 -0700
Message-ID: <20090321053716.585899541@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36666 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754541AbZCUFsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:19 -0400
Content-Disposition: inline; filename=sbni-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/wan/sbni.c	2009-03-20 17:40:56.731776387 -0700
+++ b/drivers/net/wan/sbni.c	2009-03-20 17:43:13.322652142 -0700
@@ -206,15 +206,21 @@ sbni_isa_probe( struct net_device  *dev 
 	}
 }
 
+static const struct net_device_ops sbni_netdev_ops = {
+	.ndo_open		= sbni_open,
+	.ndo_stop		= sbni_close,
+	.ndo_start_xmit		= sbni_start_xmit,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_do_ioctl		= sbni_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static void __init sbni_devsetup(struct net_device *dev)
 {
 	ether_setup( dev );
-	dev->open		= &sbni_open;
-	dev->stop		= &sbni_close;
-	dev->hard_start_xmit	= &sbni_start_xmit;
-	dev->get_stats		= &sbni_get_stats;
-	dev->set_multicast_list	= &set_multicast_list;
-	dev->do_ioctl		= &sbni_ioctl;
+	dev->netdev_ops = &sbni_netdev_ops;
 }
 
 int __init sbni_probe(int unit)
@@ -227,6 +233,8 @@ int __init sbni_probe(int unit)
 	if (!dev)
 		return -ENOMEM;
 
+	dev->netdev_ops = &sbni_netdev_ops;
+
 	sprintf(dev->name, "sbni%d", unit);
 	netdev_boot_setup_check(dev);
 

-- 

