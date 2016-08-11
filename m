From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 02/16] net: can: usb: esd_usb2: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:21 +0200
Message-ID: <1470949539-25392-3-git-send-email-wsa-dev@sang-engineering.com>
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
 drivers/net/can/usb/esd_usb2.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/can/usb/esd_usb2.c b/drivers/net/can/usb/esd_usb2.c
index 784a9002fbb930..be928ce62d32e0 100644
--- a/drivers/net/can/usb/esd_usb2.c
+++ b/drivers/net/can/usb/esd_usb2.c
@@ -558,8 +558,6 @@ static int esd_usb2_setup_rx_urbs(struct esd_usb2 *dev)
 		/* create a URB, and a buffer for it */
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
-			dev_warn(dev->udev->dev.parent,
-				 "No memory left for URBs\n");
 			err = -ENOMEM;
 			break;
 		}
@@ -730,7 +728,6 @@ static netdev_tx_t esd_usb2_start_xmit(struct sk_buff *skb,
 	/* create a URB, and a buffer for it, and copy the data to the URB */
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		netdev_err(netdev, "No memory left for URBs\n");
 		stats->tx_dropped++;
 		dev_kfree_skb(skb);
 		goto nourbmem;
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
