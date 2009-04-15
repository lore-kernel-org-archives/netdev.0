From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 03/26] dm9000: convert to net_device_ops
Date: Thu, 16 Apr 2009 02:52:37 +0400
Message-ID: <1239835980-22502-3-git-send-email-a.beregalov@gmail.com>
References: <1239835980-22502-1-git-send-email-a.beregalov@gmail.com>
 <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53404 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbZDOWxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 18:53:06 -0400
Received: by fxm2 with SMTP id 2so121391fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:53:05 -0700 (PDT)
In-Reply-To: <1239835980-22502-2-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/dm9000.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index d835086..e402e91 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1170,6 +1170,21 @@ dm9000_stop(struct net_device *ndev)
 	return 0;
 }
 
+static const struct net_device_ops dm9000_netdev_ops = {
+	.ndo_open		= dm9000_open,
+	.ndo_stop		= dm9000_stop,
+	.ndo_start_xmit		= dm9000_start_xmit,
+	.ndo_tx_timeout		= dm9000_timeout,
+	.ndo_set_multicast_list	= dm9000_hash_table,
+	.ndo_do_ioctl		= dm9000_ioctl,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= dm9000_poll_controller,
+#endif
+};
+
 #define res_size(_r) (((_r)->end - (_r)->start) + 1)
 
 /*
@@ -1339,18 +1354,9 @@ dm9000_probe(struct platform_device *pdev)
 	/* driver system function */
 	ether_setup(ndev);
 
-	ndev->open		 = &dm9000_open;
-	ndev->hard_start_xmit    = &dm9000_start_xmit;
-	ndev->tx_timeout         = &dm9000_timeout;
-	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	ndev->stop		 = &dm9000_stop;
-	ndev->set_multicast_list = &dm9000_hash_table;
-	ndev->ethtool_ops	 = &dm9000_ethtool_ops;
-	ndev->do_ioctl		 = &dm9000_ioctl;
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller	 = &dm9000_poll_controller;
-#endif
+	ndev->netdev_ops	= &dm9000_netdev_ops;
+	ndev->watchdog_timeo	= msecs_to_jiffies(watchdog);
+	ndev->ethtool_ops	= &dm9000_ethtool_ops;
 
 	db->msg_enable       = NETIF_MSG_LINK;
 	db->mii.phy_id_mask  = 0x1f;
-- 
1.6.2.3

