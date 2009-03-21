From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 51/77] labether: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:36:18 -0700
Message-ID: <20090321053716.425005688@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36661 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761018AbZCUFsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:19 -0400
Content-Disposition: inline; filename=lapbether.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/lapbether.c	2009-03-20 22:04:49.754653610 -0700
+++ b/drivers/net/wan/lapbether.c	2009-03-20 22:05:47.163652939 -0700
@@ -303,13 +303,17 @@ static int lapbeth_close(struct net_devi
 
 /* ------------------------------------------------------------------------ */
 
+static const struct net_device_ops lapbeth_netdev_ops = {
+	.ndo_open	     = lapbeth_open,
+	.ndo_stop	     = lapbeth_close,
+	.ndo_start_xmit	     = lapbeth_xmit,
+	.ndo_set_mac_address = lapbeth_set_mac_address,
+};
+
 static void lapbeth_setup(struct net_device *dev)
 {
-	dev->hard_start_xmit = lapbeth_xmit;
-	dev->open	     = lapbeth_open;
-	dev->stop	     = lapbeth_close;
+	dev->netdev_ops	     = &lapbeth_netdev_ops;
 	dev->destructor	     = free_netdev;
-	dev->set_mac_address = lapbeth_set_mac_address;
 	dev->type            = ARPHRD_X25;
 	dev->hard_header_len = 3;
 	dev->mtu             = 1000;

-- 

