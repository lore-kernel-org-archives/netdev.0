From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 27/33] ppp: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:34 -0800
Message-ID: <20081117234357.086564129@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55111 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbYKRAAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:20 -0500
Content-Disposition: inline; filename=ppp-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to network device ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ppp_generic.c	2008-11-04 13:58:06.000000000 -0800
+++ b/drivers/net/ppp_generic.c	2008-11-17 13:22:34.000000000 -0800
@@ -971,8 +971,13 @@ ppp_net_ioctl(struct net_device *dev, st
 	return err;
 }
 
+static const struct net_device_ops ppp_netdev_ops = {
+	.do_ioctl = ppp_net_ioctl,
+};
+
 static void ppp_setup(struct net_device *dev)
 {
+	dev->netdev_ops = &ppp_netdev_ops;
 	dev->hard_header_len = PPP_HDRLEN;
 	dev->mtu = PPP_MTU;
 	dev->addr_len = 0;
@@ -2436,7 +2441,6 @@ ppp_create_interface(int unit, int *retp
 	dev->priv = ppp;
 
 	dev->hard_start_xmit = ppp_start_xmit;
-	dev->do_ioctl = ppp_net_ioctl;
 
 	ret = -EEXIST;
 	mutex_lock(&all_ppp_mutex);

-- 

