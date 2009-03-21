From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 17/77] irda: convert sir device to net_device_ops
Date: Fri, 20 Mar 2009 22:35:44 -0700
Message-ID: <20090321053713.827044480@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36561 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760799AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-sir.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/irda/sir_dev.c	2009-03-19 22:52:52.826089334 -0700
+++ b/drivers/net/irda/sir_dev.c	2009-03-19 23:09:32.268774083 -0700
@@ -865,6 +865,12 @@ out:
 	return 0;
 }
 
+static const struct net_device_ops sirdev_ops = {
+	.ndo_start_xmit	= sirdev_hard_xmit,
+	.ndo_open	= sirdev_open,
+	.ndo_stop	= sirdev_close,
+	.ndo_do_ioctl	= sirdev_ioctl,
+};
 /* ----------------------------------------------------------------------------- */
 
 struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *name)
@@ -908,10 +914,7 @@ struct sir_dev * sirdev_get_instance(con
 	dev->netdev = ndev;
 
 	/* Override the network functions we need to use */
-	ndev->hard_start_xmit = sirdev_hard_xmit;
-	ndev->open = sirdev_open;
-	ndev->stop = sirdev_close;
-	ndev->do_ioctl = sirdev_ioctl;
+	ndev->netdev_ops = &sirdev_ops;
 
 	if (register_netdev(ndev)) {
 		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);

-- 

