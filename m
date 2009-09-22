From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net/wireless: Use usb_endpoint_dir_out
Date: Tue, 22 Sep 2009 13:45:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909221344370.20456@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "John W. Linville" <linville@tuxdriver.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@v
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756202AbZIVLpR@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use the usb_endpoint_dir_out API function.  Note that the use of
USB_TYPE_MASK in the original code is incorrect; it results in a test that
is always false.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
struct usb_endpoint_descriptor *endpoint;
expression E;
@@

- (endpoint->bEndpointAddress & E) == USB_DIR_OUT
+ usb_endpoint_dir_out(endpoint)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/zd1211rw/zd_usb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -u -p a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1070,7 +1070,7 @@ static int eject_installer(struct usb_in
 
 	/* Find bulk out endpoint */
 	endpoint = &iface_desc->endpoint[1].desc;
-	if ((endpoint->bEndpointAddress & USB_TYPE_MASK) == USB_DIR_OUT &&
+	if (usb_endpoint_dir_out(endpoint) &&
 	    usb_endpoint_xfer_bulk(endpoint)) {
 		bulk_out_ep = endpoint->bEndpointAddress;
 	} else {
