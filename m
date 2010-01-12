From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 4/5] tc: remove stale code
Date: Tue, 12 Jan 2010 21:45:01 +0100
Message-ID: <1263329102-19707-1-git-send-email-fw@strlen.de>
References: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:54391 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751191Ab0ALUpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 15:45:45 -0500
In-Reply-To: <20100112203428.GA24531@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove unused #define and "ok" statements.

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 tc/f_fw.c      |    2 --
 tc/f_route.c   |    2 --
 tc/f_rsvp.c    |    2 --
 tc/f_tcindex.c |    4 ----
 tc/f_u32.c     |    2 --
 tc/q_atm.c     |    2 --
 tc/q_cbq.c     |    3 +--
 tc/q_drr.c     |    1 -
 tc/q_dsmark.c  |    3 ---
 tc/q_fifo.c    |    2 --
 tc/q_gred.c    |    2 --
 tc/q_htb.c     |    2 --
 tc/q_ingress.c |    2 --
 tc/q_multiq.c  |    2 --
 tc/q_netem.c   |    2 --
 tc/q_prio.c    |    4 ----
 tc/q_red.c     |    2 --
 tc/q_rr.c      |    3 ---
 tc/q_sfq.c     |    2 --
 tc/q_tbf.c     |    2 --
 20 files changed, 1 insertions(+), 45 deletions(-)

diff --git a/tc/f_fw.c b/tc/f_fw.c
index cc8ea2d..219b404 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -31,8 +31,6 @@ static void explain(void)
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
-#define usage() return(-1)
-
 static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tc_police tp;
diff --git a/tc/f_route.c b/tc/f_route.c
index 67dd49c..eccf924 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -34,8 +34,6 @@ static void explain(void)
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
-#define usage() return(-1)
-
 static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tc_police tp;
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 7e1e6d9..808310d 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -37,8 +37,6 @@ static void explain(void)
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
-#define usage() return(-1)
-
 int get_addr_and_pi(int *argc_p, char ***argv_p, inet_prefix * addr,
 		    struct tc_rsvp_pinfo *pinfo, int dir, int family)
 {
diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 39ac75a..cb6f854 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -24,10 +24,6 @@ static void explain(void)
 	    "[ police POLICE_SPEC ]\n");
 }
 
-
-#define usage() return(-1)
-
-
 static int tcindex_parse_opt(struct filter_util *qu, char *handle, int argc,
     char **argv, struct nlmsghdr *n)
 {
diff --git a/tc/f_u32.c b/tc/f_u32.c
index cb3f67e..4f5f74e 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -45,8 +45,6 @@ static void explain(void)
 	fprintf(stderr, "\nNOTE: CLASSID is parsed at hexadecimal input.\n");
 }
 
-#define usage() return(-1)
-
 int get_u32_handle(__u32 *handle, const char *str)
 {
 	__u32 htid=0, hash=0, nodeid=0;
diff --git a/tc/q_atm.c b/tc/q_atm.c
index 4c8dc0b..eec0d77 100644
--- a/tc/q_atm.c
+++ b/tc/q_atm.c
@@ -26,8 +26,6 @@
 
 #define MAX_HDR_LEN 64
 
-#define usage() return(-1)
-
 
 static int atm_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index c99dc3b..3c5e72c 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -46,7 +46,6 @@ static void explain1(char *arg)
 	fprintf(stderr, "Illegal \"%s\"\n", arg);
 }
 
-#define usage() return(-1)
 
 static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
@@ -319,7 +318,7 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 			NEXT_ARG();
 			if (get_tc_classid(&fopt.split, *argv)) {
 				fprintf(stderr, "Invalid split node ID.\n");
-				usage();
+				return -1;
 			}
 			fopt_ok++;
 		} else if (matches(*argv, "defmap") == 0) {
diff --git a/tc/q_drr.c b/tc/q_drr.c
index 7d2d874..81de44d 100644
--- a/tc/q_drr.c
+++ b/tc/q_drr.c
@@ -33,7 +33,6 @@ static void explain2(void)
 	fprintf(stderr, "Usage: ... drr quantum SIZE\n");
 }
 
-#define usage() return(-1)
 
 static int drr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
