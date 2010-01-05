From: Jan Dumon <j.dumon@option.com>
Subject: [PATCH 6/6] hso: fixed missing newlines
Date: Tue, 5 Jan 2010 15:53:00 +0100
Message-ID: <20100105145300.GF19825@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.option.com ([81.246.70.163]:41077 "EHLO
	mailer2.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237Ab0AEO4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 09:56:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Dumon <j.dumon@option.com>

Fixed missing newlines in calls to dev_warn & dev_err.

Signed-off-by: Jan Dumon <j.dumon@option.com>

--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -828,7 +828,7 @@ static netdev_tx_t hso_net_start_xmit(st
 	result = usb_submit_urb(odev->mux_bulk_tx_urb, GFP_ATOMIC);
 	if (result) {
 		dev_warn(&odev->parent->interface->dev,
-			"failed mux_bulk_tx_urb %d", result);
+			"failed mux_bulk_tx_urb %d\n", result);
 		net->stats.tx_errors++;
 		netif_start_queue(net);
 	} else {
@@ -1076,7 +1076,7 @@ static void read_bulk_callback(struct ur
 	result = usb_submit_urb(urb, GFP_ATOMIC);
 	if (result)
 		dev_warn(&odev->parent->interface->dev,
-			 "%s failed submit mux_bulk_rx_urb %d", __func__,
+			 "%s failed submit mux_bulk_rx_urb %d\n", __func__,
 			 result);
 }
 
@@ -1865,7 +1865,7 @@ static int mux_device_request(struct hso
 	result = usb_submit_urb(ctrl_urb, GFP_ATOMIC);
 	if (result) {
 		dev_err(&ctrl_urb->dev->dev,
-			"%s failed submit ctrl_urb %d type %d", __func__,
+			"%s failed submit ctrl_urb %d type %d\n", __func__,
 			result, type);
 		return result;
 	}
@@ -2385,12 +2385,12 @@ static int hso_serial_common_create(stru
 	serial->tx_data_length = tx_size;
 	serial->tx_data = kzalloc(serial->tx_data_length, GFP_KERNEL);
 	if (!serial->tx_data) {
-		dev_err(dev, "%s - Out of memory", __func__);
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		goto exit;
 	}
 	serial->tx_buffer = kzalloc(serial->tx_data_length, GFP_KERNEL);
 	if (!serial->tx_buffer) {
-		dev_err(dev, "%s - Out of memory", __func__);
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		goto exit;
 	}
 
@@ -2859,14 +2859,14 @@ struct hso_shared_int *hso_create_shared
 
 	mux->shared_intr_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!mux->shared_intr_urb) {
-		dev_err(&interface->dev, "Could not allocate intr urb?");
+		dev_err(&interface->dev, "Could not allocate intr urb?\n");
 		goto exit;
 	}
 	mux->shared_intr_buf =
 		kzalloc(le16_to_cpu(mux->intr_endp->wMaxPacketSize),
 			GFP_KERNEL);
 	if (!mux->shared_intr_buf) {
-		dev_err(&interface->dev, "Could not allocate intr buf?");
+		dev_err(&interface->dev, "Could not allocate intr buf?\n");
 		goto exit;
 	}
 
@@ -3287,7 +3287,7 @@ static int hso_mux_submit_intr_urb(struc
 
 	result = usb_submit_urb(shared_int->shared_intr_urb, gfp);
 	if (result)
-		dev_warn(&usb->dev, "%s failed mux_intr_urb %d", __func__,
+		dev_warn(&usb->dev, "%s failed mux_intr_urb %d\n", __func__,
 			result);
 
 	return result;
