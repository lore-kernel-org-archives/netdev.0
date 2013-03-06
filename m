From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v1 1/7] USB: adds comment on suspend callback
Date: Wed,  6 Mar 2013 18:25:50 +0800
Message-ID: <1362565557-15884-2-git-send-email-ming.lei@canonical.com>
References: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1362565557-15884-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case and let resume/reset_resume callback
handle the suspend failure if needed.

Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 include/linux/usb.h |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/usb.h b/include/linux/usb.h
index 4d22d0f..6e66dc4 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -978,7 +978,14 @@ struct usbdrv_wrap {
  *	the "usbfs" filesystem.  This lets devices provide ways to
  *	expose information to user space regardless of where they
  *	do (or don't) show up otherwise in the filesystem.
- * @suspend: Called when the device is going to be suspended by the system.
+ * @suspend: Called when the device is going to be suspended by the
+ *	system either from system sleep or runtime suspend context, and
+ *	its failure return value will be ignored in system sleep context,
+ *	so do NOT try to recover device for this case. It is suggested
+ *	the callback always return 0 if resume/reset_resume callback can
+ *	handle system sususpend failure at default, otherwise driver
+ *	need to record the suspend failure and let resume/reset_resume
+ *	handle previous system suspend failure to recover device.
  * @resume: Called when the device is being resumed by the system.
  * @reset_resume: Called when the suspended device has been reset instead
  *	of being resumed.
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
