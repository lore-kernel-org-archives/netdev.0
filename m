From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v3 3/4] can: kvaser_usb: Don't send a RESET_CHIP for
 non-existing channels
Date: Mon, 5 Jan 2015 12:57:13 -0500
Message-ID: <20150105175713.GC6304@linux>
References: <20141223154654.GB6460@vivalin-002>
 <20150105174910.GA6304@linux>
 <20150105175206.GB6304@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:47664 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271AbbAER5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 12:57:18 -0500
Content-Disposition: inline
In-Reply-To: <20150105175206.GB6304@linux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Recent Leaf firmware versions (>= 3.1.557) do not allow to send
commands for non-existing channels.  If a command is sent for a
non-existing channel, the firmware crashes.

Reported-by: Christopher Storah <Christopher.Storah@invetech.com.au>
Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/can/usb/kvaser_usb.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

** V3 Changelog:
- Update commit log message per Olivier remarks on v2

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 9accc82..cc7bfc0 100644
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
