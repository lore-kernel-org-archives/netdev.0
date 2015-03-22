From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/7] can: gs_usb: check for kzalloc allocation failure
Date: Sun, 22 Mar 2015 20:13:34 +0100
Message-ID: <1427051618-28318-4-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Colin Ian King <colin.king@canonical.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:38544 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbCVTNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:13:45 -0400
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

smatch detected the following issue:
drivers/net/can/usb/gs_usb.c:904 gs_usb_probe() error:
   potential null dereference 'dev'.  (kzalloc returns null)

Add a check for null return from kzalloc and return -ENOMEM

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 009acc8641fc..8b4d3e6875eb 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -901,6 +901,8 @@ static int gs_usb_probe(struct usb_interface *intf, const struct usb_device_id *
 	}
 
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return -ENOMEM;
 	init_usb_anchor(&dev->rx_submitted);
 
 	atomic_set(&dev->active_channels, 0);
-- 
2.1.4
