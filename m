From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] isdn/gigaset: use USB API functions rather than constants
Date: Fri, 15 Aug 2014 21:54:12 +0530
Message-ID: <20140815162412.GA7192@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of the function usb_endpoint_num.

The Coccinelle semantic patch that makes these changes is as follows:

@@ struct usb_endpoint_descriptor *epd; @@

- (epd->bEndpointAddress & \(USB_ENDPOINT_NUMBER_MASK\|0x0f\))
+ usb_endpoint_num(epd)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 drivers/isdn/gigaset/usb-gigaset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index d0a41cb..00d4077 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -751,7 +751,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	/* Fill the interrupt urb and send it to the core */
 	usb_fill_int_urb(ucs->read_urb, udev,
 			 usb_rcvintpipe(udev,
-					endpoint->bEndpointAddress & 0x0f),
+					usb_endpoint_num(endpoint)),
 			 ucs->rcvbuf, buffer_size,
 			 gigaset_read_int_callback,
 			 cs, endpoint->bInterval);
-- 
1.9.1
