From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: [PATCH] iwl4965: Enable checking of format strings
Date: Wed, 11 Feb 2015 23:51:08 +0100
Message-ID: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since these fmt_* variables are just const char*, and not const
char[], gcc (and smatch) doesn't to type checking of the arguments to
the printf functions. Since the linker knows perfectly well to merge
identical string constants, there's no point in having three static
pointers waste memory and give an extra level of indirection.

This removes over 100 "non-constant format argument" warnings from
smatch, accounting for about 20% of all such warnings in an
allmodconfig.

Signed-off-by: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
---
 drivers/net/wireless/iwlegacy/4965-debug.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965-debug.c b/drivers/net/wireless/iwlegacy/4965-debug.c
index e0597bfdddb8..18855325cc1c 100644
--- a/drivers/net/wireless/iwlegacy/4965-debug.c
+++ b/drivers/net/wireless/iwlegacy/4965-debug.c
@@ -28,10 +28,9 @@
 #include "common.h"
 #include "4965.h"
 
-static const char *fmt_value = "  %-30s %10u\n";
-static const char *fmt_table = "  %-30s %10u  %10u  %10u  %10u\n";
-static const char *fmt_header =
-    "%-32s    current  cumulative       delta         max\n";
+#define fmt_value "  %-30s %10u\n"
+#define fmt_table "  %-30s %10u  %10u  %10u  %10u\n"
+#define fmt_header "%-32s    current  cumulative       delta         max\n"
 
 static int
 il4965_stats_flag(struct il_priv *il, char *buf, int bufsz)
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
