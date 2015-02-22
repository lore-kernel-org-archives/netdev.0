From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 1/2] ss: Add filter before printing unix stats from Netlink
Date: Sun, 22 Feb 2015 22:23:10 +0200
Message-ID: <1424636591-19903-2-git-send-email-vadim4j@gmail.com>
References: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41100 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBVUe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2015 15:34:29 -0500
Received: by lbiz11 with SMTP id z11so15039315lbi.8
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 12:34:27 -0800 (PST)
In-Reply-To: <1424636591-19903-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Detailed info can be printed if filter should not pass
the socket info.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2678033..5320d38 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2556,7 +2556,7 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 			}
 		}
 
-		if (f->f) {
+		if (use_proc && f->f) {
 			if (strcmp(peer, "*") == 0)
 				memset(s->remote.data, 0, sizeof(char *));
 			else
@@ -2628,6 +2628,9 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	if (tb[UNIX_DIAG_PEER])
 		stat.rport = rta_getattr_u32(tb[UNIX_DIAG_PEER]);
 
+	if (f->f && run_ssfilter(f->f, &stat) == 0)
+		return 0;
+
 	unix_stats_print(&stat, f);
 
 	if (show_mem) {
-- 
2.2.2
