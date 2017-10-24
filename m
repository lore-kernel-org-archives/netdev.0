From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: kvaser_usb: Ignore CMD_FLUSH_QUEUE_REPLY messages
Date: Tue, 24 Oct 2017 13:27:25 +0200
Message-ID: <20171024112725.13203-4-mkl@pengutronix.de>
References: <20171024112725.13203-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Jimmy Assarsson <jimmyassarsson@gmail.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57491 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932409AbdJXL1g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 07:27:36 -0400
In-Reply-To: <20171024112725.13203-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jimmy Assarsson <jimmyassarsson@gmail.com>

To avoid kernel warning "Unhandled message (68)", ignore the
CMD_FLUSH_QUEUE_REPLY message for now.

As of Leaf v2 firmware version v4.1.844 (2017-02-15), flush tx queue is
synchronous. There is a capability bit indicating whether flushing tx
queue is synchronous or asynchronous.

A proper solution would be to query the device for capabilities. If the
synchronous tx flush capability bit is set, we should wait for
CMD_FLUSH_QUEUE_REPLY message, while flushing the tx queue.

Signed-off-by: Jimmy Assarsson <jimmyassarsson@gmail.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 861e90efab86..9b18d96ef526 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -137,6 +137,7 @@ static inline bool kvaser_is_usbcan(const struct usb_device_id *id)
 #define CMD_RESET_ERROR_COUNTER		49
 #define CMD_TX_ACKNOWLEDGE		50
 #define CMD_CAN_ERROR_EVENT		51
+#define CMD_FLUSH_QUEUE_REPLY		68
 
 #define CMD_LEAF_USB_THROTTLE		77
 #define CMD_LEAF_LOG_MESSAGE		106
@@ -1301,6 +1302,11 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
 			goto warn;
 		break;
 
+	case CMD_FLUSH_QUEUE_REPLY:
+		if (dev->family != KVASER_LEAF)
+			goto warn;
+		break;
+
 	default:
 warn:		dev_warn(dev->udev->dev.parent,
 			 "Unhandled message (%d)\n", msg->id);
-- 
2.14.2
