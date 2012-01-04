From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump() into
 functions
Date: Thu, 05 Jan 2012 01:09:50 +0200
Message-ID: <20120104230950.32306.21264.stgit@x201>
References: <20120104230429.32306.75965.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath6kl-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120104230429.32306.75965.stgit@x201>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

That way it's possible to not export debug_mask outside the upcoming
ath6kl_core.ko and that makes it easier to ath6kl_core.ko in the
following patch.

Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/debug.c |   24 ++++++++++++++++++++++++
 drivers/net/wireless/ath/ath6kl/debug.h |   25 ++++---------------------
 2 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index 0d77129..1d216e9 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -57,6 +57,30 @@ int ath6kl_printk(const char *level, const char *fmt, ...)
 
 #ifdef CONFIG_ATH6KL_DEBUG
 
+void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
+{
+	va_list args;
+
+	if (!(debug_mask & mask))
+		return;
+
+	va_start(args, fmt);
+	ath6kl_printk(KERN_DEBUG, fmt, &args);
+	va_end(args);
+}
+
+void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
+		     const char *msg, const char *prefix,
+		     const void *buf, size_t len)
+{
+	if (debug_mask & mask) {
+		if (msg)
+			ath6kl_dbg(mask, "%s\n", msg);
+
+		print_hex_dump_bytes(prefix, DUMP_PREFIX_OFFSET, buf, len);
+	}
+}
+
 #define REG_OUTPUT_LEN_PER_LINE	25
 #define REGTYPE_STR_LEN		100
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index cb21d91..c4be6e5 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -61,28 +61,11 @@ enum ath6kl_war {
 };
 
 #ifdef CONFIG_ATH6KL_DEBUG
-#define ath6kl_dbg(mask, fmt, ...)					\
-	({								\
-	 int rtn;							\
-	 if (debug_mask & mask)						\
-		rtn = ath6kl_printk(KERN_DEBUG, fmt, ##__VA_ARGS__);	\
-	 else								\
-		rtn = 0;						\
-									\
-	 rtn;								\
-	 })
 
-static inline void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
-				   const char *msg, const char *prefix,
-				   const void *buf, size_t len)
-{
-	if (debug_mask & mask) {
-		if (msg)
-			ath6kl_dbg(mask, "%s\n", msg);
