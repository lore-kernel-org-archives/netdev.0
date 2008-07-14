From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH IPROUTE]: cls_flow: add perturbation support
Date: Mon, 14 Jul 2008 14:42:48 +0200
Message-ID: <487B49C8.6030607@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070507070405050402000003"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43347 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbYGNMoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 08:44:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070507070405050402000003
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070507070405050402000003
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 337628b9aca63fda7622701191d6304c83438909
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jul 4 04:54:56 2008 +0200

    cls_flow: add perturbation support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 99efbed..7cf7824 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -374,6 +374,7 @@ enum
 	TCA_FLOW_ACT,
 	TCA_FLOW_POLICE,
 	TCA_FLOW_EMATCHES,
+	TCA_FLOW_PERTURB,
 	__TCA_FLOW_MAX
 };
 
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 1537ade..84b45c9 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -24,7 +24,7 @@ static void explain(void)
 "Usage: ... flow ...\n"
 "\n"
 " [mapping mode]: map key KEY [ OPS ] ...\n"
-" [hashing mode]: hash keys KEY-LIST ...\n"
+" [hashing mode]: hash keys KEY-LIST ... [ perturb SECS ]\n"
 "\n"
 "                 [ divisor NUM ] [ baseclass ID ] [ match EMATCH_TREE ]\n"
 "                 [ police POLICE_SPEC ] [ action ACTION_SPEC ]\n"
@@ -211,6 +211,13 @@ static int flow_parse_opt(struct filter_util *fu, char *handle,
 				return -1;
 			}
 			addattr32(n, 4096, TCA_FLOW_BASECLASS, tmp);
+		} else if (matches(*argv, "perturb") == 0) {
+			NEXT_ARG();
+			if (get_u32(&tmp, *argv, 0)) {
+				fprintf(stderr, "Illegal \"perturb\"\n");
+				return -1;
+			}
+			addattr32(n, 4096, TCA_FLOW_PERTURB, tmp);
 		} else if (matches(*argv, "police") == 0) {
 			NEXT_ARG();
 			if (parse_police(&argc, &argv, TCA_FLOW_POLICE, n)) {
@@ -331,6 +338,10 @@ static int flow_print_opt(struct filter_util *fu, FILE *f, struct rtattr *opt,
 		fprintf(f, "baseclass %s ",
 			sprint_tc_classid(*(__u32 *)RTA_DATA(tb[TCA_FLOW_BASECLASS]), b1));
 
+	if (tb[TCA_FLOW_PERTURB])
+		fprintf(f, "perturb %usec ",
+			*(__u32 *)RTA_DATA(tb[TCA_FLOW_PERTURB]));
+
 	if (tb[TCA_FLOW_EMATCHES])
 		print_ematch(f, tb[TCA_FLOW_EMATCHES]);
 	if (tb[TCA_FLOW_POLICE])

--------------070507070405050402000003--
