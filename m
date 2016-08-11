From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 07/16] net: usb: hso: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:26 +0200
Message-ID: <1470949539-25392-8-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/usb/hso.c | 20 +++++---------------
 1 file changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 4b4458616693f9..c5544d36c54f96 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2300,10 +2300,8 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 	serial->rx_data_length = rx_size;
 	for (i = 0; i < serial->num_rx_urbs; i++) {
 		serial->rx_urb[i] = usb_alloc_urb(0, GFP_KERNEL);
-		if (!serial->rx_urb[i]) {
-			dev_err(dev, "Could not allocate urb?\n");
+		if (!serial->rx_urb[i])
 			goto exit;
-		}
 		serial->rx_urb[i]->transfer_buffer = NULL;
 		serial->rx_urb[i]->transfer_buffer_length = 0;
 		serial->rx_data[i] = kzalloc(serial->rx_data_length,
@@ -2314,10 +2312,8 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 
 	/* TX, allocate urb and initialize */
 	serial->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!serial->tx_urb) {
-		dev_err(dev, "Could not allocate urb?\n");
+	if (!serial->tx_urb)
 		goto exit;
-	}
 	serial->tx_urb->transfer_buffer = NULL;
 	serial->tx_urb->transfer_buffer_length = 0;
 	/* prepare our TX buffer */
@@ -2555,20 +2551,16 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 	/* start allocating */
 	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
 		hso_net->mux_bulk_rx_urb_pool[i] = usb_alloc_urb(0, GFP_KERNEL);
-		if (!hso_net->mux_bulk_rx_urb_pool[i]) {
-			dev_err(&interface->dev, "Could not allocate rx urb\n");
+		if (!hso_net->mux_bulk_rx_urb_pool[i])
 			goto exit;
-		}
 		hso_net->mux_bulk_rx_buf_pool[i] = kzalloc(MUX_BULK_RX_BUF_SIZE,
 							   GFP_KERNEL);
 		if (!hso_net->mux_bulk_rx_buf_pool[i])
 			goto exit;
 	}
 	hso_net->mux_bulk_tx_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!hso_net->mux_bulk_tx_urb) {
-		dev_err(&interface->dev, "Could not allocate tx urb\n");
+	if (!hso_net->mux_bulk_tx_urb)
 		goto exit;
-	}
 	hso_net->mux_bulk_tx_buf = kzalloc(MUX_BULK_TX_BUF_SIZE, GFP_KERNEL);
 	if (!hso_net->mux_bulk_tx_buf)
 		goto exit;
@@ -2787,10 +2779,8 @@ struct hso_shared_int *hso_create_shared_int(struct usb_interface *interface)
 	}
 
 	mux->shared_intr_urb = usb_alloc_urb(0, GFP_KERNEL);
-	if (!mux->shared_intr_urb) {
-		dev_err(&interface->dev, "Could not allocate intr urb?\n");
+	if (!mux->shared_intr_urb)
 		goto exit;
-	}
 	mux->shared_intr_buf =
 		kzalloc(le16_to_cpu(mux->intr_endp->wMaxPacketSize),
 			GFP_KERNEL);
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
