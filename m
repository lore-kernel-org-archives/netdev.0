From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 21/22] eql: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:59 -0800
Message-ID: <20081121232240.672345637@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57077 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755378AbYKUXXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:38 -0500
Content-Disposition: inline; filename=egl-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/eql.c	2008-11-21 14:57:44.000000000 -0800
+++ b/drivers/net/eql.c	2008-11-21 14:59:55.000000000 -0800
@@ -162,6 +162,13 @@ static void eql_timer(unsigned long para
 static char version[] __initdata =
 	"Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)\n";
 
+static const struct net_device_ops eql_netdev_ops = {
+	.ndo_open	= eql_open,
+	.ndo_stop	= eql_close,
+	.ndo_do_ioctl	= eql_ioctl,
+	.ndo_start_xmit	= eql_slave_xmit,
+};
+
 static void __init eql_setup(struct net_device *dev)
 {
 	equalizer_t *eql = netdev_priv(dev);
@@ -175,10 +182,7 @@ static void __init eql_setup(struct net_
 	INIT_LIST_HEAD(&eql->queue.all_slaves);
 	eql->queue.master_dev	= dev;
 
-	dev->open		= eql_open;
-	dev->stop		= eql_close;
-	dev->do_ioctl		= eql_ioctl;
-	dev->hard_start_xmit	= eql_slave_xmit;
+	dev->netdev_ops		= &eql_netdev_ops;
 
 	/*
 	 *	Now we undo some of the things that eth_setup does

-- 

