From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 2/2] tc filters: fix filters to display handle when deleted even when no option
Date: Mon, 17 Oct 2016 05:34:45 -0400
Message-ID: <1476696885-22214-2-git-send-email-jhs@emojatatu.com>
References: <1476696885-22214-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, mrv@mojatatu.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34295 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932727AbcJQJe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 05:34:58 -0400
Received: by mail-it0-f67.google.com with SMTP id e203so3294015itc.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 02:34:58 -0700 (PDT)
In-Reply-To: <1476696885-22214-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Fix a few stylistic things that hurt my eyes while at it.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_basic.c    |  6 +++---
 tc/f_bpf.c      |  6 +++---
 tc/f_cgroup.c   |  7 +++----
 tc/f_flow.c     |  4 ++--
 tc/f_flower.c   |  5 +++--
 tc/f_fw.c       | 38 ++++++++++++++++++++++----------------
 tc/f_matchall.c |  6 +++---
 tc/f_route.c    | 29 ++++++++++++++++++-----------
 tc/f_rsvp.c     | 28 ++++++++++++++++++----------
 tc/f_tcindex.c  |  4 +++-
 tc/f_u32.c      |  9 ++++-----
 11 files changed, 82 insertions(+), 60 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index d663668..317dca1 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -112,14 +112,14 @@ static int basic_print_opt(struct filter_util *qu, FILE *f,
 {
 	struct rtattr *tb[TCA_BASIC_MAX+1];
 
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_BASIC_MAX, opt);
 
-	if (handle)
-		fprintf(f, "handle 0x%x ", handle);
-
 	if (tb[TCA_BASIC_CLASSID]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "flowid %s ",
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 5c97c86..a7dd2f2 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -152,14 +152,14 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 {
 	struct rtattr *tb[TCA_BPF_MAX + 1];
 
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_BPF_MAX, opt);
 
-	if (handle)
-		fprintf(f, "handle 0x%x ", handle);
-
 	if (tb[TCA_BPF_CLASSID]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "flowid %s ",
diff --git a/tc/f_cgroup.c b/tc/f_cgroup.c
index ecf9909..ae798db 100644
--- a/tc/f_cgroup.c
+++ b/tc/f_cgroup.c
@@ -85,14 +85,13 @@ static int cgroup_print_opt(struct filter_util *qu, FILE *f,
 {
 	struct rtattr *tb[TCA_CGROUP_MAX+1];
 
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_CGROUP_MAX, opt);
-
-	if (handle)
-		fprintf(f, "handle 0x%x ", handle);
-
 	if (tb[TCA_CGROUP_EMATCHES])
 		print_ematch(f, tb[TCA_CGROUP_EMATCHES]);
 
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 09ddcaa..5a9948f 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -272,13 +272,13 @@ static int flow_print_opt(struct filter_util *fu, FILE *f, struct rtattr *opt,
 	unsigned int i;
 	__u32 mask = ~0, val = 0;
 
+	fprintf(f, "handle 0x%x ", handle);
+
 	if (opt == NULL)
 		return -EINVAL;
 
 	parse_rtattr_nested(tb, TCA_FLOW_MAX, opt);
 
-	fprintf(f, "handle 0x%x ", handle);
-
 	if (tb[TCA_FLOW_MODE]) {
 		__u32 mode = rta_getattr_u32(tb[TCA_FLOW_MODE]);
 
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 791ade7..2f566ec 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -456,13 +456,14 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	__be16 eth_type = 0;
 	__u8 ip_proto = 0xff;
 
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
 	if (!opt)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_FLOWER_MAX, opt);
 
-	if (handle)
-		fprintf(f, "handle 0x%x ", handle);
 
 	if (tb[TCA_FLOWER_CLASSID]) {
 		SPRINT_BUF(b1);
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 29c9854..f779c16 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -115,37 +115,42 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 	return 0;
 }
 
-static int fw_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, __u32 handle)
+static int fw_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
+			__u32 handle)
 {
 	struct rtattr *tb[TCA_FW_MAX+1];
+	__u32 mark = 0, mask = 0;
 
-	if (opt == NULL)
-		return 0;
+	if (opt) {
+		parse_rtattr_nested(tb, TCA_FW_MAX, opt);
+		if (tb[TCA_FW_MASK]) {
+		   __u32 tmask = rta_getattr_u32(tb[TCA_FW_MASK]);
 
-	parse_rtattr_nested(tb, TCA_FW_MAX, opt);
+		   if (tmask != 0xFFFFFFFF)
+			   mask = tmask;
+		}
+	}
 
-	if (handle || tb[TCA_FW_MASK]) {
-		__u32 mark = 0, mask = 0;
+	if (mask)
+		fprintf(f, "handle 0x%x/0x%x ", mark, mask);
+	else
+		fprintf(f, "handle 0x%x ", handle);
 
-		if (handle)
-			mark = handle;
-		if (tb[TCA_FW_MASK] &&
-		    (mask = rta_getattr_u32(tb[TCA_FW_MASK])) != 0xFFFFFFFF)
-			fprintf(f, "handle 0x%x/0x%x ", mark, mask);
-		else
-			fprintf(f, "handle 0x%x ", handle);
-	}
+	if (opt == NULL)
+		return 0;
 
 	if (tb[TCA_FW_CLASSID]) {
 		SPRINT_BUF(b1);
-		fprintf(f, "classid %s ", sprint_tc_classid(rta_getattr_u32(tb[TCA_FW_CLASSID]), b1));
+		fprintf(f, "classid %s ",
+			sprint_tc_classid(rta_getattr_u32(tb[TCA_FW_CLASSID]),
+					  b1));
 	}
 
 	if (tb[TCA_FW_POLICE])
 		tc_print_police(f, tb[TCA_FW_POLICE]);
+
 	if (tb[TCA_FW_INDEV]) {
 		struct rtattr *idev = tb[TCA_FW_INDEV];
-
 		fprintf(f, "input dev %s ", rta_getattr_str(idev));
 	}
 
@@ -153,6 +158,7 @@ static int fw_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, __u
 		fprintf(f, "\n");
 		tc_print_action(f, tb[TCA_FW_ACT]);
 	}
+
 	return 0;
 }
 
diff --git a/tc/f_matchall.c b/tc/f_matchall.c
index 04e524e..006eb70 100644
--- a/tc/f_matchall.c
+++ b/tc/f_matchall.c
@@ -116,14 +116,14 @@ static int matchall_print_opt(struct filter_util *qu, FILE *f,
 {
 	struct rtattr *tb[TCA_MATCHALL_MAX+1];
 
+	if (handle)
+		fprintf(f, "handle 0x%x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_MATCHALL_MAX, opt);
 
-	if (handle)
-		fprintf(f, "handle 0x%x ", handle);
-
 	if (tb[TCA_MATCHALL_CLASSID]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "flowid %s ",
diff --git a/tc/f_route.c b/tc/f_route.c
index 5c600b9..5d1ea17 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -34,7 +34,8 @@ static void explain(void)
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
-static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
+static int route_parse_opt(struct filter_util *qu, char *handle, int argc,
+			   char **argv, struct nlmsghdr *n)
 {
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
@@ -139,32 +140,38 @@ static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char
 	return 0;
 }
 
-static int route_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, __u32 handle)
+static int route_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
+			   __u32 handle)
 {
 	struct rtattr *tb[TCA_ROUTE4_MAX+1];
 
 	SPRINT_BUF(b1);
 
-	if (opt == NULL)
-		return 0;
-
-	parse_rtattr_nested(tb, TCA_ROUTE4_MAX, opt);
-
 	if (handle)
 		fprintf(f, "fh 0x%08x ", handle);
 	if (handle&0x7F00)
 		fprintf(f, "order %d ", (handle>>8)&0x7F);
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_ROUTE4_MAX, opt);
 
 	if (tb[TCA_ROUTE4_CLASSID]) {
 		SPRINT_BUF(b1);
-		fprintf(f, "flowid %s ", sprint_tc_classid(rta_getattr_u32(tb[TCA_ROUTE4_CLASSID]), b1));
+		fprintf(f, "flowid %s ",
+			sprint_tc_classid(rta_getattr_u32(tb[TCA_ROUTE4_CLASSID]), b1));
 	}
 	if (tb[TCA_ROUTE4_TO])
-		fprintf(f, "to %s ", rtnl_rtrealm_n2a(rta_getattr_u32(tb[TCA_ROUTE4_TO]), b1, sizeof(b1)));
+		fprintf(f, "to %s ",
+			rtnl_rtrealm_n2a(rta_getattr_u32(tb[TCA_ROUTE4_TO]),
+					 b1, sizeof(b1)));
 	if (tb[TCA_ROUTE4_FROM])
-		fprintf(f, "from %s ", rtnl_rtrealm_n2a(rta_getattr_u32(tb[TCA_ROUTE4_FROM]), b1, sizeof(b1)));
+		fprintf(f, "from %s ",
+			rtnl_rtrealm_n2a(rta_getattr_u32(tb[TCA_ROUTE4_FROM]),
+					 b1, sizeof(b1)));
 	if (tb[TCA_ROUTE4_IIF])
-		fprintf(f, "fromif %s", ll_index_to_name(*(int *)RTA_DATA(tb[TCA_ROUTE4_IIF])));
+		fprintf(f, "fromif %s",
+			ll_index_to_name(*(int *)RTA_DATA(tb[TCA_ROUTE4_IIF])));
 	if (tb[TCA_ROUTE4_POLICE])
 		tc_print_police(f, tb[TCA_ROUTE4_POLICE]);
 	if (tb[TCA_ROUTE4_ACT])
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 94bfbef..fae70cc 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -325,20 +325,21 @@ static char *sprint_spi(struct tc_rsvp_gpi *pi, int dir, char *buf)
 	return buf;
 }
 
-static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, __u32 handle)
+static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
+			  __u32 handle)
 {
 	int family = strcmp(qu->id, "rsvp") == 0 ? AF_INET : AF_INET6;
 	struct rtattr *tb[TCA_RSVP_MAX+1];
 	struct tc_rsvp_pinfo *pinfo = NULL;
 
+	if (handle)
+		fprintf(f, "fh 0x%08x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_RSVP_MAX, opt);
 
-	if (handle)
-		fprintf(f, "fh 0x%08x ", handle);
-
 	if (tb[TCA_RSVP_PINFO]) {
 		if (RTA_PAYLOAD(tb[TCA_RSVP_PINFO])  < sizeof(*pinfo))
 			return -1;
@@ -349,9 +350,12 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 	if (tb[TCA_RSVP_CLASSID]) {
 		SPRINT_BUF(b1);
 		if (!pinfo || pinfo->tunnelhdr == 0)
-			fprintf(f, "flowid %s ", sprint_tc_classid(rta_getattr_u32(tb[TCA_RSVP_CLASSID]), b1));
+			fprintf(f, "flowid %s ",
+				sprint_tc_classid(rta_getattr_u32(tb[TCA_RSVP_CLASSID]), b1));
 		else
-			fprintf(f, "tunnel %d skip %d ", rta_getattr_u32(tb[TCA_RSVP_CLASSID]), pinfo->tunnelhdr);
+			fprintf(f, "tunnel %d skip %d ",
+				rta_getattr_u32(tb[TCA_RSVP_CLASSID]),
+				pinfo->tunnelhdr);
 	} else if (pinfo && pinfo->tunnelhdr)
 		fprintf(f, "tunnel [BAD] skip %d ", pinfo->tunnelhdr);
 
@@ -359,7 +363,8 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 		char buf[128];
 
 		fprintf(f, "session ");
-		if (inet_ntop(family, RTA_DATA(tb[TCA_RSVP_DST]), buf, sizeof(buf)) == 0)
+		if (inet_ntop(family, RTA_DATA(tb[TCA_RSVP_DST]), buf,
+			      sizeof(buf)) == 0)
 			fprintf(f, " [INVALID DADDR] ");
 		else
 			fprintf(f, "%s", buf);
@@ -371,14 +376,16 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 	} else {
 		if (pinfo && pinfo->dpi.mask) {
 			SPRINT_BUF(b2);
-			fprintf(f, "session [NONE]%s ", sprint_spi(&pinfo->dpi, 1, b2));
+			fprintf(f, "session [NONE]%s ",
+				sprint_spi(&pinfo->dpi, 1, b2));
 		} else
 			fprintf(f, "session NONE ");
 	}
 
 	if (pinfo && pinfo->protocol) {
 		SPRINT_BUF(b1);
-		fprintf(f, "ipproto %s ", inet_proto_n2a(pinfo->protocol, b1, sizeof(b1)));
+		fprintf(f, "ipproto %s ", inet_proto_n2a(pinfo->protocol, b1,
+							 sizeof(b1)));
 	}
 	if (pinfo && pinfo->tunnelid)
 		fprintf(f, "tunnelid %d ", pinfo->tunnelid);
@@ -386,7 +393,8 @@ static int rsvp_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt, _
 		char buf[128];
 
 		fprintf(f, "sender ");
-		if (inet_ntop(family, RTA_DATA(tb[TCA_RSVP_SRC]), buf, sizeof(buf)) == 0) {
+		if (inet_ntop(family, RTA_DATA(tb[TCA_RSVP_SRC]), buf,
+			      sizeof(buf)) == 0) {
 			fprintf(f, "[BAD]");
 		} else {
 			fprintf(f, " %s", buf);
diff --git a/tc/f_tcindex.c b/tc/f_tcindex.c
index 32bccb0..8b6f0e8 100644
--- a/tc/f_tcindex.c
+++ b/tc/f_tcindex.c
@@ -123,12 +123,14 @@ static int tcindex_print_opt(struct filter_util *qu, FILE *f,
 {
 	struct rtattr *tb[TCA_TCINDEX_MAX+1];
 
+	if (handle != ~0)
+		fprintf(f, "handle 0x%04x ", handle);
+
 	if (opt == NULL)
 		return 0;
 
 	parse_rtattr_nested(tb, TCA_TCINDEX_MAX, opt);
 
-	if (handle != ~0) fprintf(f, "handle 0x%04x ", handle);
 	if (tb[TCA_TCINDEX_HASH]) {
 		__u16 hash;
 
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 0ad7ed2..3b107cc 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1210,16 +1210,15 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	struct tc_u32_sel *sel = NULL;
 	struct tc_u32_pcnt *pf = NULL;
 
-	if (opt == NULL)
-		return 0;
-
-	parse_rtattr_nested(tb, TCA_U32_MAX, opt);
-
 	if (handle) {
 		SPRINT_BUF(b1);
 		fprintf(f, "fh %s ", sprint_u32_handle(handle, b1));
 	}
 
+	if (opt == NULL)
+		return 0;
+
+	parse_rtattr_nested(tb, TCA_U32_MAX, opt);
 	if (TC_U32_NODE(handle))
 		fprintf(f, "order %d ", TC_U32_NODE(handle));
 
-- 
1.9.1
