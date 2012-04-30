From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] usbnet: fix failure handling in usbnet_probe
Date: Mon, 30 Apr 2012 16:51:03 +0800
Message-ID: <1335775864-4873-3-git-send-email-tom.leiming@gmail.com>
References: <1335775864-4873-1-git-send-email-tom.leiming@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335775864-4873-1-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If register_netdev returns failure, the dev->interrupt and
its transfer buffer should be released, so just fix it.

Signed-off-by: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/usbnet.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 5b38a3a..80b837c 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1445,7 +1445,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	status = register_netdev (net);
 	if (status)
-		goto out3;
+		goto out4;
 	netif_info(dev, probe, dev->net,
 		   "register '%s' at usb-%s-%s, %s, %pM\n",
 		   udev->dev.driver->name,
@@ -1463,6 +1463,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	return 0;
 
+out4:
+	usb_free_urb(dev->interrupt);
 out3:
 	if (info->unbind)
 		info->unbind (dev, udev);
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
