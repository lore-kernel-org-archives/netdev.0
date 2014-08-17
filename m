From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] isdn/bas_gigaset: use USB API functions rather than constants
Date: Sun, 17 Aug 2014 06:01:20 +0530
Message-ID: <20140817003120.GA11815@himangi-Dell>
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
 drivers/isdn/gigaset/bas-gigaset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index b7ae0a0..aecec6d 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -2365,7 +2365,7 @@ static int gigaset_probe(struct usb_interface *interface,
 	endpoint = &hostif->endpoint[0].desc;
 	usb_fill_int_urb(ucs->urb_int_in, udev,
 			 usb_rcvintpipe(udev,
-					(endpoint->bEndpointAddress) & 0x0f),
+					usb_endpoint_num(endpoint)),
 			 ucs->int_in_buf, IP_MSGSIZE, read_int_callback, cs,
 			 endpoint->bInterval);
 	rc = usb_submit_urb(ucs->urb_int_in, GFP_KERNEL);
-- 
1.9.1
