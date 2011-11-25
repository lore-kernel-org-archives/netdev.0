From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2] utils: add s32 parser
Date: Sat, 26 Nov 2011 00:00:26 +0100
Message-ID: <1322262026-8561-1-git-send-email-hagen@jauu.net>
References: <20111125174751.GA3751@hell>
Cc: David.Laight@ACULAB.COM, Stephen Hemminger <shemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35488 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752460Ab1KYXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 18:00:36 -0500
In-Reply-To: <20111125174751.GA3751@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should be enough "security", tc users have root capabilities
anyway.

Not sure if we should save errno and restore afterwards:

errno_save = errno;
errno = 0;
[...]
errno = errno_save;


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
index efaf377..9cd45e4 100644
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
+	    ((res =  LONG_MIN || res == LONG_MAX) && errno == ERANGE) ||
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
1.7.7
