From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 01/27] color: add new COLOR_NONE and disable_color function
Date: Thu, 17 Aug 2017 10:35:48 -0700
Message-ID: <20170817173614.54987-2-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:32987 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752664AbdHQRkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:13 -0400
Received: by mail-wr0-f178.google.com with SMTP id b65so50104860wrd.0
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:12 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 include/color.h |  2 ++
 lib/color.c     | 12 ++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/color.h b/include/color.h
index ba0b237e..1cd6f7d2 100644
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
+void check_if_color_enabled(void);
 void set_color_palette(void);
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...);
 enum color_attr ifa_family_color(__u8 ifa_family);
diff --git a/lib/color.c b/lib/color.c
index 4e947500..79d5e289 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -89,6 +89,14 @@ void set_color_palette(void)
 		is_dark_bg = 1;
 }
 
+void check_if_color_enabled(void)
+{
+	if (color_is_enabled) {
+		fprintf(stderr, "Option \"-json\" conflicts with \"-color\".\n");
+		exit(1);
+	}
+}
+
 int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 {
 	int ret = 0;
@@ -96,13 +104,13 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 
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
2.14.1
