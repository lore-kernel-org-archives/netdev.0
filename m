From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 v2 3/4] color: Cleanup code to remove "magic" offset + 7
Date: Fri, 13 Oct 2017 15:57:18 +0200
Message-ID: <20171013135719.18450-4-petr.vorel@gmail.com>
References: <20171013135719.18450-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:55341 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753447AbdJMN5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:57:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id u138so22097757wmu.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:57:45 -0700 (PDT)
In-Reply-To: <20171013135719.18450-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 lib/color.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/color.c b/lib/color.c
index 05afcb21..497f5e1b 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -45,8 +45,8 @@ static const char * const color_codes[] = {
 	NULL,
 };
 
-static enum color attr_colors[] = {
-	/* light background */
+/* light background */
+static enum color attr_colors_light[] = {
 	C_CYAN,
 	C_YELLOW,
 	C_MAGENTA,
@@ -54,8 +54,10 @@ static enum color attr_colors[] = {
 	C_GREEN,
 	C_RED,
 	C_CLEAR,
+};
 
-	/* dark background */
+/* dark background */
+static enum color attr_colors_dark[] = {
 	C_BOLD_CYAN,
 	C_BOLD_YELLOW,
 	C_BOLD_MAGENTA,
@@ -109,8 +111,9 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 		goto end;
 	}
 
-	ret += fprintf(fp, "%s",
-		       color_codes[attr_colors[is_dark_bg ? attr + 7 : attr]]);
+	ret += fprintf(fp, "%s", color_codes[is_dark_bg ?
+		attr_colors_dark[attr] : attr_colors_light[attr]]);
+
 	ret += vfprintf(fp, fmt, args);
 	ret += fprintf(fp, "%s", color_codes[C_CLEAR]);
 
-- 
2.14.2
