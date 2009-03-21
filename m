From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 19/77] irda: convert ksdazzle device to net_device_ops
Date: Fri, 20 Mar 2009 22:35:46 -0700
Message-ID: <20090321053713.973495714@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36563 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760792AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=ksdazzle.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/irda/ksdazzle-sir.c	2009-03-19 22:52:37.149901612 -0700
+++ b/drivers/net/irda/ksdazzle-sir.c	2009-03-19 23:08:49.416839813 -0700
@@ -562,6 +562,13 @@ static int ksdazzle_net_ioctl(struct net
 	return ret;
 }
 
+static const struct net_device_ops ksdazzle_ops = {
+	.ndo_start_xmit	= ksdazzle_hard_xmit,
+	.ndo_open	= ksdazzle_net_open,
+	.ndo_stop	= ksdazzle_net_close,
+	.ndo_do_ioctl	= ksdazzle_net_ioctl,
+};
+
 /*
  * This routine is called by the USB subsystem for each new device
  * in the system. We need to check if the device is ours, and in
@@ -684,10 +691,7 @@ static int ksdazzle_probe(struct usb_int
 	irda_qos_bits_to_value(&kingsun->qos);
 
 	/* Override the network functions we need to use */
-	net->hard_start_xmit = ksdazzle_hard_xmit;
-	net->open = ksdazzle_net_open;
-	net->stop = ksdazzle_net_close;
-	net->do_ioctl = ksdazzle_net_ioctl;
+	net->netdev_ops = &ksdazzle_ops;
 
 	ret = register_netdev(net);
 	if (ret != 0)

-- 

