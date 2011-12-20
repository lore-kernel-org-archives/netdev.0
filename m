From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2 1/3] utils: add s32 parser
Date: Tue, 20 Dec 2011 22:28:46 +0100
Message-ID: <1324416528-3845-2-git-send-email-hagen@jauu.net>
References: <1324416528-3845-1-git-send-email-hagen@jauu.net>
Cc: shemminger@vyatta.com, Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42972 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752738Ab1LTV3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:29:19 -0500
In-Reply-To: <1324416528-3845-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/utils.h |    1 +
 lib/utils.c     |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 47f8e07..496db68 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -85,6 +85,7 @@ extern int get_time_rtt(unsigned *val, const char *arg, int *raw);
 #define get_short get_s16
 extern int get_u64(__u64 *val, const char *arg, int base);
 extern int get_u32(__u32 *val, const char *arg, int base);
+extern int get_s32(__s32 *val, const char *arg, int base);
 extern int get_u16(__u16 *val, const char *arg, int base);
 extern int get_s16(__s16 *val, const char *arg, int base);
 extern int get_u8(__u8 *val, const char *arg, int base);
diff --git a/lib/utils.c b/lib/utils.c
index efaf377..d80f79b 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -25,6 +25,7 @@
 #include <linux/pkt_sched.h>
 #include <time.h>
 #include <sys/time.h>
+#include <errno.h>
 
 
 #include "utils.h"
@@ -198,6 +199,24 @@ int get_u8(__u8 *val, const char *arg, int base)
 	return 0;
 }
 
+int get_s32(__s32 *val, const char *arg, int base)
+{
+	long res;
+	char *ptr;
+
+	errno = 0;
+
+	if (!arg || !*arg)
+		return -1;
+	res = strtol(arg, &ptr, base);
+	if (ptr == arg || *ptr ||
+	    ((res ==  LONG_MIN || res == LONG_MAX) && errno == ERANGE) ||
+	    res > INT32_MAX || res < INT32_MIN)
+		return -1;
+	*val = res;
+	return 0;
+}
+
 int get_s16(__s16 *val, const char *arg, int base)
 {
 	long res;
-- 
1.7.7.3
