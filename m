From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/7] can: kvaser_usb: Fix sparse warning __le16 degrades to integer
Date: Sun, 22 Mar 2015 20:13:33 +0100
Message-ID: <1427051618-28318-3-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38542 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbbCVTNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:13:43 -0400
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

USB endpoint's wMaxPacketSize field is an le16 entity. Use
appropriate le16_to_cpu macros to maintain endian independence.

Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 2f9733a8e125..57611fd91229 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -596,8 +596,8 @@ static int kvaser_usb_wait_msg(const struct kvaser_usb *dev, u8 id,
 			 * for further details.
 			 */
 			if (tmp->len == 0) {
-				pos = round_up(pos,
-					       dev->bulk_in->wMaxPacketSize);
+				pos = round_up(pos, le16_to_cpu(dev->bulk_in->
+								wMaxPacketSize));
 				continue;
 			}
 
@@ -1337,7 +1337,8 @@ static void kvaser_usb_read_bulk_callback(struct urb *urb)
 		 * number of events in case of a heavy rx load on the bus.
 		 */
 		if (msg->len == 0) {
-			pos = round_up(pos, dev->bulk_in->wMaxPacketSize);
+			pos = round_up(pos, le16_to_cpu(dev->bulk_in->
+							wMaxPacketSize));
 			continue;
 		}
 
-- 
2.1.4
