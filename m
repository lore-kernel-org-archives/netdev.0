From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/77] irda: convert vlsi driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:41 -0700
Message-ID: <20090321053713.605552151@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36571 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760842AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-vlsi.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/irda/vlsi_ir.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- a/drivers/net/irda/vlsi_ir.c	2009-03-19 22:40:30.270902366 -0700
+++ b/drivers/net/irda/vlsi_ir.c	2009-03-19 22:42:50.764027628 -0700
@@ -1573,6 +1573,14 @@ static int vlsi_close(struct net_device 
 	return 0;
 }
 
+static const struct net_device_ops vlsi_netdev_ops = {
+	.ndo_open       = vlsi_open,
+	.ndo_stop       = vlsi_close,
+	.ndo_start_xmit = vlsi_hard_start_xmit,
+	.ndo_do_ioctl   = vlsi_ioctl,
+	.ndo_tx_timeout = vlsi_tx_timeout,
+};
+
 static int vlsi_irda_init(struct net_device *ndev)
 {
 	vlsi_irda_dev_t *idev = netdev_priv(ndev);
@@ -1608,11 +1616,7 @@ static int vlsi_irda_init(struct net_dev
 	ndev->flags |= IFF_PORTSEL | IFF_AUTOMEDIA;
 	ndev->if_port = IF_PORT_UNKNOWN;
  
-	ndev->open	      = vlsi_open;
-	ndev->stop	      = vlsi_close;
-	ndev->hard_start_xmit = vlsi_hard_start_xmit;
-	ndev->do_ioctl	      = vlsi_ioctl;
-	ndev->tx_timeout      = vlsi_tx_timeout;
+	ndev->netdev_ops = &vlsi_netdev_ops;
 	ndev->watchdog_timeo  = 500*HZ/1000;	/* max. allowed turn time for IrLAP */
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);

-- 

