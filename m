From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] usbnet: fix leak of transfer buffer of dev->interrupt
Date: Mon, 30 Apr 2012 16:51:02 +0800
Message-ID: <1335775864-4873-2-git-send-email-tom.leiming@gmail.com>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335775864-4873-1-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The transfer buffer of dev->interrupt is allocated in .probe path,
but not freed in .disconnet path, so mark the interrupt URB as
URB_FREE_BUFFER to free the buffer when the URB is destroyed.

Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..5b38a3a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -210,6 +210,7 @@ static int init_status (struct usbnet *dev, struct usb_interface *intf)
 		} else {
 			usb_fill_int_urb(dev->interrupt, dev->udev, pipe,
 				buf, maxp, intr_complete, dev, period);
+			dev->interrupt->transfer_flags |= URB_FREE_BUFFER;
 			dev_dbg(&intf->dev,
 				"status ep%din, %d bytes period %d\n",
 				usb_pipeendpoint(pipe), maxp, period);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
