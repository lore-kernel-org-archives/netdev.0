From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 05/30] To: acme@ghostprotocols.net Subjetct: appltetalk: convert cops device to net_device ops
Date: Thu, 26 Mar 2009 18:11:19 -0700
Message-ID: <20090327011255.312373568@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39805 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753857AbZC0BXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:23:48 -0400
Content-Disposition: inline; filename=cops-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/appletalk/cops.c	2009-03-22 21:19:10.000000000 -0700
+++ b/drivers/net/appletalk/cops.c	2009-03-22 23:12:17.941522246 -0700
@@ -258,6 +258,15 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops cops_netdev_ops = {
+	.ndo_open               = cops_open,
+        .ndo_stop               = cops_close,
+	.ndo_start_xmit   	= cops_send_packet,
+	.ndo_tx_timeout		= cops_timeout,
+        .ndo_do_ioctl           = cops_ioctl,
+	.ndo_set_multicast_list = set_multicast_list,
+};
+
 /*
  *      This is the real probe routine. Linux has a history of friendly device
  *      probes on the ISA bus. A good device probes avoids doing writes, and
@@ -331,15 +340,9 @@ static int __init cops_probe1(struct net
 	/* Copy local board variable to lp struct. */
 	lp->board               = board;
 
-	dev->hard_start_xmit    = cops_send_packet;
-	dev->tx_timeout		= cops_timeout;
+	dev->netdev_ops 	= &cops_netdev_ops;
 	dev->watchdog_timeo	= HZ * 2;
 
-	dev->open               = cops_open;
-        dev->stop               = cops_close;
-        dev->do_ioctl           = cops_ioctl;
-	dev->set_multicast_list = set_multicast_list;
-        dev->mc_list            = NULL;
 
 	/* Tell the user where the card is and what mode we're in. */
 	if(board==DAYNA)


