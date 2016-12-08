From: =?UTF-8?q?Micha=C5=82=20K=C4=99pie=C5=84?= <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
Subject: [PATCH v2 1/2] net: rfkill: Cleanup error handling in rfkill_init()
Date: Thu,  8 Dec 2016 08:30:51 +0100
Message-ID: <20161208073052.12988-1-kernel@kempniu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use a separate label per error condition in rfkill_init() to make it a
bit cleaner and easier to extend.

Signed-off-by: Michał Kępień <kernel-ePNcKBjznIDVItvQsEIGlw@public.gmane.org>
---
No changes from v1.

 net/rfkill/core.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 884027f..f28e441 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -1266,24 +1266,25 @@ static int __init rfkill_init(void)
 
 	error = class_register(&rfkill_class);
 	if (error)
-		goto out;
+		goto error_class;
 
 	error = misc_register(&rfkill_miscdev);
-	if (error) {
-		class_unregister(&rfkill_class);
-		goto out;
-	}
+	if (error)
+		goto error_misc;
 
 #ifdef CONFIG_RFKILL_INPUT
 	error = rfkill_handler_init();
-	if (error) {
-		misc_deregister(&rfkill_miscdev);
-		class_unregister(&rfkill_class);
-		goto out;
-	}
+	if (error)
+		goto error_input;
 #endif
 
- out:
+	return 0;
+
+error_input:
+	misc_deregister(&rfkill_miscdev);
+error_misc:
+	class_unregister(&rfkill_class);
+error_class:
 	return error;
 }
 subsys_initcall(rfkill_init);
-- 
2.10.2
