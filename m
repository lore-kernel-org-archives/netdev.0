From: Patrick McHardy <kaber@trash.net>
Subject: [IPROUTE]: Use FRA_* attributes for routing rules
Date: Thu, 15 Mar 2007 04:38:52 +0100
Message-ID: <45F8BFCC.60502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000201050302030404050400"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52934 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964962AbXCODiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 23:38:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000201050302030404050400
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------000201050302030404050400
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[IPROUTE]: Use FRA_* attributes for routing rules

Use the FRA attributes for routing rules, with exception of RTA_GATEWAY
(used for route-NAT) which isn't supported by current kernels anymore
and thus doesn't exist as FRA attribute.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 75f9b78e5ef1f16fc8e42375b9951083da522289
tree de357a8517cb64acd9608f20dc7ab34f7b6ff13a
parent 7081c45d9713f2ed1aeacdf8d0ff830bfce164f2
author Patrick McHardy <kaber@trash.net> Thu, 15 Mar 2007 04:36:49 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 15 Mar 2007 04:36:49 +0100

 ip/iprule.c |   68 ++++++++++++++++++++++++++++++-----------------------------
 1 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 0aa115a..724bd45 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -53,7 +53,7 @@ int print_rule(const struct sockaddr_nl 
 	int len = n->nlmsg_len;
 	int host_len = -1;
 	__u32 table;
-	struct rtattr * tb[RTA_MAX+1];
+	struct rtattr * tb[FRA_MAX+1];
 	char abuf[256];
 	SPRINT_BUF(b1);
 
@@ -64,7 +64,7 @@ int print_rule(const struct sockaddr_nl 
 	if (len < 0)
 		return -1;
 
-	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+	parse_rtattr(tb, FRA_MAX, RTM_RTA(r), len);
 
 	if (r->rtm_family == AF_INET)
 		host_len = 32;
@@ -78,26 +78,26 @@ int print_rule(const struct sockaddr_nl 
 	if (n->nlmsg_type == RTM_DELRULE)
 		fprintf(fp, "Deleted ");
 
-	if (tb[RTA_PRIORITY])
-		fprintf(fp, "%u:\t", *(unsigned*)RTA_DATA(tb[RTA_PRIORITY]));
+	if (tb[FRA_PRIORITY])
+		fprintf(fp, "%u:\t", *(unsigned*)RTA_DATA(tb[FRA_PRIORITY]));
 	else
 		fprintf(fp, "0:\t");
 
 	if (r->rtm_flags & FIB_RULE_INVERT)
 		fprintf(fp, "not ");
 
-	if (tb[RTA_SRC]) {
+	if (tb[FRA_SRC]) {
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_PAYLOAD(tb[RTA_SRC]),
-							 RTA_DATA(tb[RTA_SRC]),
+							 RTA_PAYLOAD(tb[FRA_SRC]),
+							 RTA_DATA(tb[FRA_SRC]),
 							 abuf, sizeof(abuf)),
 				r->rtm_src_len
 				);
 		} else {
 			fprintf(fp, "from %s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_SRC]),
-						       RTA_DATA(tb[RTA_SRC]),
+						       RTA_PAYLOAD(tb[FRA_SRC]),
+						       RTA_DATA(tb[FRA_SRC]),
 						       abuf, sizeof(abuf))
 				);
 		}
@@ -107,18 +107,18 @@ int print_rule(const struct sockaddr_nl 
 		fprintf(fp, "from all ");
 	}
 
-	if (tb[RTA_DST]) {
+	if (tb[FRA_DST]) {
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "to %s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_PAYLOAD(tb[RTA_DST]),
-							 RTA_DATA(tb[RTA_DST]),
+							 RTA_PAYLOAD(tb[FRA_DST]),
+							 RTA_DATA(tb[FRA_DST]),
 							 abuf, sizeof(abuf)),
 				r->rtm_dst_len
 				);
 		} else {
 			fprintf(fp, "to %s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_DST]),
-						       RTA_DATA(tb[RTA_DST]),
+						       RTA_PAYLOAD(tb[FRA_DST]),
+						       RTA_DATA(tb[FRA_DST]),
 						       abuf, sizeof(abuf)));
 		}
 	} else if (r->rtm_dst_len) {
@@ -129,29 +129,29 @@ int print_rule(const struct sockaddr_nl 
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
 	}
-	if (tb[RTA_PROTOINFO] || tb[RTA_FWMASK]) {
+	if (tb[FRA_FWMARK] || tb[FRA_FWMASK]) {
 		__u32 mark = 0, mask = 0;
 
-		if (tb[RTA_PROTOINFO])
-			mark = *(__u32*)RTA_DATA(tb[RTA_PROTOINFO]);
+		if (tb[FRA_FWMARK])
+			mark = *(__u32*)RTA_DATA(tb[FRA_FWMARK]);
 
-		if (tb[RTA_FWMASK] &&
-		    (mask = *(__u32*)RTA_DATA(tb[RTA_FWMASK])) != 0xFFFFFFFF)
+		if (tb[FRA_FWMASK] &&
+		    (mask = *(__u32*)RTA_DATA(tb[FRA_FWMASK])) != 0xFFFFFFFF)
 			fprintf(fp, "fwmark 0x%x/0x%x ", mark, mask);
 		else
 			fprintf(fp, "fwmark 0x%x ", mark);
 	}
 
-	if (tb[RTA_IIF]) {
-		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[RTA_IIF]));
+	if (tb[FRA_IFNAME]) {
+		fprintf(fp, "iif %s ", (char*)RTA_DATA(tb[FRA_IFNAME]));
 	}
 
 	table = rtm_get_table(r, tb);
 	if (table)
 		fprintf(fp, "lookup %s ", rtnl_rttable_n2a(table, b1, sizeof(b1)));
 
-	if (tb[RTA_FLOW]) {
-		__u32 to = *(__u32*)RTA_DATA(tb[RTA_FLOW]);
+	if (tb[FRA_FLOW]) {
+		__u32 to = *(__u32*)RTA_DATA(tb[FRA_FLOW]);
 		__u32 from = to>>16;
 		to &= 0xFFFF;
 		if (from) {
@@ -239,13 +239,13 @@ static int iprule_modify(int cmd, int ar
 			NEXT_ARG();
 			get_prefix(&dst, *argv, req.r.rtm_family);
 			req.r.rtm_src_len = dst.bitlen;
-			addattr_l(&req.n, sizeof(req), RTA_SRC, &dst.data, dst.bytelen);
+			addattr_l(&req.n, sizeof(req), FRA_SRC, &dst.data, dst.bytelen);
 		} else if (strcmp(*argv, "to") == 0) {
 			inet_prefix dst;
 			NEXT_ARG();
 			get_prefix(&dst, *argv, req.r.rtm_family);
 			req.r.rtm_dst_len = dst.bitlen;
-			addattr_l(&req.n, sizeof(req), RTA_DST, &dst.data, dst.bytelen);
+			addattr_l(&req.n, sizeof(req), FRA_DST, &dst.data, dst.bytelen);
 		} else if (matches(*argv, "preference") == 0 ||
 			   matches(*argv, "order") == 0 ||
 			   matches(*argv, "priority") == 0) {
@@ -253,7 +253,7 @@ static int iprule_modify(int cmd, int ar
 			NEXT_ARG();
 			if (get_u32(&pref, *argv, 0))
 				invarg("preference value is invalid\n", *argv);
-			addattr32(&req.n, sizeof(req), RTA_PRIORITY, pref);
+			addattr32(&req.n, sizeof(req), FRA_PRIORITY, pref);
 		} else if (strcmp(*argv, "tos") == 0) {
 			__u32 tos;
 			NEXT_ARG();
@@ -268,18 +268,18 @@ static int iprule_modify(int cmd, int ar
 				*slash = '\0';
 			if (get_u32(&fwmark, *argv, 0))
 				invarg("fwmark value is invalid\n", *argv);
-			addattr32(&req.n, sizeof(req), RTA_PROTOINFO, fwmark);
+			addattr32(&req.n, sizeof(req), FRA_FWMARK, fwmark);
 			if (slash) {
 				if (get_u32(&fwmask, slash+1, 0))
 					invarg("fwmask value is invalid\n", slash+1);
-				addattr32(&req.n, sizeof(req), RTA_FWMASK, fwmask);
+				addattr32(&req.n, sizeof(req), FRA_FWMASK, fwmask);
 			}
 		} else if (matches(*argv, "realms") == 0) {
 			__u32 realm;
 			NEXT_ARG();
 			if (get_rt_realms(&realm, *argv))
 				invarg("invalid realms\n", *argv);
-			addattr32(&req.n, sizeof(req), RTA_FLOW, realm);
+			addattr32(&req.n, sizeof(req), FRA_FLOW, realm);
 		} else if (matches(*argv, "table") == 0 ||
 			   strcmp(*argv, "lookup") == 0) {
 			__u32 tid;
@@ -290,13 +290,13 @@ static int iprule_modify(int cmd, int ar
 				req.r.rtm_table = tid;
 			else {
 				req.r.rtm_table = RT_TABLE_UNSPEC;
-				addattr32(&req.n, sizeof(req), RTA_TABLE, tid);
+				addattr32(&req.n, sizeof(req), FRA_TABLE, tid);
 			}
 			table_ok = 1;
 		} else if (strcmp(*argv, "dev") == 0 ||
 			   strcmp(*argv, "iif") == 0) {
 			NEXT_ARG();
-			addattr_l(&req.n, sizeof(req), RTA_IIF, *argv, strlen(*argv)+1);
+			addattr_l(&req.n, sizeof(req), FRA_IFNAME, *argv, strlen(*argv)+1);
 		} else if (strcmp(*argv, "nat") == 0 ||
 			   matches(*argv, "map-to") == 0) {
 			NEXT_ARG();
@@ -337,15 +337,15 @@ static int flush_rule(const struct socka
 	struct rtnl_handle rth2;
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	struct rtattr * tb[RTA_MAX+1];
+	struct rtattr * tb[FRA_MAX+1];
 
 	len -= NLMSG_LENGTH(sizeof(*r));
 	if (len < 0)
 		return -1;
 
-	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+	parse_rtattr(tb, FRA_MAX, RTM_RTA(r), len);
 
-	if (tb[RTA_PRIORITY]) {
+	if (tb[FRA_PRIORITY]) {
 		n->nlmsg_type = RTM_DELRULE;
 		n->nlmsg_flags = NLM_F_REQUEST;
 

--------------000201050302030404050400--
