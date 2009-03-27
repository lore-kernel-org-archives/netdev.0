From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 21/30] netdev: convert eexpro to net_device_ops
Date: Thu, 26 Mar 2009 18:11:35 -0700
Message-ID: <20090327011256.459760386@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49183 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763151AbZC0Bcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:32:32 -0400
Content-Disposition: inline; filename=eepro.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/eepro.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/eepro.c	2009-03-26 16:32:54.922349626 -0700
@@ -739,6 +739,17 @@ static void __init eepro_print_info (str
 
 static const struct ethtool_ops eepro_ethtool_ops;
 
+static const struct net_device_ops eepro_netdev_ops = {
+ 	.ndo_open               = eepro_open,
+ 	.ndo_stop               = eepro_close,
+ 	.ndo_start_xmit    	= eepro_send_packet,
+ 	.ndo_set_multicast_list = set_multicast_list,
+ 	.ndo_tx_timeout		= eepro_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* This is the real probe routine.  Linux has a history of friendly device
    probes on the ISA bus.  A good device probe avoids doing writes, and
    verifies that the correct device exists and functions.  */
@@ -851,11 +862,7 @@ static int __init eepro_probe1(struct ne
  		}
  	}
 
- 	dev->open               = eepro_open;
- 	dev->stop               = eepro_close;
- 	dev->hard_start_xmit    = eepro_send_packet;
- 	dev->set_multicast_list = &set_multicast_list;
- 	dev->tx_timeout		= eepro_tx_timeout;
+	dev->netdev_ops		= &eepro_netdev_ops;
  	dev->watchdog_timeo	= TX_TIMEOUT;
 	dev->ethtool_ops	= &eepro_ethtool_ops;
 


