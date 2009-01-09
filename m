From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 39/45] hdlcdrv: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:36 -0800
Message-ID: <20090109230139.625427535@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>, t.sailer@alumni.ethz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42279 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbZAIXSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:11 -0500
Content-Disposition: inline; filename=hdlcdrv-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/hdlcdrv.c	2009-01-09 12:52:18.000000000 -0800
+++ b/drivers/net/hamradio/hdlcdrv.c	2009-01-09 12:52:27.000000000 -0800
@@ -617,6 +617,14 @@ static int hdlcdrv_ioctl(struct net_devi
 
 /* --------------------------------------------------------------------- */
 
+static const struct net_device_ops hdlcdrv_netdev = {
+	.ndo_open	= hdlcdrv_open,
+	.ndo_stop	= hdlcdrv_close,
+	.ndo_start_xmit = hdlcdrv_send_packet,
+	.ndo_do_ioctl	= hdlcdrv_ioctl,
+	.ndo_set_mac_address = hdlcdrv_set_mac_address,
+};
+
 /*
  * Initialize fields in hdlcdrv
  */
@@ -656,21 +664,13 @@ static void hdlcdrv_setup(struct net_dev
 	s->bitbuf_hdlc.shreg = 0x80;
 #endif /* HDLCDRV_DEBUG */
 
-	/*
-	 * initialize the device struct
-	 */
-	dev->open = hdlcdrv_open;
-	dev->stop = hdlcdrv_close;
-	dev->do_ioctl = hdlcdrv_ioctl;
-	dev->hard_start_xmit = hdlcdrv_send_packet;
-	dev->get_stats = hdlcdrv_get_stats;
 
 	/* Fill in the fields of the device structure */
 
 	s->skb = NULL;
 	
+	dev->netdev_ops = &hdlcdrv_netdev;
 	dev->header_ops = &ax25_header_ops;
-	dev->set_mac_address = hdlcdrv_set_mac_address;
 	
 	dev->type = ARPHRD_AX25;           /* AF_AX25 device */
 	dev->hard_header_len = AX25_MAX_HEADER_LEN + AX25_BPQ_HEADER_LEN;


