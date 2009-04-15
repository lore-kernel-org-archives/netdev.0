From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 4/5] bfin_mac: convert to net_device_ops
Date: Wed, 15 Apr 2009 08:30:24 +0400
Message-ID: <1239769825-12413-4-git-send-email-a.beregalov@gmail.com>
References: <1239769825-12413-1-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-2-git-send-email-a.beregalov@gmail.com>
 <1239769825-12413-3-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:43042 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbZDOEai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:30:38 -0400
Received: by mail-fx0-f158.google.com with SMTP id 2so2713444fxm.37
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 21:30:37 -0700 (PDT)
In-Reply-To: <1239769825-12413-3-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/bfin_mac.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 9afe809..9326aef 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -979,6 +979,20 @@ static int bfin_mac_open(struct net_device *dev)
 	return 0;
 }
 
+static const struct net_device_ops bfin_mac_netdev_ops = {
+	.ndo_open		= bfin_mac_open,
+	.ndo_stop		= bfin_mac_close,
+	.ndo_start_xmit		= bfin_mac_hard_start_xmit,
+	.ndo_set_mac_address	= bfin_mac_set_mac_address,
+	.ndo_tx_timeout		= bfin_mac_timeout,
+	.ndo_set_multicast_list	= bfin_mac_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= bfin_mac_poll,
+#endif
+};
+
 /*
  *
  * this makes the board clean up everything that it can
@@ -1086,15 +1100,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	/* Fill in the fields of the device structure with ethernet values. */
 	ether_setup(ndev);
 
-	ndev->open = bfin_mac_open;
-	ndev->stop = bfin_mac_close;
-	ndev->hard_start_xmit = bfin_mac_hard_start_xmit;
-	ndev->set_mac_address = bfin_mac_set_mac_address;
-	ndev->tx_timeout = bfin_mac_timeout;
-	ndev->set_multicast_list = bfin_mac_set_multicast_list;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	ndev->poll_controller = bfin_mac_poll;
-#endif
+	ndev->netdev_ops = &bfin_mac_netdev_ops;
 	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
 
 	spin_lock_init(&lp->lock);
-- 
1.6.2.3

