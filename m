From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Fix allocation of cong control alg name
Date: Fri, 29 May 2015 13:30:00 +0300
Message-ID: <1432895400-12266-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:35777 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbE2KbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:31:01 -0400
Received: by labko7 with SMTP id ko7so48770425lab.2
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 03:30:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Use strdup instead of malloc, and get rid of bad strcpy.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 347e3a1..a719466 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1908,8 +1908,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 
 		if (tb[INET_DIAG_CONG]) {
 			const char *cong_attr = rta_getattr_str(tb[INET_DIAG_CONG]);
-			s.cong_alg = malloc(strlen(cong_attr + 1));
-			strcpy(s.cong_alg, cong_attr);
+			s.cong_alg = strdup(cong_attr);
 		}
 
 		if (TCPI_HAS_OPT(info, TCPI_OPT_WSCALE)) {
-- 
2.3.1
