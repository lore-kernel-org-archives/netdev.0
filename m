From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 5/6] ether1: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:28:55 +0400
Message-ID: <20090410032855.GC29233@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:61783 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935097AbZDJD3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:29:00 -0400
Received: by fg-out-1718.google.com with SMTP id 16so781889fgg.17
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:28:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/arm/ether1.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
index e380de4..edf770f 100644
--- a/drivers/net/arm/ether1.c
+++ b/drivers/net/arm/ether1.c
@@ -991,6 +991,18 @@ static void __devinit ether1_banner(void)
 		printk(KERN_INFO "%s", version);
 }
 
+static const struct net_device_ops ether1_netdev_ops = {
+	.ndo_open		= ether1_open,
+	.ndo_stop		= ether1_close,
+	.ndo_start_xmit		= ether1_sendpacket,
+	.ndo_get_stats		= ether1_getstats,
+	.ndo_set_multicast_list	= ether1_setmulticastlist,
+	.ndo_tx_timeout		= ether1_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __devinit
 ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 {
@@ -1031,12 +1043,7 @@ ether1_probe(struct expansion_card *ec, const struct ecard_id *id)
 		goto free;
 	}
 
-	dev->open		= ether1_open;
-	dev->stop		= ether1_close;
-	dev->hard_start_xmit    = ether1_sendpacket;
-	dev->get_stats		= ether1_getstats;
-	dev->set_multicast_list = ether1_setmulticastlist;
-	dev->tx_timeout		= ether1_timeout;
+	dev->netdev_ops		= &ether1_netdev_ops;
 	dev->watchdog_timeo	= 5 * HZ / 100;
 
 	ret = register_netdev(dev);
