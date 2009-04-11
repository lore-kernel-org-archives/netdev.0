From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 07/11] macb: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:42:26 +0400
Message-ID: <20090411174226.GG16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:50886 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZDKRmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:42:33 -0400
Received: by an-out-0708.google.com with SMTP id d14so1350385and.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:42:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/macb.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f505010..46073de 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1100,6 +1100,18 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, if_mii(rq), cmd);
 }
 
+static const struct net_device_ops macb_netdev_ops = {
+	.ndo_open		= macb_open,
+	.ndo_stop		= macb_close,
+	.ndo_start_xmit		= macb_start_xmit,
+	.ndo_set_multicast_list	= macb_set_rx_mode,
+	.ndo_get_stats		= macb_get_stats,
+	.ndo_do_ioctl		= macb_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init macb_probe(struct platform_device *pdev)
 {
 	struct eth_platform_data *pdata;
@@ -1175,12 +1187,7 @@ static int __init macb_probe(struct platform_device *pdev)
 		goto err_out_iounmap;
 	}
 
-	dev->open = macb_open;
-	dev->stop = macb_close;
-	dev->hard_start_xmit = macb_start_xmit;
-	dev->get_stats = macb_get_stats;
-	dev->set_multicast_list = macb_set_rx_mode;
-	dev->do_ioctl = macb_ioctl;
+	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
 
