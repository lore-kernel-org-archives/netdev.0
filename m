From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] netiucv: convert to net_device_ops
Date: Fri, 09 Jan 2009 10:01:59 +0100
Message-ID: <20090109090221.873883000@de.ibm.com>
References: <20090109090156.422658000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:57049 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbZAIJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 04:02:24 -0500
Content-Disposition: inline; filename=netiucv_devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

netiucv convert to net_device_ops.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/netiucv.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/netiucv.c
===================================================================
--- git_linus.orig/drivers/s390/net/netiucv.c
+++ git_linus/drivers/s390/net/netiucv.c
@@ -1876,20 +1876,24 @@ static void netiucv_free_netdevice(struc
 /**
  * Initialize a net device. (Called from kernel in alloc_netdev())
  */
+static struct net_device_ops netiucv_netdev_ops = {
+	.ndo_open		= netiucv_open,
+	.ndo_stop		= netiucv_close,
+	.ndo_get_stats		= netiucv_stats,
+	.ndo_start_xmit		= netiucv_tx,
+	.ndo_change_mtu	   	= netiucv_change_mtu,
+};
+
 static void netiucv_setup_netdevice(struct net_device *dev)
 {
 	dev->mtu	         = NETIUCV_MTU_DEFAULT;
-	dev->hard_start_xmit     = netiucv_tx;
-	dev->open	         = netiucv_open;
-	dev->stop	         = netiucv_close;
-	dev->get_stats	         = netiucv_stats;
-	dev->change_mtu          = netiucv_change_mtu;
 	dev->destructor          = netiucv_free_netdevice;
 	dev->hard_header_len     = NETIUCV_HDRLEN;
 	dev->addr_len            = 0;
 	dev->type                = ARPHRD_SLIP;
 	dev->tx_queue_len        = NETIUCV_QUEUELEN_DEFAULT;
 	dev->flags	         = IFF_POINTOPOINT | IFF_NOARP;
+	dev->netdev_ops		 = &netiucv_netdev_ops;
 }
 
 /**

-- 
