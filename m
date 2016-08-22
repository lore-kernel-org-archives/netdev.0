From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 iproute2 1/1] tc classifiers: Modernize tcindex classifier
Date: Mon, 22 Aug 2016 07:17:33 -0400
Message-ID: <1471864653-13511-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35951 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbcHVLSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:18:40 -0400
Received: by mail-it0-f68.google.com with SMTP id j124so4597900ith.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:17:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_tcindex.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 280d1d4..32bccb0 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -23,7 +23,7 @@ static void explain(void)
 }
 
 static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
-    char **argv, struct nlmsghdr *n)
+			     char **argv, struct nlmsghdr *n)
 {
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
@@ -49,7 +49,8 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 				explain();
 				return -1;
 			}
-			addattr_l(n, 4096, TCA_TCINDEX_HASH, &hash, sizeof(hash));
+			addattr_l(n, 4096, TCA_TCINDEX_HASH, &hash,
+				  sizeof(hash));
 		} else if (!strcmp(*argv,"mask")) {
 			__u16 mask;
 
@@ -59,7 +60,8 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 				explain();
 				return -1;
 			}
-			addattr_l(n, 4096, TCA_TCINDEX_MASK, &mask, sizeof(mask));
+			addattr_l(n, 4096, TCA_TCINDEX_MASK, &mask,
+				  sizeof(mask));
 		} else if (!strcmp(*argv,"shift")) {
 			int shift;
 
@@ -99,7 +101,7 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 			continue;
 		} else if (!strcmp(*argv,"action")) {
 			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_TCINDEX_ACT, n)) {
+			if (parse_action(&argc, &argv, TCA_TCINDEX_ACT, n)) {
 				fprintf(stderr, "Illegal \"action\"\n");
 				return -1;
 			}
@@ -117,7 +119,7 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 
 
 static int tcindex_print_opt(struct filter_util *qu, FILE *f,
-     struct rtattr *opt, __u32 handle)
+			     struct rtattr *opt, __u32 handle)
 {
 	struct rtattr *tb[TCA_TCINDEX_MAX+1];
 
@@ -171,7 +173,7 @@ static int tcindex_print_opt(struct filter_util *qu, FILE *f,
 	}
 	if (tb[TCA_TCINDEX_ACT]) {
 		fprintf(f, "\n");
-		tc_print_police(f, tb[TCA_TCINDEX_ACT]);
+		tc_print_action(f, tb[TCA_TCINDEX_ACT]);
 	}
 	return 0;
 }
-- 
1.9.1
