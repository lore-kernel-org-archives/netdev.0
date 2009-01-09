From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 33/45] baycom: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:30 -0800
Message-ID: <20090109230139.156784731@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42259 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605AbZAIXSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:07 -0500
Content-Disposition: inline; filename=baycom-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/baycom_epp.c	2009-01-09 10:22:45.000000000 -0800
+++ b/drivers/net/hamradio/baycom_epp.c	2009-01-09 10:42:00.000000000 -0800
@@ -1102,6 +1102,14 @@ static int baycom_ioctl(struct net_devic
 
 /* --------------------------------------------------------------------- */
 
+static const struct net_device_ops baycom_netdev_ops = {
+	.ndo_open	     = epp_open,
+	.ndo_stop	     = epp_close,
+	.ndo_do_ioctl	     = baycom_ioctl,
+	.ndo_start_xmit      = baycom_send_packet,
+	.ndo_set_mac_address = baycom_set_mac_address,
+};
+
 /*
  * Check for a network adaptor of this type, and return '0' if one exists.
  * If dev->base_addr == 0, probe all likely locations.
@@ -1129,16 +1137,12 @@ static void baycom_probe(struct net_devi
 	/*
 	 * initialize the device struct
 	 */
-	dev->open = epp_open;
-	dev->stop = epp_close;
-	dev->do_ioctl = baycom_ioctl;
-	dev->hard_start_xmit = baycom_send_packet;
 
 	/* Fill in the fields of the device structure */
 	bc->skb = NULL;
 	
+	dev->netdev_ops = &baycom_netdev_ops;
 	dev->header_ops = &ax25_header_ops;
-	dev->set_mac_address = baycom_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;


