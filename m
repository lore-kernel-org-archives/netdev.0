From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 09/11] isa-skeleton: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:44:06 +0400
Message-ID: <20090411174406.GI16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:21924 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757966AbZDKRoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:44:14 -0400
Received: by an-out-0708.google.com with SMTP id d14so1350769and.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:44:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/isa-skeleton.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 3126678..73585fd 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -181,6 +181,18 @@ out:
 }
 #endif
 
+static const struct net_device_ops netcard_netdev_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_start_xmit		= net_send_packet,
+	.ndo_get_stats		= net_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_tx_timeout		= net_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 /*
  * This is the real probe routine. Linux has a history of friendly device
  * probes on the ISA bus. A good device probes avoids doing writes, and
@@ -303,13 +315,7 @@ static int __init netcard_probe1(struct net_device *dev, int ioaddr)
 	np = netdev_priv(dev);
 	spin_lock_init(&np->lock);
 
-	dev->open		= net_open;
-	dev->stop		= net_close;
-	dev->hard_start_xmit	= net_send_packet;
-	dev->get_stats		= net_get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-
-        dev->tx_timeout		= &net_tx_timeout;
+        dev->netdev_ops		= &netcard_netdev_ops;
         dev->watchdog_timeo	= MY_TX_TIMEOUT;
 
 	err = register_netdev(dev);
