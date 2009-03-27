From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 14/30] netdev: seeq8005 convert to net_device_ops
Date: Thu, 26 Mar 2009 18:11:28 -0700
Message-ID: <20090327011255.959142292@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:43192 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757395AbZC0B27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:28:59 -0400
Content-Disposition: inline; filename=seeq8005-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/seeq8005.c	2009-03-26 15:57:02.853605485 -0700
+++ b/drivers/net/seeq8005.c	2009-03-26 15:57:26.453599758 -0700
@@ -143,6 +143,17 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops seeq8005_netdev_ops = {
+	.ndo_open		= seeq8005_open,
+	.ndo_stop		= seeq8005_close,
+	.ndo_start_xmit 	= seeq8005_send_packet,
+	.ndo_tx_timeout		= seeq8005_timeout,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* This is the real probe routine.  Linux has a history of friendly device
    probes on the ISA bus.  A good device probes avoids doing writes, and
    verifies that the correct device exists and functions.  */
@@ -332,12 +343,8 @@ static int __init seeq8005_probe1(struct
 		 }
 	}
 #endif
-	dev->open		= seeq8005_open;
-	dev->stop		= seeq8005_close;
-	dev->hard_start_xmit 	= seeq8005_send_packet;
-	dev->tx_timeout		= seeq8005_timeout;
+	dev->netdev_ops = &seeq8005_netdev_ops;
 	dev->watchdog_timeo	= HZ/20;
-	dev->set_multicast_list = set_multicast_list;
 	dev->flags &= ~IFF_MULTICAST;
 
 	return 0;


