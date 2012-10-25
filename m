From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 08/11] usbnet: plusb: apply introduced usb command APIs
Date: Thu, 25 Oct 2012 13:47:01 +0800
Message-ID: <1351144024-16596-9-git-send-email-ming.lei@canonical.com>
References: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351144024-16596-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/usb/plusb.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 4584b9a..0fcc8e6 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -71,13 +71,10 @@
 static inline int
 pl_vendor_req(struct usbnet *dev, u8 req, u8 val, u8 index)
 {
-	return usb_control_msg(dev->udev,
-		usb_rcvctrlpipe(dev->udev, 0),
-		req,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		val, index,
-		NULL, 0,
-		USB_CTRL_GET_TIMEOUT);
+	return usbnet_read_cmd(dev, req,
+				USB_DIR_IN | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE,
+				val, index, NULL, 0);
 }
 
 static inline int
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
