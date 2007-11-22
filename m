From: Andi Kleen <ak@suse.de>
Subject: [PATCH RFC] [3/9] modpost: Declare the modpost error functions as printf like
Date: Thu, 22 Nov 2007 03:43:08 +0100 (CET)
Message-ID: <20071122024308.9B40114D68@wotan.suse.de>
References: <20071122343.446909000@suse.de>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37766 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbXKVCnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 21:43:10 -0500
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This way gcc can warn for wrong format strings

---
 scripts/mod/modpost.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: linux/scripts/mod/modpost.c
===================================================================
--- linux.orig/scripts/mod/modpost.c
+++ linux/scripts/mod/modpost.c
@@ -33,7 +33,9 @@ enum export {
 	export_unused_gpl, export_gpl_future, export_unknown
 };
 
-void fatal(const char *fmt, ...)
+#define PRINTF __attribute__ ((format (printf, 1, 2)))
+
+PRINTF void fatal(const char *fmt, ...)
 {
 	va_list arglist;
 
@@ -46,7 +48,7 @@ void fatal(const char *fmt, ...)
 	exit(1);
 }
 
-void warn(const char *fmt, ...)
+PRINTF void warn(const char *fmt, ...)
 {
 	va_list arglist;
 
@@ -57,7 +59,7 @@ void warn(const char *fmt, ...)
 	va_end(arglist);
 }
 
-void merror(const char *fmt, ...)
+PRINTF void merror(const char *fmt, ...)
 {
 	va_list arglist;
 
