From: Kautuk Consul <consul.kautuk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/1] drivers/net/usb/usbnet.c: No need for usb_free_urb in rx_complete
Date: Sat,  3 Sep 2011 23:05:53 +0530
Message-ID: <1315071353-14978-1-git-send-email-consul.kautuk@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kautuk Consul <consul.kautuk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

usb_hcd_giveback_urb frees the urb irrespective of any return
value from the urb->complete function. It calls usb_put_urb which 
is #defined to usb_free_urb, so maybe we shouldn't be freeing this 
from rx_complete.

But I can't get around the fact that this has not been detected as a problem 
till now, so I could be quite wrong about this. :)

Signed-off-by: Kautuk Consul <consul.kautuk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ce395fe..6df8094 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -491,7 +491,6 @@ block:
 			rx_submit (dev, urb, GFP_ATOMIC);
 			return;
 		}
-		usb_free_urb (urb);
 	}
 	netif_dbg(dev, rx_err, dev->net, "no read resubmitted\n");
 }
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
