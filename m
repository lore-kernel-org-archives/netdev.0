From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH] wil6210: increase cmd buffer size to avoid sscanf buffer overflow
Date: Sun,  1 Mar 2015 17:48:33 +0000
Message-ID: <1425232113-5010-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vladimir Kondratiev <qca_vkondrat-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wil6210-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

cppcheck detected a buffer overflow:

[drivers/net/wireless/ath/wil6210/debugfs.c:634]: (error) Width 8
  given in format string (no. 1) is larger than destination buffer
  'cmd[8]', use %7s to prevent overflowing it.

For the current %8s sscanf we require cmd to be 9 chars long
so increase it by 1 byte to prevent the sscan overflow (rather
than reduce the %8s specifier to %7s as cppcheck recommends).

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/ath/wil6210/debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wireless/ath/wil6210/debugfs.c
index 45c3558e..29aab12 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -618,7 +618,7 @@ static ssize_t wil_write_back(struct file *file, const char __user *buf,
 	struct wil6210_priv *wil = file->private_data;
 	int rc;
 	char *kbuf = kmalloc(len + 1, GFP_KERNEL);
-	char cmd[8];
+	char cmd[9];
 	int p1, p2, p3;
 
 	if (!kbuf)
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
