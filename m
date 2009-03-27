From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 15/30] netdev: smc9194 convert to net_device_ops
Date: Thu, 26 Mar 2009 18:11:29 -0700
Message-ID: <20090327011256.026692707@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49165 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757023AbZC0B33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:29:29 -0400
Content-Disposition: inline; filename=smc9194.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/smc9194.c	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/smc9194.c	2009-03-26 16:02:53.518387041 -0700
@@ -831,6 +831,17 @@ static int __init smc_findirq(int ioaddr
 #endif
 }
 
+static const struct net_device_ops smc_netdev_ops = {
+	.ndo_open		 = smc_open,
+	.ndo_stop		= smc_close,
+	.ndo_start_xmit    	= smc_wait_to_send_packet,
+	.ndo_tx_timeout	    	= smc_timeout,
+	.ndo_set_multicast_list	= smc_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*----------------------------------------------------------------------
  . Function: smc_probe( int ioaddr )
  .
@@ -1044,12 +1055,8 @@ static int __init smc_probe(struct net_d
   	  	goto err_out;
       	}
 
-	dev->open		        = smc_open;
-	dev->stop		        = smc_close;
-	dev->hard_start_xmit    	= smc_wait_to_send_packet;
-	dev->tx_timeout		    	= smc_timeout;
+	dev->netdev_ops			= &smc_netdev_ops;
 	dev->watchdog_timeo		= HZ/20;
-	dev->set_multicast_list 	= smc_set_multicast_list;
 
 	return 0;
 


