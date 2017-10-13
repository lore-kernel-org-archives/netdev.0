From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH iproute2 v2 1/4] color: Fix ip segfault when using --color switch
Date: Fri, 13 Oct 2017 15:57:16 +0200
Message-ID: <20171013135719.18450-2-petr.vorel@gmail.com>
References: <20171013135719.18450-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>,
        Julien Fortin <julien@cumulusnetworks.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34926 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbdJMN5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 09:57:36 -0400
Received: by mail-wr0-f193.google.com with SMTP id y44so988255wry.2
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 06:57:35 -0700 (PDT)
In-Reply-To: <20171013135719.18450-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d0e72011 ("ip: ipaddress.c: add support for json output")
introduced passing -1 as enum color_attr. This is not only wrong as no
color_attr has value -1, but also causes another segfault in color_fprintf()
on this setup as there is no item with index -1 in array of enum attr_colors[].
Using COLOR_CLEAR is valid option.

Reproduce with:
$ COLORFGBG='0;15' ip -c a

NOTE: COLORFGBG is environmental variable used for defining whether user
has light or dark background.
COLORFGBG="0;15" is used to ask for color set suitable for light background,
COLORFGBG="15;0" is used to ask for color set suitable for dark background.

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 include/json_print.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/json_print.h b/include/json_print.h
index b6ce1f9f..596af35a 100644
--- a/include/json_print.h
+++ b/include/json_print.h
@@ -53,7 +53,7 @@ void close_json_array(enum output_type type, const char *delim);
 					     const char *fmt,		\
 					     type value)		\
 	{								\
-		print_color_##type_name(t, -1, key, fmt, value);	\
+		print_color_##type_name(t, COLOR_CLEAR, key, fmt, value);	\
 	}
 _PRINT_FUNC(int, int);
 _PRINT_FUNC(bool, bool);
-- 
2.14.2
