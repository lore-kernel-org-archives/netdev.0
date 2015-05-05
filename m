From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] tc: fill in handle before checking argc
Date: Tue,  5 May 2015 15:30:20 -0700
Message-ID: <1430865020-16509-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33425 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbEEWa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 18:30:29 -0400
Received: by pacwv17 with SMTP id wv17so207684946pac.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 15:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When deleting a specific basic filter with handle,
tc command always ignores the 'handle' option, so
tcm_handle is always 0 and kernel deletes all filters
in the selected group. This is wrong, we should respect
'handle' in cmdline.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 tc/f_basic.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index 1c33ca3..4adf1d2 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -43,9 +43,6 @@ static int basic_parse_opt(struct filter_util *qu, char *handle,
 	struct rtattr *tail;
 	long h = 0;
 
-	if (argc == 0)
-		return 0;
-
 	if (handle) {
 		h = strtol(handle, NULL, 0);
 		if (h == LONG_MIN || h == LONG_MAX) {
@@ -54,9 +51,11 @@ static int basic_parse_opt(struct filter_util *qu, char *handle,
 			return -1;
 		}
 	}
-
 	t->tcm_handle = h;
 
+	if (argc == 0)
+		return 0;
+
 	tail = (struct rtattr*)(((void*)n)+NLMSG_ALIGN(n->nlmsg_len));
 	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
 
-- 
1.8.3.1
