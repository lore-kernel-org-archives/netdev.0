From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH iproute2 1/2] utils: add s32 parser
Date: Thu, 24 Nov 2011 18:40:14 +0100
Message-ID: <1322156415-23331-1-git-send-email-hagen@jauu.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:37277 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750789Ab1KXRkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 12:40:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 include/utils.h |    1 +
 lib/utils.c     |   14 ++++++++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

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
index efaf377..6788dd9 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -198,6 +198,20 @@ int get_u8(__u8 *val, const char *arg, int base)
 	return 0;
 }
 
+int get_s32(__s32 *val, const char *arg, int base)
+{
+	long res;
+	char *ptr;
+
+	if (!arg || !*arg)
+		return -1;
+	res = strtoul(arg, &ptr, base);
+	if (!ptr || ptr == arg || *ptr || res > INT32_MAX || res < INT32_MIN)
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
