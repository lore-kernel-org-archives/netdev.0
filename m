From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH 1/2] ss: Unify meminfo output
Date: Tue, 20 Jan 2015 16:14:23 +0200
Message-ID: <1421763264-8954-2-git-send-email-vadim4j@gmail.com>
References: <1421763264-8954-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:49978 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbbATOZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 09:25:08 -0500
Received: by mail-wi0-f182.google.com with SMTP id n3so22390037wiv.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 06:25:07 -0800 (PST)
In-Reply-To: <1421763264-8954-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index f434f57..3764f3a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1613,8 +1613,24 @@ static char *sprint_bw(char *buf, double bw)
 static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 {
 	const __u32 *skmeminfo;
-	if (!tb[attrtype])
+
+	if (!tb[attrtype]) {
+		if (attrtype == INET_DIAG_SKMEMINFO) {
+			if (!tb[INET_DIAG_MEMINFO])
+				return;
+
+			const struct inet_diag_meminfo *minfo =
+				RTA_DATA(tb[INET_DIAG_MEMINFO]);
+
+			printf(" mem:(r%u,w%u,f%u,t%u)",
+					minfo->idiag_rmem,
+					minfo->idiag_wmem,
+					minfo->idiag_fmem,
+					minfo->idiag_tmem);
+		}
 		return;
+	}
+
 	skmeminfo = RTA_DATA(tb[attrtype]);
 
 	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
@@ -1639,17 +1655,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 	char b1[64];
 	double rtt = 0;
 
-	if (tb[INET_DIAG_SKMEMINFO]) {
-		print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
-	} else if (tb[INET_DIAG_MEMINFO]) {
-		const struct inet_diag_meminfo *minfo
-			= RTA_DATA(tb[INET_DIAG_MEMINFO]);
-		printf(" mem:(r%u,w%u,f%u,t%u)",
-		       minfo->idiag_rmem,
-		       minfo->idiag_wmem,
-		       minfo->idiag_fmem,
-		       minfo->idiag_tmem);
-	}
+	print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 
 	if (tb[INET_DIAG_INFO]) {
 		struct tcp_info *info;
-- 
2.1.3
