From: Vimalkumar <j.vimal@gmail.com>
Subject: [PATCH] print_rate: use knowledge in rate_suffix table for human readable rates.
Date: Sat,  9 Mar 2013 19:26:38 -0800
Message-ID: <1362885998-14292-1-git-send-email-j.vimal@gmail.com>
Cc: Vimalkumar <j.vimal@gmail.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:46350 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3CJD0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 22:26:51 -0500
Received: by mail-da0-f51.google.com with SMTP id z17so450819dal.24
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 19:26:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Vimalkumar <j.vimal@gmail.com>
---
 tc/tc_util.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 0939536..6e68d87 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -139,7 +139,8 @@ static const struct rate_suffix {
 	{ "GBps",	8000000000. },
 	{ "TiBps",	8.*1024.*1024.*1024.*1024. },
 	{ "TBps",	8000000000000. },
-	{ NULL }
+	{ NULL },
+	{ NULL },
 };
 
 
@@ -171,21 +172,18 @@ void print_rate(char *buf, int len, __u64 rate)
 {
 	double tmp = (double)rate*8;
 	extern int use_iec;
+	int start = 0;
+	const struct rate_suffix *s;
 
 	if (use_iec) {
-		if (tmp >= 1000.0*1024.0*1024.0)
-			snprintf(buf, len, "%.0fMibit", tmp/(1024.0*1024.0));
-		else if (tmp >= 1000.0*1024)
-			snprintf(buf, len, "%.0fKibit", tmp/1024);
-		else
-			snprintf(buf, len, "%.0fbit", tmp);
-	} else {
-		if (tmp >= 1000.0*1000000.0)
-			snprintf(buf, len, "%.0fMbit", tmp/1000000.0);
-		else if (tmp >= 1000.0 * 1000.0)
-			snprintf(buf, len, "%.0fKbit", tmp/1000.0);
-		else
-			snprintf(buf, len, "%.0fbit",  tmp);
+		start = 1;
+	}
+
+	snprintf(buf, len, "%.0fbit", tmp);
+	for (s = &suffixes[start]; s->name; s += 2) {
+		if (tmp >= s->scale) {
+			snprintf(buf, len, "%.3f%s", tmp / s->scale, s->name);
+		}
 	}
 }
 
-- 
1.7.5.3
