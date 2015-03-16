From: Colin King <colin.king@canonical.com>
Subject: [PATCH] can: gs_usb: check for kzalloc allocation failure
Date: Mon, 16 Mar 2015 22:42:24 +0000
Message-ID: <1426545744-3317-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

smatch detected the following issue:
drivers/net/can/usb/gs_usb.c:904 gs_usb_probe() error:
   potential null dereference 'dev'.  (kzalloc returns null)

Add a check for null return from kzalloc and return -ENOMEM

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/can/usb/gs_usb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index 009acc8..8b4d3e6 100644
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

