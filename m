From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] action pedit: stylistic changes
Date: Sun, 12 Jun 2016 17:40:34 -0400
Message-ID: <1465767634-2708-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36848 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933590AbcFLVko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 17:40:44 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so5180950ith.3
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 14:40:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

More modern layout.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_pedit.c | 118 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 62 insertions(+), 56 deletions(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index a539b68..d276ba0 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -32,8 +32,7 @@
 static struct m_pedit_util *pedit_list;
 static int pedit_debug;
 
-static void
-explain(void)
+static void explain(void)
 {
 	fprintf(stderr, "Usage: ... pedit munge <MUNGE> [CONTROL]\n");
 	fprintf(stderr,
@@ -48,22 +47,24 @@ explain(void)
 
 }
 
-static void
-usage(void)
+static void usage(void)
 {
 	explain();
 	exit(-1);
 }
 
-static int
-pedit_parse_nopopt (int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+static int pedit_parse_nopopt(int *argc_p, char ***argv_p,
+			      struct tc_pedit_sel *sel,
+			      struct tc_pedit_key *tkey)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
 
 	if (argc) {
-		fprintf(stderr, "Unknown action  hence option \"%s\" is unparsable\n", *argv);
-			return -1;
+		fprintf(stderr,
+			"Unknown action  hence option \"%s\" is unparsable\n",
+			*argv);
+		return -1;
 	}
 
 	return 0;
@@ -75,7 +76,7 @@ static struct m_pedit_util *get_pedit_kind(const char *str)
 	static void *pBODY;
 	void *dlh;
 	char buf[256];
-	struct  m_pedit_util *p;
+	struct m_pedit_util *p;
 
 	for (p = pedit_list; p; p = p->next) {
 		if (strcmp(p->id, str) == 0)
@@ -107,15 +108,14 @@ noexist:
 	p = malloc(sizeof(*p));
 	if (p) {
 		memset(p, 0, sizeof(*p));
-		strncpy(p->id, str, sizeof(p->id)-1);
+		strncpy(p->id, str, sizeof(p->id) - 1);
 		p->parse_peopt = pedit_parse_nopopt;
 		goto reg;
 	}
 	return p;
 }
 
-int
-pack_key(struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key(struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 {
 	int hwm = sel->nkeys;
 
@@ -137,9 +137,8 @@ pack_key(struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 	return 0;
 }
 
-
-int
-pack_key32(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key32(__u32 retain, struct tc_pedit_sel *sel,
+	       struct tc_pedit_key *tkey)
 {
 	if (tkey->off > (tkey->off & ~3)) {
 		fprintf(stderr,
@@ -152,11 +151,11 @@ pack_key32(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 	return pack_key(sel, tkey);
 }
 
-int
-pack_key16(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key16(__u32 retain, struct tc_pedit_sel *sel,
+	       struct tc_pedit_key *tkey)
 {
 	int ind, stride;
-	__u32 m[4] = {0x0000FFFF, 0xFF0000FF, 0xFFFF0000};
+	__u32 m[4] = { 0x0000FFFF, 0xFF0000FF, 0xFFFF0000 };
 
 	if (tkey->val > 0xFFFF || tkey->mask > 0xFFFF) {
 		fprintf(stderr, "pack_key16 bad value\n");
@@ -177,19 +176,20 @@ pack_key16(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 	tkey->off &= ~3;
 
 	if (pedit_debug)
-		printf("pack_key16: Final val %08x mask %08x\n", tkey->val, tkey->mask);
+		printf("pack_key16: Final val %08x mask %08x\n",
+		       tkey->val, tkey->mask);
 	return pack_key(sel, tkey);
 
 }
 
-int
-pack_key8(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int pack_key8(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 {
 	int ind, stride;
-	__u32 m[4] = {0x00FFFFFF, 0xFF00FFFF, 0xFFFF00FF, 0xFFFFFF00};
+	__u32 m[4] = { 0x00FFFFFF, 0xFF00FFFF, 0xFFFF00FF, 0xFFFFFF00 };
 
 	if (tkey->val > 0xFF || tkey->mask > 0xFF) {
-		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n", tkey->val, tkey->mask);
+		fprintf(stderr, "pack_key8 bad value (val %x mask %x\n",
+			tkey->val, tkey->mask);
 		return -1;
 	}
 
@@ -202,12 +202,12 @@ pack_key8(__u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 	tkey->off &= ~3;
 
 	if (pedit_debug)
-		printf("pack_key8: Final word off %d  val %08x mask %08x\n", tkey->off, tkey->val, tkey->mask);
+		printf("pack_key8: Final word off %d  val %08x mask %08x\n",
+		       tkey->off, tkey->val, tkey->mask);
 	return pack_key(sel, tkey);
 }
 
-int
-parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
+int parse_val(int *argc_p, char ***argv_p, __u32 * val, int type)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
@@ -216,7 +216,7 @@ parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 		return -1;
 
 	if (type == TINT)
-		return get_integer((int *) val, *argv, 0);
+		return get_integer((int *)val, *argv, 0);
 
 	if (type == TU32)
 		return get_u32(val, *argv, 0);
@@ -238,8 +238,8 @@ parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 	return -1;
 }
 
-int
-parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
+	      struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
 {
 	__u32 mask = 0, val = 0;
 	__u32 o = 0xFF;
@@ -251,7 +251,8 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain, struct
 		return -1;
 
 	if (pedit_debug)
-		printf("parse_cmd argc %d %s offset %d length %d\n", argc, *argv, tkey->off, len);
+		printf("parse_cmd argc %d %s offset %d length %d\n",
+		       argc, *argv, tkey->off, len);
 
 	if (len == 2)
 		o = 0xFFFF;
@@ -271,13 +272,15 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain, struct
 			return -1;
 	}
 
-	argc--; argv++;
+	argc--;
+	argv++;
 
 	if (argc && matches(*argv, "retain") == 0) {
 		NEXT_ARG();
 		if (parse_val(&argc, &argv, &retain, TU32))
 			return -1;
-		argc--; argv++;
+		argc--;
+		argv++;
 	}
 
 	tkey->val = val;
@@ -302,15 +305,16 @@ parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain, struct
 	return -1;
 done:
 	if (pedit_debug)
-		printf("parse_cmd done argc %d %s offset %d length %d\n", argc, *argv, tkey->off, len);
+		printf("parse_cmd done argc %d %s offset %d length %d\n",
+		       argc, *argv, tkey->off, len);
 	*argc_p = argc;
 	*argv_p = argv;
 	return res;
 
 }
 
-int
-parse_offset(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pedit_key *tkey)
+int parse_offset(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel,
+		 struct tc_pedit_key *tkey)
 {
 	int off;
 	__u32 len, retain;
@@ -331,7 +335,6 @@ parse_offset(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel, struct tc_pe
 	if (argc <= 0)
 		return -1;
 
-
 	if (matches(*argv, "u32") == 0) {
 		len = 4;
 		retain = 0xFFFFFFFF;
@@ -386,8 +389,7 @@ done:
 	return res;
 }
 
-static int
-parse_munge(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel)
+static int parse_munge(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel)
 {
 	struct tc_pedit_key tkey;
 	int argc = *argc_p;
@@ -433,8 +435,8 @@ done:
 	return res;
 }
 
-int
-parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
+		struct nlmsghdr *n)
 {
 	struct {
 		struct tc_pedit_sel sel;
@@ -459,13 +461,15 @@ parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, stru
 			usage();
 		} else if (matches(*argv, "munge") == 0) {
 			if (!ok) {
-				fprintf(stderr, "Illegal pedit construct (%s)\n", *argv);
+				fprintf(stderr, "Bad pedit construct (%s)\n",
+					*argv);
 				explain();
 				return -1;
 			}
 			NEXT_ARG();
 			if (parse_munge(&argc, &argv, &sel.sel)) {
-				fprintf(stderr, "Illegal pedit construct (%s)\n", *argv);
+				fprintf(stderr, "Bad pedit construct (%s)\n",
+					*argv);
 				explain();
 				return -1;
 			}
@@ -489,7 +493,7 @@ parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, stru
 			sel.sel.action = TC_ACT_PIPE;
 			NEXT_ARG();
 		} else if (matches(*argv, "drop") == 0 ||
-			matches(*argv, "shot") == 0) {
+			   matches(*argv, "shot") == 0) {
 			sel.sel.action = TC_ACT_SHOT;
 			NEXT_ARG();
 		} else if (matches(*argv, "continue") == 0) {
@@ -517,16 +521,17 @@ parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, stru
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
-	addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS, &sel, sizeof(sel.sel)+sel.sel.nkeys*sizeof(struct tc_pedit_key));
-	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
+	addattr_l(n, MAX_MSG, TCA_PEDIT_PARMS, &sel,
+		  sizeof(sel.sel) +
+		  sel.sel.nkeys * sizeof(struct tc_pedit_key));
+	tail->rta_len = (void *)NLMSG_TAIL(n) - (void *)tail;
 
 	*argc_p = argc;
 	*argv_p = argv;
 	return 0;
 }
 
-int
-print_pedit(struct action_util *au, FILE * f, struct rtattr *arg)
+int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct tc_pedit_sel *sel;
 	struct rtattr *tb[TCA_PEDIT_MAX + 1];
@@ -544,8 +549,10 @@ print_pedit(struct action_util *au, FILE * f, struct rtattr *arg)
 	}
 	sel = RTA_DATA(tb[TCA_PEDIT_PARMS]);
 
-	fprintf(f, " pedit action %s keys %d\n ", action_n2a(sel->action, b1, sizeof (b1)), sel->nkeys);
-	fprintf(f, "\t index %d ref %d bind %d", sel->index, sel->refcnt, sel->bindcnt);
+	fprintf(f, " pedit action %s keys %d\n ",
+		action_n2a(sel->action, b1, sizeof(b1)), sel->nkeys);
+	fprintf(f, "\t index %d ref %d bind %d", sel->index, sel->refcnt,
+		sel->bindcnt);
 
 	if (show_stats) {
 		if (tb[TCA_PEDIT_TM]) {
@@ -561,21 +568,20 @@ print_pedit(struct action_util *au, FILE * f, struct rtattr *arg)
 		for (i = 0; i < sel->nkeys; i++, key++) {
 			fprintf(f, "\n\t key #%d", i);
 			fprintf(f, "  at %d: val %08x mask %08x",
-			(unsigned int)key->off,
-			(unsigned int)ntohl(key->val),
-			(unsigned int)ntohl(key->mask));
+				(unsigned int)key->off,
+				(unsigned int)ntohl(key->val),
+				(unsigned int)ntohl(key->mask));
 		}
 	} else {
-		fprintf(f, "\npedit %x keys %d is not LEGIT", sel->index, sel->nkeys);
+		fprintf(f, "\npedit %x keys %d is not LEGIT", sel->index,
+			sel->nkeys);
 	}
 
-
 	fprintf(f, "\n ");
 	return 0;
 }
 
-int
-pedit_print_xstats(struct action_util *au, FILE *f, struct rtattr *xstats)
+int pedit_print_xstats(struct action_util *au, FILE *f, struct rtattr *xstats)
 {
 	return 0;
 }
-- 
1.9.1
