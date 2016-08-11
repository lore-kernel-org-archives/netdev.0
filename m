From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 10/16] net: wimax: i2400m: usb-notif: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:29 +0200
Message-ID: <1470949539-25392-11-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wimax-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/wimax/i2400m/usb-notif.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index fc1355d98bc6ae..5d429f81612546 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -206,7 +206,6 @@ int i2400mu_notification_setup(struct i2400mu *i2400mu)
 	i2400mu->notif_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!i2400mu->notif_urb) {
 		ret = -ENOMEM;
-		dev_err(dev, "notification: cannot allocate URB\n");
 		goto error_alloc_urb;
 	}
 	epd = usb_get_epd(i2400mu->usb_iface,
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
