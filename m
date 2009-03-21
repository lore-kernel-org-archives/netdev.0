From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 18/77] irda: convert kignsun device to net_device_ops
Date: Fri, 20 Mar 2009 22:35:45 -0700
Message-ID: <20090321053713.897498717@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36572 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760832AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=kingsun.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/irda/kingsun-sir.c	2009-03-19 22:49:39.434901885 -0700
+++ b/drivers/net/irda/kingsun-sir.c	2009-03-19 22:52:44.909902552 -0700
@@ -418,6 +418,12 @@ static int kingsun_net_ioctl(struct net_
 	return ret;
 }
 
+static const struct net_device_ops kingsun_ops = {
+	.ndo_start_xmit = kingsun_hard_xmit,
+	.ndo_open            = kingsun_net_open,
+	.ndo_stop            = kingsun_net_close,
+	.ndo_do_ioctl        = kingsun_net_ioctl,
+};
 
 /*
  * This routine is called by the USB subsystem for each new device
@@ -520,10 +526,7 @@ static int kingsun_probe(struct usb_inte
 	irda_qos_bits_to_value(&kingsun->qos);
 
 	/* Override the network functions we need to use */
-	net->hard_start_xmit = kingsun_hard_xmit;
-	net->open            = kingsun_net_open;
-	net->stop            = kingsun_net_close;
-	net->do_ioctl        = kingsun_net_ioctl;
+	net->netdev_ops = &kingsun_ops;
 
 	ret = register_netdev(net);
 	if (ret != 0)

-- 

