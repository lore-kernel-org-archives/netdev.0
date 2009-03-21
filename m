From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/77] irda: convert w83977af_ir to net_device_ops
Date: Fri, 20 Mar 2009 22:35:38 -0700
Message-ID: <20090321053713.376037045@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36568 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760860AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-w.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/irda/w83977af_ir.c	2009-03-19 22:40:30.367964328 -0700
+++ b/drivers/net/irda/w83977af_ir.c	2009-03-19 22:42:48.582901908 -0700
@@ -140,6 +140,13 @@ static void __exit w83977af_cleanup(void
 	}
 }
 
+static const struct net_device_ops w83977_netdev_ops = {
+	.ndo_open       = w83977af_net_open,
+	.ndo_stop       = w83977af_net_close,
+	.ndo_start_xmit = w83977af_hard_xmit,
+	.ndo_do_ioctl   = w83977af_net_ioctl,
+};
+
 /*
  * Function w83977af_open (iobase, irq)
  *
@@ -231,11 +238,7 @@ static int w83977af_open(int i, unsigned
 	self->rx_buff.data = self->rx_buff.head;
 	self->netdev = dev;
 
-	/* Override the network functions we need to use */
-	dev->hard_start_xmit = w83977af_hard_xmit;
-	dev->open            = w83977af_net_open;
-	dev->stop            = w83977af_net_close;
-	dev->do_ioctl        = w83977af_net_ioctl;
+	dev->netdev_ops	= &w83977_netdev_ops;
 
 	err = register_netdev(dev);
 	if (err) {

-- 

