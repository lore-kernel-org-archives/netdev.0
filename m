From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc: pass correct conversion specifier to print 'unsigned int' action index.
Date: Tue, 13 Dec 2016 15:31:16 -0500
Message-ID: <1481661076-28962-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33621 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938386AbcLMUcQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 15:32:16 -0500
Received: by mail-io0-f194.google.com with SMTP id p13so491090ioi.0
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 12:31:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_bpf.c      | 2 +-
 tc/m_connmark.c | 2 +-
 tc/m_csum.c     | 3 ++-
 tc/m_gact.c     | 3 ++-
 tc/m_ife.c      | 2 +-
 tc/m_ipt.c      | 2 +-
 tc/m_mirred.c   | 3 ++-
 tc/m_pedit.c    | 2 +-
 tc/m_simple.c   | 2 +-
 tc/m_skbedit.c  | 2 +-
 tc/m_skbmod.c   | 2 +-
 tc/m_vlan.c     | 2 +-
 tc/m_xt.c       | 2 +-
 tc/m_xt_old.c   | 2 +-
 14 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 9bf2a85..6400724 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -161,7 +161,7 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 
 	fprintf(f, "default-action %s\n", action_n2a(parm->action));
-	fprintf(f, "\tindex %d ref %d bind %d", parm->index, parm->refcnt,
+	fprintf(f, "\tindex %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 20f98e4..295f90d 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -123,7 +123,7 @@ static int print_connmark(struct action_util *au, FILE *f, struct rtattr *arg)
 	ci = RTA_DATA(tb[TCA_CONNMARK_PARMS]);
 
 	fprintf(f, " connmark zone %d\n", ci->zone);
-	fprintf(f, "\t index %d ref %d bind %d", ci->index,
+	fprintf(f, "\t index %u ref %d bind %d", ci->index,
 		ci->refcnt, ci->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_csum.c b/tc/m_csum.c
index a6e4c1e..d5b1af6 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -199,7 +199,8 @@ print_csum(struct action_util *au, FILE *f, struct rtattr *arg)
 		uflag_1, uflag_2, uflag_3,
 		uflag_4, uflag_5, uflag_6,
 		action_n2a(sel->action));
-	fprintf(f, "\tindex %d ref %d bind %d", sel->index, sel->refcnt, sel->bindcnt);
+	fprintf(f, "\tindex %u ref %d bind %d", sel->index, sel->refcnt,
+		sel->bindcnt);
 
 	if (show_stats) {
 		if (tb[TCA_CSUM_TM]) {
diff --git a/tc/m_gact.c b/tc/m_gact.c
index dc04b9f..755a3be 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -224,7 +224,8 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 	fprintf(f, "\n\t random type %s %s val %d",
 		prob_n2a(pp->ptype), action_n2a(pp->paction), pp->pval);
 #endif
-	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
+	fprintf(f, "\n\t index %u ref %d bind %d", p->index, p->refcnt,
+		p->bindcnt);
 	if (show_stats) {
 		if (tb[TCA_GACT_TM]) {
 			struct tcf_t *tm = RTA_DATA(tb[TCA_GACT_TM]);
diff --git a/tc/m_ife.c b/tc/m_ife.c
index e6f6153..f6131b1 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -312,7 +312,7 @@ static int print_ife(struct action_util *au, FILE *f, struct rtattr *arg)
 				    sizeof(b2)));
 	}
 
-	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt,
+	fprintf(f, "\n\t index %u ref %d bind %d", p->index, p->refcnt,
 		p->bindcnt);
 	if (show_stats) {
 		if (tb[TCA_IFE_TM]) {
diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index d6f62bd..1b935ec 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -489,7 +489,7 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 			__u32 index;
 
 			index = rta_getattr_u32(tb[TCA_IPT_INDEX]);
-			fprintf(f, "\n\tindex %d", index);
+			fprintf(f, "\n\tindex %u", index);
 		}
 
 		if (tb[TCA_IPT_CNT]) {
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 11f4c9b..35ae21f 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -260,7 +260,8 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
 		mirred_n2a(p->eaction), dev, action_n2a(p->action));
 
 	fprintf(f, "\n ");
-	fprintf(f, "\tindex %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
+	fprintf(f, "\tindex %u ref %d bind %d", p->index, p->refcnt,
+		p->bindcnt);
 
 	if (show_stats) {
 		if (tb[TCA_MIRRED_TM]) {
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 891c2ec..8e9bf07 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -527,7 +527,7 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 
 	fprintf(f, " pedit action %s keys %d\n ",
 		action_n2a(sel->action), sel->nkeys);
-	fprintf(f, "\t index %d ref %d bind %d", sel->index, sel->refcnt,
+	fprintf(f, "\t index %u ref %d bind %d", sel->index, sel->refcnt,
 		sel->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_simple.c b/tc/m_simple.c
index 732eaf1..3a8bd91 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -187,7 +187,7 @@ static int print_simple(struct action_util *au, FILE *f, struct rtattr *arg)
 	simpdata = RTA_DATA(tb[TCA_DEF_DATA]);
 
 	fprintf(f, "Simple <%s>\n", simpdata);
-	fprintf(f, "\t index %d ref %d bind %d", sel->index,
+	fprintf(f, "\t index %u ref %d bind %d", sel->index,
 		sel->refcnt, sel->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 368debc..8660d60 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -214,7 +214,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 			fprintf(f, " ptype %d", *ptype);
 	}
 
-	fprintf(f, "\n\t index %d ref %d bind %d",
+	fprintf(f, "\n\t index %u ref %d bind %d",
 		p->index, p->refcnt, p->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_skbmod.c b/tc/m_skbmod.c
index 0c293fc..acb7771 100644
--- a/tc/m_skbmod.c
+++ b/tc/m_skbmod.c
@@ -237,7 +237,7 @@ static int print_skbmod(struct action_util *au, FILE *f, struct rtattr *arg)
 	if (p->flags & SKBMOD_F_SWAPMAC)
 		fprintf(f, "swap mac ");
 
-	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt,
+	fprintf(f, "\n\t index %u ref %d bind %d", p->index, p->refcnt,
 		p->bindcnt);
 	if (show_stats) {
 		if (tb[TCA_SKBMOD_TM]) {
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index b32f746..44b9375 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -226,7 +226,7 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 	}
 	fprintf(f, " %s", action_n2a(parm->action));
 
-	fprintf(f, "\n\t index %d ref %d bind %d", parm->index, parm->refcnt,
+	fprintf(f, "\n\t index %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/m_xt.c b/tc/m_xt.c
index 028bad6..dbb5498 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -372,7 +372,7 @@ print_ipt(struct action_util *au, FILE *f, struct rtattr *arg)
 		__u32 index;
 
 		index = rta_getattr_u32(tb[TCA_IPT_INDEX]);
-		fprintf(f, "\n\tindex %d", index);
+		fprintf(f, "\n\tindex %u", index);
 	}
 
 	if (tb[TCA_IPT_CNT]) {
diff --git a/tc/m_xt_old.c b/tc/m_xt_old.c
index 20a6342..e9cc624 100644
--- a/tc/m_xt_old.c
+++ b/tc/m_xt_old.c
@@ -412,7 +412,7 @@ print_ipt(struct action_util *au, FILE * f, struct rtattr *arg)
 			__u32 index;
 
 			index = rta_getattr_u32(tb[TCA_IPT_INDEX]);
-			fprintf(f, "\n\tindex %d", index);
+			fprintf(f, "\n\tindex %u", index);
 		}
 
 		if (tb[TCA_IPT_CNT]) {
-- 
1.9.1
