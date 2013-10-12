From: Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] usbnet: fix error return code in usbnet_probe()
Date: Sat, 12 Oct 2013 14:24:08 +0800
Message-ID: <CAPgLHd9jQfT2Kzi5o+3KPy0hFrkHL135K2aYp7OXcbLX4Cmkcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oneukum-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>

Fix to return -ENOMEM in the padding pkt alloc fail error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
---
 drivers/net/usb/usbnet.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index bf94e10..90a429b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1688,8 +1688,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if (dev->can_dma_sg && !(info->flags & FLAG_SEND_ZLP) &&
 		!(info->flags & FLAG_MULTI_PACKET)) {
 		dev->padding_pkt = kzalloc(1, GFP_KERNEL);
-		if (!dev->padding_pkt)
+		if (!dev->padding_pkt) {
+			status = -ENOMEM;
 			goto out4;
+		}
 	}
 
 	status = register_netdev (net);

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
