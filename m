From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] net: can: esd_usb2: check index of array before accessing
Date: Fri, 19 Jul 2013 15:17:48 +0200
Message-ID: <1374239869-27085-2-git-send-email-mkl@pengutronix.de>
References: <1374239869-27085-1-git-send-email-mkl@pengutronix.de>
Cc: kernel@pengutronix.de, linux-can@vger.kernel.org,
	davem@davemloft.net, Maximilian Schneider <max@schneidersoft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42820 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760461Ab3GSNSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:18:24 -0400
In-Reply-To: <1374239869-27085-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maximilian Schneider <max@schneidersoft.net>

The esd_usb2_read_bulk_callback() function is parsing the data that comes from
the USB CAN adapter. One datum is used as an index to access the dev->nets[]
array. This patch adds the missing bounds checking.

Acked-by: Matthias Fuchs <matthias.fuchs@esd.eu>
Signed-off-by: Maximilian Schneider <max@schneidersoft.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/esd_usb2.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 6aa7b32..ac6177d 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -412,10 +412,20 @@ static void esd_usb2_read_bulk_callback(struct urb *urb)
 
 		switch (msg->msg.hdr.cmd) {
 		case CMD_CAN_RX:
+			if (msg->msg.rx.net >= dev->net_count) {
+				dev_err(dev->udev->dev.parent, "format error\n");
+				break;
+			}
+
 			esd_usb2_rx_can_msg(dev->nets[msg->msg.rx.net], msg);
 			break;
 
 		case CMD_CAN_TX:
+			if (msg->msg.txdone.net >= dev->net_count) {
+				dev_err(dev->udev->dev.parent, "format error\n");
+				break;
+			}
+
 			esd_usb2_tx_done_msg(dev->nets[msg->msg.txdone.net],
 					     msg);
 			break;
-- 
1.8.3.1
