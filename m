From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tc util: Fix possible buffer overflow when print class id
Date: Mon, 20 Apr 2015 08:33:32 +0300
Message-ID: <1429508012-19119-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34844 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbbDTFdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 01:33:44 -0400
Received: by lbbuc2 with SMTP id uc2so121988141lbb.2
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 22:33:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Use correct handle buffer length.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 tc/tc_util.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 1d3153d..dc2b70f 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -128,30 +128,31 @@ ok:
 	return 0;
 }
 
-int print_tc_classid(char *buf, int len, __u32 h)
+int print_tc_classid(char *buf, int blen, __u32 h)
 {
-	char handle[40] = {};
+	SPRINT_BUF(handle) = {};
+	int hlen = SPRINT_BSIZE - 1;
 
 	if (h == TC_H_ROOT)
 		sprintf(handle, "root");
 	else if (h == TC_H_UNSPEC)
-		snprintf(handle, len, "none");
+		snprintf(handle, hlen, "none");
 	else if (TC_H_MAJ(h) == 0)
-		snprintf(handle, len, ":%x", TC_H_MIN(h));
+		snprintf(handle, hlen, ":%x", TC_H_MIN(h));
 	else if (TC_H_MIN(h) == 0)
-		snprintf(handle, len, "%x:", TC_H_MAJ(h) >> 16);
+		snprintf(handle, hlen, "%x:", TC_H_MAJ(h) >> 16);
 	else
-		snprintf(handle, len, "%x:%x", TC_H_MAJ(h) >> 16, TC_H_MIN(h));
+		snprintf(handle, hlen, "%x:%x", TC_H_MAJ(h) >> 16, TC_H_MIN(h));
 
 	if (use_names) {
 		char clname[IDNAME_MAX] = {};
 
 		if (id_to_name(cls_names, h, clname))
-			snprintf(buf, len, "%s#%s", clname, handle);
+			snprintf(buf, blen, "%s#%s", clname, handle);
 		else
-			snprintf(buf, len, "%s", handle);
+			snprintf(buf, blen, "%s", handle);
 	} else {
-		snprintf(buf, len, "%s", handle);
+		snprintf(buf, blen, "%s", handle);
 	}
 
 	return 0;
-- 
2.3.1
