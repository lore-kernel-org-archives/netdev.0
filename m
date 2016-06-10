From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/9] tc: m_xt: Fix indenting
Date: Fri, 10 Jun 2016 13:42:02 +0200
Message-ID: <1465558928-19657-4-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35449 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbcFJLme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:34 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By exiting early if xtables_find_target() fails, one indenting level can
be dropped. Some of the wrongly indented code then happens to sit at the
right spot by accident which is why this patch is smaller than expected.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 54 ++++++++++++++++++++++++++----------------------------
 1 file changed, 26 insertions(+), 28 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 45d86d66248d4..5a629c442ac3a 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -161,12 +161,15 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 		switch (c) {
 		case 'j':
 			m = xtables_find_target(optarg, XTF_TRY_LOAD);
-			if (m != NULL) {
+			if (!m) {
+				fprintf(stderr, " failed to find target %s\n\n", optarg);
+				return -1;
+			}
 
-				if (build_st(m, NULL) < 0) {
-					printf(" %s error\n", m->name);
-					return -1;
-				}
+			if (build_st(m, NULL) < 0) {
+				printf(" %s error\n", m->name);
+				return -1;
+			}
 #if (XTABLES_VERSION_CODE >= 6)
 			opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
 						    tmp_tcipt_globals.opts,
@@ -182,22 +185,18 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 				return -1;
 			} else
 				tmp_tcipt_globals.opts = opts;
-			} else {
-				fprintf(stderr, " failed to find target %s\n\n", optarg);
-				return -1;
-			}
 			ok++;
 			break;
 
 		default:
 			memset(&fw, 0, sizeof(fw));
 #if (XTABLES_VERSION_CODE >= 6)
-		if (m != NULL && m->x6_parse != NULL) {
-			xtables_option_tpcall(c, argv, 0, m, NULL);
+			if (m != NULL && m->x6_parse != NULL) {
+				xtables_option_tpcall(c, argv, 0, m, NULL);
 #else
-		if (m != NULL && m->parse != NULL) {
-			m->parse(c - m->option_offset, argv, 0, &m->tflags,
-				 NULL, &m->t);
+			if (m != NULL && m->parse != NULL) {
+				m->parse(c - m->option_offset, argv, 0,
+				         &m->tflags, NULL, &m->t);
 #endif
 			} else {
 				fprintf(stderr, "failed to find target %s\n\n", optarg);
@@ -339,11 +338,15 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 
 		t = RTA_DATA(tb[TCA_IPT_TARG]);
 		m = xtables_find_target(t->u.user.name, XTF_TRY_LOAD);
-		if (m != NULL) {
-			if (build_st(m, t) < 0) {
-				fprintf(stderr, " %s error\n", m->name);
-				return -1;
-			}
+		if (!m) {
+			fprintf(stderr, " failed to find target %s\n\n",
+				t->u.user.name);
+			return -1;
+		}
+		if (build_st(m, t) < 0) {
+			fprintf(stderr, " %s error\n", m->name);
+			return -1;
+		}
 
 #if (XTABLES_VERSION_CODE >= 6)
 		opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
@@ -355,16 +358,11 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 					     m->extra_opts,
 					     &m->option_offset);
 #endif
-	if (opts == NULL) {
-		fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
-		return -1;
-	} else
-		tmp_tcipt_globals.opts = opts;
-		} else {
-			fprintf(stderr, " failed to find target %s\n\n",
-				t->u.user.name);
+		if (opts == NULL) {
+			fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
 			return -1;
-		}
+		} else
+			tmp_tcipt_globals.opts = opts;
 		fprintf(f, "\ttarget ");
 		m->print(NULL, m->t, 0);
 		if (tb[TCA_IPT_INDEX] == NULL) {
-- 
2.8.2
