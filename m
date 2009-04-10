From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 6/6] ether3: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:29:38 +0400
Message-ID: <20090410032938.GD29233@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:60644 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761929AbZDJD3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:29:43 -0400
Received: by fg-out-1718.google.com with SMTP id e12so282026fga.17
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:29:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/arm/ether3.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
index 21a7bef..ec8a1ae 100644
--- a/drivers/net/arm/ether3.c
+++ b/drivers/net/arm/ether3.c
@@ -770,6 +770,18 @@ static void __devinit ether3_banner(void)
 		printk(KERN_INFO "%s", version);
 }
 
+static const struct net_device_ops ether3_netdev_ops = {
+	.ndo_open		= ether3_open,
+	.ndo_stop		= ether3_close,
+	.ndo_start_xmit		= ether3_sendpacket,
+	.ndo_get_stats		= ether3_getstats,
+	.ndo_set_multicast_list	= ether3_setmulticastlist,
+	.ndo_tx_timeout		= ether3_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __devinit
 ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
@@ -846,12 +858,7 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto free;
 	}
 
-	dev->open		= ether3_open;
-	dev->stop		= ether3_close;
-	dev->hard_start_xmit	= ether3_sendpacket;
-	dev->get_stats		= ether3_getstats;
-	dev->set_multicast_list	= ether3_setmulticastlist;
-	dev->tx_timeout		= ether3_timeout;
+	dev->netdev_ops		= &ether3_netdev_ops;
 	dev->watchdog_timeo	= 5 * HZ / 100;
 
 	ret = register_netdev(dev);
