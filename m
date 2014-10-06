From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/2] tcindex classifier support for multiple actions
Date: Mon,  6 Oct 2014 07:30:16 -0400
Message-ID: <1412595017-6346-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38921 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbaJFLab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:30:31 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so2949642iec.8
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:30:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

tcindex can now use the action syntax

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_tcindex.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 590c0a6..b1847c8 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -21,7 +21,7 @@ static void explain(void)
 	    " [ shift SHIFT ]\n");
 	fprintf(stderr,"                    [ pass_on | fall_through ]\n");
 	fprintf(stderr,"                    [ classid CLASSID ] "
-	    "[ police POLICE_SPEC ]\n");
+	    "[ action ACTION_SPEC ]\n");
 }
 
 static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
@@ -106,6 +106,14 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 			}
 			continue;
 		}
+		else if (!strcmp(*argv,"action")) {
+			NEXT_ARG();
+			if (parse_police(&argc, &argv, TCA_TCINDEX_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
+		}
 		else {
 			explain();
 			return -1;
@@ -171,6 +179,10 @@ static int tcindex_print_opt(struct filter_util *qu, FILE *f,
 		fprintf(f, "\n");
 		tc_print_police(f, tb[TCA_TCINDEX_POLICE]);
 	}
+	if (tb[TCA_TCINDEX_ACT]) {
+		fprintf(f, "\n");
+		tc_print_police(f, tb[TCA_TCINDEX_ACT]);
+	}
 	return 0;
 }
 
-- 
1.7.9.5
