From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 05/16] net: can: usb: peak_usb: pcan_usb_core: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:24 +0200
Message-ID: <1470949539-25392-6-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index bfb91d8fa46056..c06382cdfdfee4 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -399,7 +399,6 @@ static int peak_usb_start(struct peak_usb_device *dev)
 		/* create a URB, and a buffer for it, to receive usb messages */
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
-			netdev_err(netdev, "No memory left for URBs\n");
 			err = -ENOMEM;
 			break;
 		}
@@ -454,7 +453,6 @@ static int peak_usb_start(struct peak_usb_device *dev)
 		/* create a URB and a buffer for it, to transmit usb messages */
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
-			netdev_err(netdev, "No memory left for URBs\n");
 			err = -ENOMEM;
 			break;
 		}
@@ -651,10 +649,8 @@ static int peak_usb_restart(struct peak_usb_device *dev)
 
 	/* first allocate a urb to handle the asynchronous steps */
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_err(dev->netdev, "no memory left for urb\n");
+	if (!urb)
 		return -ENOMEM;
-	}
 
 	/* also allocate enough space for the commands to send */
 	buf = kmalloc(PCAN_USB_MAX_CMD_LEN, GFP_ATOMIC);
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
