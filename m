From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/77] stir4200: convert to net_device_ops
Date: Fri, 20 Mar 2009 22:35:37 -0700
Message-ID: <20090321053713.305126852@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36573 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760875AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-stir.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/irda/stir4200.c	2009-03-19 22:40:30.388964511 -0700
+++ b/drivers/net/irda/stir4200.c	2009-03-19 22:42:47.828091113 -0700
@@ -1007,6 +1007,13 @@ static int stir_net_ioctl(struct net_dev
 	return ret;
 }
 
+static const struct net_device_ops stir_netdev_ops = {
+	.ndo_open       = stir_net_open,
+	.ndo_stop       = stir_net_close,
+	.ndo_start_xmit = stir_hard_xmit,
+	.ndo_do_ioctl   = stir_net_ioctl,
+};
+
 /*
  * This routine is called by the USB subsystem for each new device
  * in the system. We need to check if the device is ours, and in
@@ -1054,10 +1061,7 @@ static int stir_probe(struct usb_interfa
 	irda_qos_bits_to_value(&stir->qos);
 
 	/* Override the network functions we need to use */
-	net->hard_start_xmit = stir_hard_xmit;
-	net->open            = stir_net_open;
-	net->stop            = stir_net_close;
-	net->do_ioctl        = stir_net_ioctl;
+	net->netdev_ops = &stir_netdev_ops;
 
 	ret = register_netdev(net);
 	if (ret != 0)

-- 

