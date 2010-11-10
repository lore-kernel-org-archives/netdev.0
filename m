From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/9] drivers/net/wireless/b43/main.c: Use printf extension %pV
Date: Tue,  9 Nov 2010 16:35:18 -0800
Message-ID: <68c1a8814468ff2b8f901da4533f3bbea3c2c770.1289348757.git.joe@perches.com>
References: <cover.1289348757.git.joe@perches.com>
Cc: Stefano Brivio <stefano.brivio@polimi.it>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4840 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753749Ab0KJAfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Nov 2010 19:35:30 -0500
In-Reply-To: <cover.1289348757.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using %pV reduces the number of printk calls and
eliminates any possible message interleaving from
other printk calls.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/b43/main.c |   48 +++++++++++++++++++++++++++++---------
 1 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index a118652..fa48803 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -322,59 +322,83 @@ static int b43_ratelimit(struct b43_wl *wl)
 
 void b43info(struct b43_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (b43_modparam_verbose < B43_VERBOSITY_INFO)
 		return;
 	if (!b43_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_INFO "b43-%s: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_INFO "b43-%s: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 void b43err(struct b43_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (b43_modparam_verbose < B43_VERBOSITY_ERROR)
 		return;
 	if (!b43_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_ERR "b43-%s ERROR: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_ERR "b43-%s ERROR: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 void b43warn(struct b43_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (b43_modparam_verbose < B43_VERBOSITY_WARN)
 		return;
 	if (!b43_ratelimit(wl))
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_WARNING "b43-%s warning: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_WARNING "b43-%s warning: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
 void b43dbg(struct b43_wl *wl, const char *fmt, ...)
 {
+	struct va_format vaf;
 	va_list args;
 
 	if (b43_modparam_verbose < B43_VERBOSITY_DEBUG)
 		return;
+
 	va_start(args, fmt);
-	printk(KERN_DEBUG "b43-%s debug: ",
-	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan");
-	vprintk(fmt, args);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	printk(KERN_DEBUG "b43-%s debug: %pV",
+	       (wl && wl->hw) ? wiphy_name(wl->hw->wiphy) : "wlan", &vaf);
+
 	va_end(args);
 }
 
-- 
1.7.3.1.g432b3.dirty

