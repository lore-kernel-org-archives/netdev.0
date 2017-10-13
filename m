From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 v2 4/4] color: Rename enum
Date: Fri, 13 Oct 2017 15:57:19 +0200
Message-ID: <20171013135719.18450-5-petr.vorel@gmail.com>
References: <20171013135719.18450-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37755 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753447AbdJMN5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:57:50 -0400
Received: by mail-wr0-f196.google.com with SMTP id k15so990504wrc.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:57:49 -0700 (PDT)
In-Reply-To: <20171013135719.18450-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

COLOR_NONE is more descriptive than COLOR_CLEAR.

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 include/color.h      | 2 +-
 include/json_print.h | 2 +-
 lib/color.c          | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/color.h b/include/color.h
index c183ef79..7fd685d0 100644
--- a/include/color.h
+++ b/include/color.h
@@ -8,7 +8,7 @@ enum color_attr {
 	COLOR_INET6,
 	COLOR_OPERSTATE_UP,
 	COLOR_OPERSTATE_DOWN,
-	COLOR_CLEAR
+	COLOR_NONE
 };
 
 void enable_color(void);
diff --git a/include/json_print.h b/include/json_print.h
index 596af35a..dc4d2bb3 100644
--- a/include/json_print.h
+++ b/include/json_print.h
@@ -53,7 +53,7 @@ void close_json_array(enum output_type type, const char *delim);
 					     const char *fmt,		\
 					     type value)		\
 	{								\
-		print_color_##type_name(t, COLOR_CLEAR, key, fmt, value);	\
+		print_color_##type_name(t, COLOR_NONE, key, fmt, value);	\
 	}
 _PRINT_FUNC(int, int);
 _PRINT_FUNC(bool, bool);
diff --git a/lib/color.c b/lib/color.c
index 497f5e1b..8d049a01 100644
--- a/lib/color.c
+++ b/lib/color.c
@@ -106,7 +106,7 @@ int color_fprintf(FILE *fp, enum color_attr attr, const char *fmt, ...)
 
 	va_start(args, fmt);
 
-	if (!color_is_enabled || attr == COLOR_CLEAR) {
+	if (!color_is_enabled || attr == COLOR_NONE) {
 		ret = vfprintf(fp, fmt, args);
 		goto end;
 	}
@@ -130,7 +130,7 @@ enum color_attr ifa_family_color(__u8 ifa_family)
 	case AF_INET6:
 		return COLOR_INET6;
 	default:
-		return COLOR_CLEAR;
+		return COLOR_NONE;
 	}
 }
 
@@ -142,6 +142,6 @@ enum color_attr oper_state_color(__u8 state)
 	case IF_OPER_DOWN:
 		return COLOR_OPERSTATE_DOWN;
 	default:
-		return COLOR_CLEAR;
+		return COLOR_NONE;
 	}
 }
-- 
2.14.2
