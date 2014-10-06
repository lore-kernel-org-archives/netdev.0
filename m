From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/1] RFC: obsolete direct invocation of police
Date: Mon,  6 Oct 2014 07:46:00 -0400
Message-ID: <1412595960-7862-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:55252 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbaJFLqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 07:46:13 -0400
Received: by mail-ie0-f177.google.com with SMTP id rd18so2968611iec.8
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 04:46:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

I realize this may be controversial. I dont think people are still using
the 1990s syntax anymore. This is one way to test it.
We want to eventually phase out the kernel hacks for backward compat.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_basic.c   |    9 +++------
 tc/f_bpf.c     |    9 +++------
 tc/f_cgroup.c  |    9 +++------
 tc/f_flow.c    |    9 +++------
 tc/f_fw.c      |    9 +++------
 tc/f_route.c   |    9 +++------
 tc/f_rsvp.c    |    9 +++------
 tc/f_tcindex.c |    9 +++------
 tc/f_u32.c     |   10 +++-------
 9 files changed, 27 insertions(+), 55 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index 1c33ca3..6137f83 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -86,12 +86,9 @@ static int basic_parse_opt(struct filter_util *qu, char *handle,
 			continue;
 
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_BASIC_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 48635a7..4d86f38 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -227,12 +227,9 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			}
 			continue;
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_BPF_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
index 53f7406..092050c 100644
--- a/tc/f_cgroup.c
+++ b/tc/f_cgroup.c
@@ -60,12 +60,9 @@ static int cgroup_parse_opt(struct filter_util *qu, char *handle,
 			continue;
 
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_CGROUP_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/tc/f_flow.c b/tc/f_flow.c
index b454a65..d021f6f 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -220,12 +220,9 @@ static int flow_parse_opt(struct filter_util *fu, char *handle,
 			}
 			addattr32(n, 4096, TCA_FLOW_PERTURB, tmp);
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_FLOW_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_FLOW_ACT, n)) {
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 165f489..4b15cce1 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -78,12 +78,9 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 			}
 			addattr_l(n, 4096, TCA_FW_CLASSID, &handle, 4);
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_FW_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_FW_ACT, n)) {
diff --git a/tc/f_route.c b/tc/f_route.c
index 23c4ecc..7603c0e 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -99,12 +99,9 @@ static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char
 			}
 			addattr_l(n, 4096, TCA_ROUTE4_CLASSID, &handle, 4);
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_ROUTE4_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (parse_action(&argc, &argv, TCA_ROUTE4_ACT, n)) {
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index cb7b8fb..b1af8fb 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -269,12 +269,9 @@ static int rsvp_parse_opt(struct filter_util *qu, char *handle, int argc, char *
 			}
 			continue;
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_RSVP_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index b1847c8..e7a08d9 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -99,12 +99,9 @@ static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
 			addattr_l(n, 4096, TCA_TCINDEX_CLASSID, &handle, 4);
 		}
 		else if (!strcmp(*argv,"police")) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_TCINDEX_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		}
 		else if (!strcmp(*argv,"action")) {
 			NEXT_ARG();
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 80a5097..a7b3da6 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1131,13 +1131,9 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			continue;
 
 		} else if (matches(*argv, "police") == 0) {
-			NEXT_ARG();
-			if (parse_police(&argc, &argv, TCA_U32_POLICE, n)) {
-				fprintf(stderr, "Illegal \"police\"\n");
-				return -1;
-			}
-			terminal_ok++;
-			continue;
+			fprintf(stderr, "Obsolete \"police\"\n");
+			fprintf(stderr, "use \"action police ...\"\n");
+			return -1;
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
-- 
1.7.9.5