diff --git a/tc/q_dsmark.c b/tc/q_dsmark.c
index cdb5bf2..cfbb335 100644
--- a/tc/q_dsmark.c
+++ b/tc/q_dsmark.c
@@ -19,9 +19,6 @@
 #include "tc_util.h"
 
 
-#define usage() return(-1)
-
-
 static void explain(void)
 {
 	fprintf(stderr,"Usage: dsmark indices INDICES [ default_index "
diff --git a/tc/q_fifo.c b/tc/q_fifo.c
index 9f3b3eb..f561752 100644
--- a/tc/q_fifo.c
+++ b/tc/q_fifo.c
@@ -28,8 +28,6 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... [p|b]fifo [ limit NUMBER ]\n");
 }
 
-#define usage() return(-1)
-
 static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok=0;
diff --git a/tc/q_gred.c b/tc/q_gred.c
index ab26801..df4aa3d 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -46,8 +46,6 @@ static void explain(void)
 	    "[grio]\n");
 }
 
-#define usage() return(-1)
-
 static int init_gred(struct qdisc_util *qu, int argc, char **argv, 
 		     struct nlmsghdr *n)
 {
diff --git a/tc/q_htb.c b/tc/q_htb.c
index c69e350..caa47c2 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -58,8 +58,6 @@ static void explain1(char *arg)
 }
 
 
-#define usage() return(-1)
-
 static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tc_htb_glob opt;
diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index 71fbd49..ba58e72 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -32,8 +32,6 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... ingress \n");
 }
 
-#define usage() return(-1)
-
 static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 
diff --git a/tc/q_multiq.c b/tc/q_multiq.c
index 306e170..fce5e44 100644
--- a/tc/q_multiq.c
+++ b/tc/q_multiq.c
@@ -41,8 +41,6 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... multiq [help]\n");
 }
 
-#define usage() return(-1)
-
 static int multiq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			    struct nlmsghdr *n)
 {
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 33b3d2a..6aaaded 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -42,8 +42,6 @@ static void explain1(const char *arg)
 	fprintf(stderr, "Illegal \"%s\"\n", arg);
 }
 
-#define usage() return(-1)
-
 /* Upper bound on size of distribution 
  *  really (TCA_BUF_MAX - other headers) / sizeof (__s16)
  */
diff --git a/tc/q_prio.c b/tc/q_prio.c
index 31a37cd..2f54d55 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -28,11 +28,8 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... prio bands NUMBER priomap P1 P2...[multiqueue]\n");
 }
 
-#define usage() return(-1)
-
 static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	int ok=0;
 	int pmap_mode = 0;
 	int idx = 0;
 	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
@@ -48,7 +45,6 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				fprintf(stderr, "Illegal \"bands\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "priomap") == 0) {
 			if (pmap_mode) {
 				fprintf(stderr, "Error: duplicate priomap\n");
diff --git a/tc/q_red.c b/tc/q_red.c
index 3ba6bc7..4b1b889 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -31,8 +31,6 @@ static void explain(void)
 	fprintf(stderr, "               probability PROBABILITY bandwidth KBPS [ ecn ]\n");
 }
 
-#define usage() return(-1)
-
 static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tc_red_qopt opt;
diff --git a/tc/q_rr.c b/tc/q_rr.c
index 9bb8c7d..1ff3ac9 100644
--- a/tc/q_rr.c
+++ b/tc/q_rr.c
@@ -28,11 +28,9 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... rr bands NUMBER priomap P1 P2... [multiqueue]\n");
 }
 
-#define usage() return(-1)
 
 static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	int ok = 0;
 	int pmap_mode = 0;
 	int idx = 0;
 	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
@@ -48,7 +46,6 @@ static int rr_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlm
 				fprintf(stderr, "Illegal \"bands\"\n");
 				return -1;
 			}
-			ok++;
 		} else if (strcmp(*argv, "priomap") == 0) {
 			if (pmap_mode) {
 				fprintf(stderr, "Error: duplicate priomap\n");
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index ce4dade..71a3c9a 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -28,8 +28,6 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... sfq [ limit NUMBER ] [ perturb SECS ] [ quantum BYTES ]\n");
 }
 
-#define usage() return(-1)
-
 static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok=0;
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 06ccda3..dc556fe 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -36,8 +36,6 @@ static void explain1(char *arg)
 }
 
 
-#define usage() return(-1)
-
 static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok=0;
-- 
1.6.4.4

