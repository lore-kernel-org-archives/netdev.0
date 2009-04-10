From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 2/6] am79c961a: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:25:25 +0400
Message-ID: <20090410032525.GB9004@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:40071 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762996AbZDJDZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:25:31 -0400
Received: by fg-out-1718.google.com with SMTP id e12so281745fga.17
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:25:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/arm/am79c961a.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 4bc6901..627bc75 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -665,6 +665,20 @@ static void __init am79c961_banner(void)
 	if (net_debug && version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
 }
+static const struct net_device_ops am79c961_netdev_ops = {
+	.ndo_open		= am79c961_open,
+	.ndo_stop		= am79c961_close,
+	.ndo_start_xmit		= am79c961_sendpacket,
+	.ndo_get_stats		= am79c961_getstats,
+	.ndo_set_multicast_list	= am79c961_setmulticastlist,
+	.ndo_tx_timeout		= am79c961_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= am79c961_poll_controller,
+#endif
+};
 
 static int __init am79c961_probe(struct platform_device *pdev)
 {
@@ -732,15 +746,7 @@ static int __init am79c961_probe(struct platform_device *pdev)
 	if (am79c961_hw_init(dev))
 		goto release;
 
-	dev->open		= am79c961_open;
-	dev->stop		= am79c961_close;
-	dev->hard_start_xmit	= am79c961_sendpacket;
-	dev->get_stats		= am79c961_getstats;
-	dev->set_multicast_list	= am79c961_setmulticastlist;
-	dev->tx_timeout		= am79c961_timeout;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller	= am79c961_poll_controller;
-#endif
+	dev->netdev_ops = &am79c961_netdev_ops;
 
 	ret = register_netdev(dev);
 	if (ret == 0) {
