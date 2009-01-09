From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 09/45] rose: convert to network_device_ops
Date: Fri, 09 Jan 2009 15:01:06 -0800
Message-ID: <20090109230137.377073273@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44995 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932826AbZAIXW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:22:57 -0500
Content-Disposition: inline; filename=rose-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/rose/rose_dev.c	2009-01-09 13:39:57.000000000 -0800
+++ b/net/rose/rose_dev.c	2009-01-09 13:40:29.000000000 -0800
@@ -149,18 +149,22 @@ static const struct header_ops rose_head
 	.rebuild= rose_rebuild_header,
 };
 
+static const struct net_device_ops rose_netdev_ops = {
+	.ndo_open		= rose_open,
+	.ndo_stop		= rose_close,
+	.ndo_start_xmit		= rose_xmit,
+	.ndo_set_mac_address    = rose_set_mac_address,
+};
+
 void rose_setup(struct net_device *dev)
 {
 	dev->mtu		= ROSE_MAX_PACKET_SIZE - 2;
-	dev->hard_start_xmit	= rose_xmit;
-	dev->open		= rose_open;
-	dev->stop		= rose_close;
+	dev->netdev_ops		= &rose_netdev_ops;
 
 	dev->header_ops		= &rose_header_ops;
 	dev->hard_header_len	= AX25_BPQ_HEADER_LEN + AX25_MAX_HEADER_LEN + ROSE_MIN_LEN;
 	dev->addr_len		= ROSE_ADDR_LEN;
 	dev->type		= ARPHRD_ROSE;
-	dev->set_mac_address    = rose_set_mac_address;
 
 	/* New-style flags. */
 	dev->flags		= IFF_NOARP;


