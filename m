From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/7] USB: adds comment on suspend callback
Date: Tue,  5 Mar 2013 12:01:37 +0800
Message-ID: <1362456103-24956-2-git-send-email-ming.lei@canonical.com>
References: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362456103-24956-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds comments on interface driver suspend callback
to emphasize that the failure return value is ignored by
USB core in system sleep context, so do not try to recover
device for this case.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 include/linux/usb.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/usb.h b/include/linux/usb.h
index 4d22d0f..ea9d7cb 100644
--- a/include/linux/usb.h
+++ b/include/linux/usb.h
@@ -978,7 +978,10 @@ struct usbdrv_wrap {
  *	the "usbfs" filesystem.  This lets devices provide ways to
  *	expose information to user space regardless of where they
  *	do (or don't) show up otherwise in the filesystem.
- * @suspend: Called when the device is going to be suspended by the system.
+ * @suspend: Called when the device is going to be suspended by the
+ *	system either from system sleep or runtime suspend context, and
+ *	its failed return value will be ignored in system sleep context,
+ *	so do NOT try to recover device for this case.
  * @resume: Called when the device is being resumed by the system.
  * @reset_resume: Called when the suspended device has been reset instead
  *	of being resumed.
-- 
1.7.9.5

