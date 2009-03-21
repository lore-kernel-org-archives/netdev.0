From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/77] irda: convert irda_usb to net_device_ops
Date: Fri, 20 Mar 2009 22:35:35 -0700
Message-ID: <20090321053713.155535463@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36567 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760817AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-usb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/irda/irda-usb.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

--- a/drivers/net/irda/irda-usb.c	2009-03-19 22:40:30.429651929 -0700
+++ b/drivers/net/irda/irda-usb.c	2009-03-19 22:42:46.433089198 -0700
@@ -1401,6 +1401,14 @@ static inline void irda_usb_init_qos(str
 }
 
 /*------------------------------------------------------------------*/
+static const struct net_device_ops irda_usb_netdev_ops = {
+	.ndo_open       = irda_usb_net_open,
+	.ndo_stop       = irda_usb_net_close,
+	.ndo_do_ioctl   = irda_usb_net_ioctl,
+	.ndo_start_xmit = irda_usb_hard_xmit,
+	.ndo_tx_timeout	= irda_usb_net_timeout,
+};
+
 /*
  * Initialise the network side of the irda-usb instance
  * Called when a new USB instance is registered in irda_usb_probe()
@@ -1411,15 +1419,9 @@ static inline int irda_usb_open(struct i
 
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
-	irda_usb_init_qos(self);
+	netdev->netdev_ops = &irda_usb_netdev_ops;
 
-	/* Override the network functions we need to use */
-	netdev->hard_start_xmit = irda_usb_hard_xmit;
-	netdev->tx_timeout	= irda_usb_net_timeout;
-	netdev->watchdog_timeo  = 250*HZ/1000;	/* 250 ms > USB timeout */
-	netdev->open            = irda_usb_net_open;
-	netdev->stop            = irda_usb_net_close;
-	netdev->do_ioctl        = irda_usb_net_ioctl;
+	irda_usb_init_qos(self);
 
 	return register_netdev(netdev);
 }

-- 

