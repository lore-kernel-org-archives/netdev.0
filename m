From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: [PATCH] drivers/net/usb/catc.c: Fix potential deadlock in catc_ctrl_run()
Date: Mon, 30 May 2011 21:01:18 +0400
Message-ID: <1306774878-5471-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The patch replaces GFP_KERNEL with GFP_ATOMIC.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
---
 drivers/net/usb/catc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index d7221c4..8056f8a 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -495,7 +495,7 @@ static void catc_ctrl_run(struct catc *catc)
 	if (!q->dir && q->buf && q->len)
 		memcpy(catc->ctrl_buf, q->buf, q->len);
 
-	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_KERNEL)))
+	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_ATOMIC)))
 		err("submit(ctrl_urb) status %d", status);
 }
 
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
