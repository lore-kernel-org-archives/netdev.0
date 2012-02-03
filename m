From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/9] can: ems_usb: Improved memory handling on ems_usb_start
Date: Fri,  3 Feb 2012 01:51:53 +0100
Message-ID: <1328230318-8962-5-git-send-email-mkl@pengutronix.de>
References: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de, mkl@blackshift.org,
	linux-can@vger.kernel.org, Sebastian Haas <dev@sebastianhaas.info>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Haas <dev@sebastianhaas.info>

Do not return from ems_usb_start if allocation fails. If not all URBs
could be allocated use the one already submitted.

Signed-off-by: Sebastian Haas <dev@sebastianhaas.info>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/ems_usb.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 7dae64d..9783e02 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -607,7 +607,8 @@ static int ems_usb_start(struct ems_usb *dev)
 		if (!urb) {
 			dev_err(netdev->dev.parent,
 				"No memory left for URBs\n");
-			return -ENOMEM;
+			err = -ENOMEM;
+			break;
 		}
 
 		buf = usb_alloc_coherent(dev->udev, RX_BUFFER_SIZE, GFP_KERNEL,
@@ -616,7 +617,8 @@ static int ems_usb_start(struct ems_usb *dev)
 			dev_err(netdev->dev.parent,
 				"No memory left for USB buffer\n");
 			usb_free_urb(urb);
-			return -ENOMEM;
+			err = -ENOMEM;
+			break;
 		}
 
 		usb_fill_bulk_urb(urb, dev->udev, usb_rcvbulkpipe(dev->udev, 2),
-- 
1.7.4.1

