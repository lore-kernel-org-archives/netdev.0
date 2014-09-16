From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip lib: Change timestamp to be shorter and on the same line
Date: Tue, 16 Sep 2014 12:58:06 +0300
Message-ID: <1410861486-2631-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62417 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753112AbaIPKGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 06:06:25 -0400
Received: by mail-lb0-f174.google.com with SMTP id 10so6234582lbg.19
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 03:06:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed timestamp format to look like more logging info:

[Sep 01 20:56:11.853146]2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
    link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 lib/utils.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index dc21567..03092ba 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -772,14 +772,13 @@ __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 int print_timestamp(FILE *fp)
 {
 	struct timeval tv;
-	char *tstr;
+	char tstr[40] = {};
 
 	memset(&tv, 0, sizeof(tv));
 	gettimeofday(&tv, NULL);
 
-	tstr = asctime(localtime(&tv.tv_sec));
-	tstr[strlen(tstr)-1] = 0;
-	fprintf(fp, "Timestamp: %s %ld usec\n", tstr, (long)tv.tv_usec);
+	strftime(tstr, sizeof(tstr), "%b %d %H:%M:%S", localtime(&tv.tv_sec));
+	fprintf(fp, "[%s.%ld]", tstr, (long)tv.tv_usec);
 	return 0;
 }
 
-- 
2.1.0
