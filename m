From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 7/8] can: kvaser_usb: Don't send a RESET_CHIP for non-existing channels
Date: Thu, 15 Jan 2015 17:11:22 +0100
Message-ID: <1421338283-12417-8-git-send-email-mkl@pengutronix.de>
References: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	"Ahmed S. Darwish" <ahmed.darwish@valeo.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56632 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbbAOQLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:11:36 -0500
In-Reply-To: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ahmed S. Darwish" <ahmed.darwish@valeo.com>

Recent Leaf firmware versions (>= 3.1.557) do not allow to send
commands for non-existing channels.  If a command is sent for a
non-existing channel, the firmware crashes.

Reported-by: Christopher Storah <Christopher.Storah@invetech.com.au>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/kvaser_usb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 9accc8272c27..cc7bfc0c0a71 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -1503,6 +1503,10 @@ static int kvaser_usb_init_one(struct usb_interface *intf,
 	struct kvaser_usb_net_priv *priv;
 	int i, err;
 
+	err = kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, channel);
+	if (err)
+		return err;
+
 	netdev = alloc_candev(sizeof(*priv), MAX_TX_URBS);
 	if (!netdev) {
 		dev_err(&intf->dev, "Cannot alloc candev\n");
@@ -1607,9 +1611,6 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 
 	usb_set_intfdata(intf, dev);
 
-	for (i = 0; i < MAX_NET_DEVICES; i++)
-		kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, i);
-
 	err = kvaser_usb_get_software_info(dev);
 	if (err) {
 		dev_err(&intf->dev,
-- 
2.1.4
