From: Vladimir Murzin <murzin.v-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] wlcore: limit base for output buffer in dev_mem_read
Date: Thu, 12 Sep 2013 17:32:23 +0200
Message-ID: <1378999943-1968-4-git-send-email-murzin.v@gmail.com>
References: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Cc: coelho-l0cyMroinI0@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Vladimir Murzin <murzin.v-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1378999943-1968-1-git-send-email-murzin.v-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

dev_mem_read tries to speed up things a bit by limiting output
buffer which can not exceed WLCORE_MAX_BLOCK_SIZE. However,
WLCORE_MAX_BLOCK_SIZE is based on PAGE_SIZE which may vary.

Use 4K size base for buffer explicitly.

Signed-off-by: Vladimir Murzin <murzin.v-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/debugfs.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index e17630c..6b413a7 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -38,7 +38,8 @@
 /* ms */
 #define WL1271_DEBUGFS_STATS_LIFETIME 1000
 
-#define WLCORE_MAX_BLOCK_SIZE ((size_t)(4*PAGE_SIZE))
+#define WLCORE_PAGE_SIZE	4096
+#define WLCORE_MAX_BLOCK_SIZE ((size_t)(4*WLCORE_PAGE_SIZE))
 
 /* debugfs macros idea from mac80211 */
 int wl1271_format_buffer(char __user *userbuf, size_t count,
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
