From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 20/77] irda: convert ks959 device to net_device_ops
Date: Fri, 20 Mar 2009 22:35:47 -0700
Message-ID: <20090321053714.047172024@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36562 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760813AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-ks959.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/irda/ks959-sir.c	2009-03-19 23:10:00.793089980 -0700
+++ b/drivers/net/irda/ks959-sir.c	2009-03-19 23:11:27.344651666 -0700
@@ -668,6 +668,12 @@ static int ks959_net_ioctl(struct net_de
 	return ret;
 }
 
+static const struct net_device_ops ks959_ops = {
+	.ndo_start_xmit	= ks959_hard_xmit,
+	.ndo_open	= ks959_net_open,
+	.ndo_stop	= ks959_net_close,
+	.ndo_do_ioctl	= ks959_net_ioctl,
+};
 /*
  * This routine is called by the USB subsystem for each new device
  * in the system. We need to check if the device is ours, and in
@@ -780,10 +786,7 @@ static int ks959_probe(struct usb_interf
 	irda_qos_bits_to_value(&kingsun->qos);
 
 	/* Override the network functions we need to use */
-	net->hard_start_xmit = ks959_hard_xmit;
-	net->open = ks959_net_open;
-	net->stop = ks959_net_close;
-	net->do_ioctl = ks959_net_ioctl;
+	net->netdev_ops = &ks959_ops;
 
 	ret = register_netdev(net);
 	if (ret != 0)

-- 

