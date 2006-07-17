From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2]: Fix help for actions
Date: Mon, 17 Jul 2006 07:29:25 -0400
Message-ID: <1153135765.5210.47.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-a9eDs/w5inIcUADo4hav"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:36487 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750744AbWGQL33
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 07:29:29 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G2RI2-0007GB-Vc
	for netdev@vger.kernel.org; Mon, 17 Jul 2006 07:29:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-a9eDs/w5inIcUADo4hav
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Stephen,
Here's one of 2-3 patches over a period of time that i will send your
way to clean up the help for actions. Please apply.

cheers,
jamal


--=-a9eDs/w5inIcUADo4hav
Content-Disposition: attachment; filename=act_help_p1
Content-Type: text/plain; name=act_help_p1; charset=UTF-8
Content-Transfer-Encoding: 7bit

First part of cleaning up the help output of actions.

---
commit a31787bf2939fd9eb11396e3765c78c4d1e744a1
tree 884f90d157adf219559481ae5a1d70cb6cda90e7
parent 9cd6ca6d2a2b1b27fc3c98ecb8e081b19aa64019
author Jamal Hadi Salim <hadi@cyberus.ca> Mon, 17 Jul 2006 07:24:23 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Mon, 17 Jul 2006 07:24:23 -0400

 tc/m_action.c |    1 +
 tc/m_gact.c   |   24 ++++++++++++++++--------
 tc/m_mirred.c |   22 ++++++++++++++--------
 tc/m_pedit.c  |   44 +++++++++++++++++++++++---------------------
 tc/m_police.c |    9 +++------
 5 files changed, 57 insertions(+), 43 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index a7efe72..c612069 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -38,6 +38,7 @@ int tab_flush = 0;
 void act_usage(void)
 {
 	fprintf (stderr, "action usage improper\n");
+	exit(-1);
 }
 
 static int print_noaopt(struct action_util *au, FILE *f, struct rtattr *opt)
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 4bb5041..4e3f3c7 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -45,22 +45,28 @@ explain(void)
 #ifdef CONFIG_GACT_PROB
 	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX]\n");
 	fprintf(stderr,
-		"Where: ACTION := reclassify | drop | continue | pass "
-		        "RAND := random <RANDTYPE> <ACTION> <VAL>"
-		        "RANDTYPE := netrand | determ"
-			"VAL : = value not exceeding 10000"
-			"INDEX := index value used"
+		"Where: \tACTION := reclassify | drop | continue | pass \n"
+		        "\tRAND := random <RANDTYPE> <ACTION> <VAL>\n"
+		        "\tRANDTYPE := netrand | determ\n"
+			"\tVAL : = value not exceeding 10000\n"
+			"\tINDEX := index value used\n"
 			"\n");
 #else
 	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX]\n");
 	fprintf(stderr,
-		"Where: ACTION := reclassify | drop | continue | pass "
-		"INDEX := index value used"
+		"Where: \tACTION := reclassify | drop | continue | pass \n"
+		"\tINDEX := index value used\n"
 			"\n");
 #endif
 }
 
-#define usage() return(-1)
+
+static void
+usage(void)
+{
+	explain();
+	exit(-1);
+}
 
 int
 get_act(char ***argv_p)
@@ -157,6 +163,8 @@ #ifdef CONFIG_GACT_PROB
 			}
 			argc--;
 			argv++;
+		} else if (matches(*argv, "help") == 0) {
+				usage();
 		}
 	}
 #endif
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index cbfea84..ed87c81 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -33,13 +33,19 @@ explain(void)
 {
 	fprintf(stderr, "Usage: mirred <DIRECTION> <ACTION> [index INDEX] <dev DEVICENAME> \n");
 	fprintf(stderr, "where: \n");
-	fprintf(stderr, "DIRECTION := <ingress | egress>\n");
-	fprintf(stderr, "aCTION := <mirror | redirect>\n");
-	fprintf(stderr, "     : INDEX  is the specific policy instance id\n");
-	fprintf(stderr, "     : DEVICENAME is the devicename \n");
+	fprintf(stderr, "\tDIRECTION := <ingress | egress>\n");
+	fprintf(stderr, "\tACTION := <mirror | redirect>\n");
+	fprintf(stderr, "\tINDEX  is the specific policy instance id\n");
+	fprintf(stderr, "\tDEVICENAME is the devicename \n");
+
 }
 
