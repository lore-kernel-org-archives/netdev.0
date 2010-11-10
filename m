From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/9] drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
Date: Tue,  9 Nov 2010 16:35:19 -0800
Message-ID: <3c8217914a987ad3f86afbc1890637657b8b7aa7.1289348757.git.joe@perches.com>
References: <cover.1289348757.git.joe@perches.com>
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4845 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911Ab0KJAfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 19:35:31 -0500
In-Reply-To: <cover.1289348757.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using %pV reduces the number of printk calls and
eliminates any possible message interleaving from
other printk calls.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43legacy/main.c |   47 ++++++++++++++++++++++++--------
 1 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 67f18ec..1f11e16 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -181,52 +181,75 @@ static int b43legacy_ratelimit(struct b43legacy_wl *wl)
 
 void b43legacyinfo(struct b43legacy_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (!b43legacy_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_INFO "b43legacy-%s: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_INFO "b43legacy-%s: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 void b43legacyerr(struct b43legacy_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (!b43legacy_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_ERR "b43legacy-%s ERROR: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_ERR "b43legacy-%s ERROR: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 void b43legacywarn(struct b43legacy_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (!b43legacy_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_WARNING "b43legacy-%s warning: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_WARNING "b43legacy-%s warning: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 #if B43legacy_DEBUG
 void b43legacydbg(struct b43legacy_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	va_start(args, fmt);
-	printk(KERN_DEBUG "b43legacy-%s debug: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_DEBUG "b43legacy-%s debug: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 #endif /* DEBUG */
-- 
1.7.3.1.g432b3.dirty

