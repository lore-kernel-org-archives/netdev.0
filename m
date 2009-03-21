From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/77] irda: convert mcs driver to net_device_ops
Date: Fri, 20 Mar 2009 22:35:36 -0700
Message-ID: <20090321053713.225888375@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36565 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760816AbZCUFsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:15 -0400
Content-Disposition: inline; filename=irda-msc7780.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/irda/mcs7780.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

--- a/drivers/net/irda/mcs7780.c	2009-03-19 22:40:30.408964174 -0700
+++ b/drivers/net/irda/mcs7780.c	2009-03-19 22:42:47.157714010 -0700
@@ -873,6 +873,13 @@ static int mcs_hard_xmit(struct sk_buff 
 	return ret;
 }
 
+static const struct net_device_ops mcs_netdev_ops = {
+	.ndo_open = mcs_net_open,
+	.ndo_stop = mcs_net_close,
+	.ndo_start_xmit = mcs_hard_xmit,
+	.ndo_do_ioctl = mcs_net_ioctl,
+};
+
 /*
  * This function is called by the USB subsystem for each new device in the
  * system.  Need to verify the device and if it is, then start handling it.
@@ -919,11 +926,7 @@ static int mcs_probe(struct usb_interfac
 	/* Speed change work initialisation*/
 	INIT_WORK(&mcs->work, mcs_speed_work);
 
-	/* Override the network functions we need to use */
-	ndev->hard_start_xmit = mcs_hard_xmit;
-	ndev->open = mcs_net_open;
-	ndev->stop = mcs_net_close;
-	ndev->do_ioctl = mcs_net_ioctl;
+	ndev->netdev_ops = &mcs_netdev_ops;
 
 	if (!intf->cur_altsetting)
 		goto error2;

-- 

