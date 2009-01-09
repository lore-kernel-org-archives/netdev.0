From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 42/45] scc: convert to internal net_device_ops
Date: Fri, 09 Jan 2009 15:01:39 -0800
Message-ID: <20090109230139.849953696@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, klaus.kudielka@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42284 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855AbZAIXSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:12 -0500
Content-Disposition: inline; filename=scc-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/hamradio/scc.c	2009-01-08 08:30:11.000000000 -0800
+++ b/drivers/net/hamradio/scc.c	2009-01-08 15:23:35.000000000 -0800
@@ -1542,23 +1542,24 @@ static int scc_net_alloc(const char *nam
 /* *			    Network driver methods		      * */
 /* ******************************************************************** */
 
+static const struct net_device_ops scc_netdev_ops = {
+	.ndo_open            = scc_net_open,
+	.ndo_stop	     = scc_net_close,
+	.ndo_start_xmit	     = scc_net_tx,
+	.ndo_set_mac_address = scc_net_set_mac_address,
+	.ndo_get_stats       = scc_net_get_stats,
+	.ndo_do_ioctl        = scc_net_ioctl,
+};
+
 /* ----> Initialize device <----- */
 
 static void scc_net_setup(struct net_device *dev)
 {
 	dev->tx_queue_len    = 16;	/* should be enough... */
 
-	dev->open            = scc_net_open;
-	dev->stop	     = scc_net_close;
-
-	dev->hard_start_xmit = scc_net_tx;
+	dev->netdev_ops	     = &scc_netdev_ops;
 	dev->header_ops      = &ax25_header_ops;
 
-	dev->set_mac_address = scc_net_set_mac_address;
-	dev->get_stats       = scc_net_get_stats;
-	dev->do_ioctl        = scc_net_ioctl;
-	dev->tx_timeout      = NULL;
-
 	memcpy(dev->broadcast, &ax25_bcast,  AX25_ADDR_LEN);
 	memcpy(dev->dev_addr,  &ax25_defaddr, AX25_ADDR_LEN);
  


