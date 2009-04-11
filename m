From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 05/11] sh_eth: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:40:49 +0400
Message-ID: <20090411174049.GE16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:4523 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214AbZDKRk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:40:56 -0400
Received: by an-out-0708.google.com with SMTP id d14so1350034and.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:40:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/sh_eth.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 7b18827..3ab28bb 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1188,6 +1188,19 @@ out:
 	return ret;
 }
 
+static const struct net_device_ops sh_eth_netdev_ops = {
+	.ndo_open		= sh_eth_open,
+	.ndo_stop		= sh_eth_close,
+	.ndo_start_xmit		= sh_eth_start_xmit,
+	.ndo_get_stats		= sh_eth_get_stats,
+	.ndo_set_multicast_list	= sh_eth_set_multicast_list,
+	.ndo_tx_timeout		= sh_eth_tx_timeout,
+	.ndo_do_ioctl		= sh_eth_do_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
 static int sh_eth_drv_probe(struct platform_device *pdev)
 {
 	int ret, i, devno = 0;
@@ -1240,13 +1253,7 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	mdp->edmac_endian = pd->edmac_endian;
 
 	/* set function */
-	ndev->open = sh_eth_open;
-	ndev->hard_start_xmit = sh_eth_start_xmit;
-	ndev->stop = sh_eth_close;
-	ndev->get_stats = sh_eth_get_stats;
-	ndev->set_multicast_list = sh_eth_set_multicast_list;
-	ndev->do_ioctl = sh_eth_do_ioctl;
-	ndev->tx_timeout = sh_eth_tx_timeout;
+	ndev->netdev_ops = &sh_eth_netdev_ops;
 	ndev->watchdog_timeo = TX_TIMEOUT;
 
 	mdp->post_rx = POST_RX >> (devno << 1);
