From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: peak_usb: fix memset() usage
Date: Sun,  7 Dec 2014 23:06:04 +0100
Message-ID: <1417989966-31309-2-git-send-email-mkl@pengutronix.de>
References: <1417989966-31309-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1417989966-31309-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Grosjean <s.grosjean@peak-system.com>

This patchs fixes a misplaced call to memset() that fills the request
buffer with 0. The problem was with sending PCAN_USBPRO_REQ_FCT
requests, the content set by the caller was thus lost.

With this patch, the memory area is zeroed only when requesting info
from the device.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 263dd921edc4..f7f796a2c50b 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -333,8 +333,6 @@ static int pcan_usb_pro_send_req(struct peak_usb_device *dev, int req_id,
 	if (!(dev->state & PCAN_USB_STATE_CONNECTED))
 		return 0;
 
-	memset(req_addr, '\0', req_size);
-
 	req_type = USB_TYPE_VENDOR | USB_RECIP_OTHER;
 
 	switch (req_id) {
@@ -345,6 +343,7 @@ static int pcan_usb_pro_send_req(struct peak_usb_device *dev, int req_id,
 	default:
 		p = usb_rcvctrlpipe(dev->udev, 0);
 		req_type |= USB_DIR_IN;
+		memset(req_addr, '\0', req_size);
 		break;
 	}
 
-- 
2.1.3

