From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 2/2] route classifier support for multiple actions
Date: Mon,  6 Oct 2014 07:30:17 -0400
Message-ID: <1412595017-6346-2-git-send-email-jhs@emojatatu.com>
References: <1412595017-6346-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:47910 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870AbaJFLai (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:30:38 -0400
Received: by mail-ie0-f171.google.com with SMTP id tr6so3085603ieb.16
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:30:37 -0700 (PDT)
In-Reply-To: <1412595017-6346-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

route can now use the action syntax

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_route.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/tc/f_route.c b/tc/f_route.c
index 649e0ec..23c4ecc 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -28,8 +28,8 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... route [ from REALM | fromif TAG ] [ to REALM ]\n");
-	fprintf(stderr, "                [ flowid CLASSID ] [ police POLICE_SPEC ]\n");
-	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
+	fprintf(stderr, "                [ flowid CLASSID ] [ action ACTION_SPEC ]]\n");
+	fprintf(stderr, "       ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "       CLASSID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
@@ -105,6 +105,13 @@ static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char
 				return -1;
 			}
 			continue;
+		} else if (matches(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (parse_action(&argc, &argv, TCA_ROUTE4_ACT, n)) {
+				fprintf(stderr, "Illegal \"action\"\n");
+				return -1;
+			}
+			continue;
 		} else if (matches(*argv, "order") == 0) {
 			NEXT_ARG();
 			if (get_u32(&order, *argv, 0)) {
@@ -158,6 +165,8 @@ static int route_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 		fprintf(f, "fromif %s", ll_index_to_name(*(int*)RTA_DATA(tb[TCA_ROUTE4_IIF])));
 	if (tb[TCA_ROUTE4_POLICE])
 		tc_print_police(f, tb[TCA_ROUTE4_POLICE]);
+	if (tb[TCA_ROUTE4_ACT])
+		tc_print_action(f, tb[TCA_ROUTE4_ACT]);
 	return 0;
 }
 
-- 
1.7.9.5