-#define usage() return(-1)
+static void
+usage(void)
+{
+	explain();
+	exit(-1);
+}
 
 char *mirred_n2a(int action)
 {
@@ -133,7 +139,6 @@ parse_egress(struct action_util *a, int 
 	}
 
 	if (!ok && !iok) {
-		explain();
 		return -1;
 	}
 
@@ -235,9 +240,10 @@ parse_mirred(struct action_util *a, int 
 
 	} else if (matches(*argv, "ingress") == 0) {
 		fprintf(stderr,"mirred ingress not supported at the moment\n");
-
+	} else if (matches(*argv, "help") == 0) {
+		usage();
 	} else {
-		fprintf(stderr,"mirred not supported %s\n", *argv);
+		fprintf(stderr,"mirred option not supported %s\n", *argv);
 	}
 
 	return -1;
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index acfa581..5ac84a5 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -33,25 +33,30 @@ static struct m_pedit_util *pedit_list;
 int pedit_debug = 1;
 
 static void
-p_explain(void)
+explain(void)
 {
-	fprintf(stderr, "Usage: ... pedit <MUNGE>\n");
+	fprintf(stderr, "Usage: ... pedit munge <MUNGE>\n");
 	fprintf(stderr,
 		"Where: MUNGE := <RAW>|<LAYERED>\n" 
-		"<RAW>:= <OFFSETC>[ATC]<CMD>\n "
-		"OFFSETC:= offset <offval> <u8|u16|u32>\n "
-		"ATC:= at <atval> offmask <maskval> shift <shiftval>\n "
-		"NOTE: offval is byte offset, must be multiple of 4\n "
-		"NOTE: maskval is a 32 bit hex number\n "
-		"NOTE: shiftval is a is a shift value\n "
-		"CMD:= clear | invert | set <setval>| retain\n "
-		"<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
-		" | udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
-		"For Example usage look at the examples directory");
+		"\t<RAW>:= <OFFSETC>[ATC]<CMD>\n "
+		"\t\tOFFSETC:= offset <offval> <u8|u16|u32>\n "
+		"\t\tATC:= at <atval> offmask <maskval> shift <shiftval>\n "
+		"\t\tNOTE: offval is byte offset, must be multiple of 4\n "
+		"\t\tNOTE: maskval is a 32 bit hex number\n "
+		"\t\tNOTE: shiftval is a is a shift value\n "
+		"\t\tCMD:= clear | invert | set <setval>| retain\n "
+		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
+		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
+		"For Example usage look at the examples directory\n");
 
 }
 
-#define usage() return(-1)
+static void
+usage(void)
+{
+	explain();
+	exit(-1);
+}
 
 static int 
 pedit_parse_nopopt (int *argc_p, char ***argv_p,struct tc_pedit_sel *sel,struct tc_pedit_key *tkey) 
@@ -423,11 +428,6 @@ parse_munge(int *argc_p, char ***argv_p,
 		NEXT_ARG();
 		res = parse_offset(&argc, &argv,sel,&tkey);
 		goto done;
-#if jamal
-	} else if (strcmp(*argv, "help") == 0) {
-		p_explain();
-		return -1;
-#endif
 	} else {
 		char k[16];
 		struct m_pedit_util *p = NULL;
@@ -479,16 +479,18 @@ parse_pedit(struct action_util *a, int *
 			NEXT_ARG();
 			ok++;
 			continue;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
 		} else if (matches(*argv, "munge") == 0) {
 			if (!ok) {
 				fprintf(stderr, "Illegal pedit construct (%s) \n", *argv);
-				p_explain();
+				explain();
 				return -1;
 			}
 			NEXT_ARG();
 			if (parse_munge(&argc, &argv,&sel.sel)) {
 				fprintf(stderr, "Illegal pedit construct (%s) \n", *argv);
-				p_explain();
+				explain();
 				return -1;
 			}
 			ok++;
@@ -499,7 +501,7 @@ parse_pedit(struct action_util *a, int *
 	}
 
 	if (!ok) {
-		p_explain();
+		explain();
 		return -1;
 	}
 
diff --git a/tc/m_police.c b/tc/m_police.c
index 71adb59..7b80367 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -32,7 +32,7 @@ struct action_util police_action_util = 
 	.print_aopt = print_police,
 };
 
-static void explain(void)
+static void usage(void)
 {
 	fprintf(stderr, "Usage: ... police rate BPS burst BYTES[/BYTES] [ mtu BYTES[/BYTES] ]\n");
 	fprintf(stderr, "                [ peakrate BPS ] [ avrate BPS ]\n");
@@ -41,6 +41,7 @@ static void explain(void)
 	fprintf(stderr, "New Syntax ACTIONTERM := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT] \n"); 
 	fprintf(stderr, "Where: *EXCEEDACT := pipe | ok | reclassify | drop | continue \n");
 	fprintf(stderr, "Where:  pipe is only valid for new syntax \n");
+	exit(-1);
 }
 
 static void explain1(char *arg)
@@ -48,9 +49,6 @@ static void explain1(char *arg)
 	fprintf(stderr, "Illegal \"%s\"\n", arg);
 }
 
-#define usage() return(-1)
-
-
 char *police_action_n2a(int action, char *buf, int len)
 {
 	switch (action) {
@@ -236,8 +234,7 @@ int act_parse_police(struct action_util 
 				return -1;
 			}
 		} else if (strcmp(*argv, "help") == 0) {
-			explain();
-			return -1;
+			usage();
 		} else {
 			break;
 		}

--=-a9eDs/w5inIcUADo4hav--

