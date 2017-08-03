From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 01/27] color: add new COLOR_NONE and disable_color function
Date: Thu,  3 Aug 2017 17:54:49 +0200
Message-ID: <20170803155515.99226-2-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37487 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751158AbdHCPzg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:36 -0400
Received: by mail-wm0-f48.google.com with SMTP id t201so19235396wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:35 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 include/color.h | 2 ++
 lib/color.c     | 9 +++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/color.h b/include/color.h
index ba0b237e..a4ca1177 100644
--- a/include/color.h
+++ b/include/color.h
@@ -2,6 +2,7 @@
 #define __COLOR_H__ 1
 
 enum color_attr {
+	COLOR_NONE,
 	COLOR_IFNAME,
 	COLOR_MAC,
 	COLOR_INET,
@@ -12,6 +13,7 @@ enum color_attr {
 };
 
 void enable_color(void);
+void disable_color(void);
 void set_color_palette(void);
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
 enum color_attr ifa_family_color(__u8 ifa_family);
diff --git a/lib/color.c b/lib/color.c
index 4e947500..2d1db194 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -89,6 +89,11 @@ void set_color_palette(void)
 		is_dark_bg = 1;
 }
 
+void disable_color(void)
+{
+	color_is_enabled = 0;
+}
+
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 {
 	int ret = 0;
@@ -96,13 +101,13 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 
 	va_start(args, fmt);
 
-	if (!color_is_enabled) {
+	if (!color_is_enabled || attr == COLOR_NONE) {
 		ret = vfprintf(fp, fmt, args);
 		goto end;
 	}
 
 	ret += fprintf(fp, "%s",
-		       color_codes[attr_colors[is_dark_bg ? attr + 7 : attr]]);
+		       color_codes[attr_colors[is_dark_bg ? attr + 8 : attr]]);
 	ret += vfprintf(fp, fmt, args);
 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
 
-- 
2.13.3
