From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/9] tc: m_xt: Get rid of one indentation level in parse_ipt()
Date: Fri, 10 Jun 2016 13:42:03 +0200
Message-ID: <1465558928-19657-5-git-send-email-phil@nwl.cc>
References: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47822 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbcFJLmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 07:42:40 -0400
In-Reply-To: <1465558928-19657-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 91 +++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 45 insertions(+), 46 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 5a629c442ac3a..b3731086c717b 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -298,6 +298,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 static int
 print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 {
+	struct xtables_target *m;
 	struct rtattr *tb[TCA_IPT_MAX + 1];
 	struct xt_entry_target *t = NULL;
 	struct option *opts = NULL;
@@ -333,62 +334,60 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 	if (tb[TCA_IPT_TARG] == NULL) {
 		fprintf(f, "\t[NULL ipt target parameters ]\n");
 		return -1;
-	} else {
-		struct xtables_target *m = NULL;
-
-		t = RTA_DATA(tb[TCA_IPT_TARG]);
-		m = xtables_find_target(t->u.user.name, XTF_TRY_LOAD);
-		if (!m) {
-			fprintf(stderr, " failed to find target %s\n\n",
-				t->u.user.name);
-			return -1;
-		}
-		if (build_st(m, t) < 0) {
-			fprintf(stderr, " %s error\n", m->name);
-			return -1;
-		}
+	}
+
+	t = RTA_DATA(tb[TCA_IPT_TARG]);
+	m = xtables_find_target(t->u.user.name, XTF_TRY_LOAD);
+	if (!m) {
+		fprintf(stderr, " failed to find target %s\n\n",
+			t->u.user.name);
+		return -1;
+	}
+	if (build_st(m, t) < 0) {
+		fprintf(stderr, " %s error\n", m->name);
+		return -1;
+	}
 
 #if (XTABLES_VERSION_CODE >= 6)
-		opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
-					    tmp_tcipt_globals.opts,
-					    m->x6_options,
-					    &m->option_offset);
+	opts = xtables_options_xfrm(tmp_tcipt_globals.orig_opts,
+				    tmp_tcipt_globals.opts,
+				    m->x6_options,
+				    &m->option_offset);
 #else
-		opts = xtables_merge_options(tmp_tcipt_globals.opts,
-					     m->extra_opts,
-					     &m->option_offset);
+	opts = xtables_merge_options(tmp_tcipt_globals.opts,
+				     m->extra_opts,
+				     &m->option_offset);
 #endif
-		if (opts == NULL) {
-			fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
-			return -1;
-		} else
-			tmp_tcipt_globals.opts = opts;
-		fprintf(f, "\ttarget ");
-		m->print(NULL, m->t, 0);
-		if (tb[TCA_IPT_INDEX] == NULL) {
-			fprintf(f, " [NULL ipt target index ]\n");
-		} else {
-			__u32 index;
+	if (opts == NULL) {
+		fprintf(stderr, " failed to find additional options for target %s\n\n", optarg);
+		return -1;
+	} else
+		tmp_tcipt_globals.opts = opts;
+	fprintf(f, "\ttarget ");
+	m->print(NULL, m->t, 0);
+	if (tb[TCA_IPT_INDEX] == NULL) {
+		fprintf(f, " [NULL ipt target index ]\n");
+	} else {
+		__u32 index;
 
-			index = rta_getattr_u32(tb[TCA_IPT_INDEX]);
-			fprintf(f, "\n\tindex %d", index);
-		}
+		index = rta_getattr_u32(tb[TCA_IPT_INDEX]);
+		fprintf(f, "\n\tindex %d", index);
+	}
 
-		if (tb[TCA_IPT_CNT]) {
-			struct tc_cnt *c  = RTA_DATA(tb[TCA_IPT_CNT]);
+	if (tb[TCA_IPT_CNT]) {
+		struct tc_cnt *c  = RTA_DATA(tb[TCA_IPT_CNT]);
 
-			fprintf(f, " ref %d bind %d", c->refcnt, c->bindcnt);
-		}
-		if (show_stats) {
-			if (tb[TCA_IPT_TM]) {
-				struct tcf_t *tm = RTA_DATA(tb[TCA_IPT_TM]);
+		fprintf(f, " ref %d bind %d", c->refcnt, c->bindcnt);
+	}
+	if (show_stats) {
+		if (tb[TCA_IPT_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_IPT_TM]);
 
-				print_tm(f, tm);
-			}
+			print_tm(f, tm);
 		}
-		fprintf(f, "\n");
-
 	}
+	fprintf(f, "\n");
+
 	xtables_free_opts(1);
 
 	return 0;
-- 
2.8.2
