From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: u32 filter coding style cleanup
Date: Fri, 23 Oct 2015 19:21:23 +0200
Message-ID: <1445620883-5304-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46063 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbbJWRVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 13:21:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing spaces around operators to increase readability. Aside from
that, make "preference" match a real synonym for "tos" and "dsfield" as
it's effect was identical to them.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/f_u32.c | 56 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 27 insertions(+), 29 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index cb63869..0b97678 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -61,14 +61,14 @@ static int get_u32_handle(__u32 *handle, const char *str)
 	if (htid>=0x1000)
 		return -1;
 	if (*tmp) {
-		str = tmp+1;
+		str = tmp + 1;
 		hash = strtoul(str, &tmp, 16);
 		if (tmp == str && *str != ':' && *str != 0)
 			return -1;
 		if (hash>=0x100)
 			return -1;
 		if (*tmp) {
-			str = tmp+1;
+			str = tmp + 1;
 			nodeid = strtoul(str, &tmp, 16);
 			if (tmp == str && *str != 0)
 				return -1;
@@ -124,9 +124,9 @@ static int pack_key(struct tc_u32_sel *sel, __u32 key, __u32 mask,
 
 	for (i=0; i<hwm; i++) {
 		if (sel->keys[i].off == off && sel->keys[i].offmask == offmask) {
-			__u32 intersect = mask&sel->keys[i].mask;
+			__u32 intersect = mask & sel->keys[i].mask;
 
-			if ((key^sel->keys[i].val) & intersect)
+			if ((key ^ sel->keys[i].val) & intersect)
 				return -1;
 			sel->keys[i].val |= key;
 			sel->keys[i].mask |= mask;
@@ -346,7 +346,7 @@ static int parse_ip_addr(int *argc_p, char ***argv_p, struct tc_u32_sel *sel,
 
 	mask = 0;
 	if (addr.bitlen)
-		mask = htonl(0xFFFFFFFF<<(32-addr.bitlen));
+		mask = htonl(0xFFFFFFFF << (32 - addr.bitlen));
 	if (pack_key(sel, addr.data[0], mask, off, offmask) < 0)
 		return -1;
 	res = 0;
@@ -381,17 +381,17 @@ static int parse_ip6_addr(int *argc_p, char ***argv_p,
 	}
 
 	plen = addr.bitlen;
-	for (i=0; i<plen; i+=32) {
-//		if (((i+31)&~0x1F)<=plen) {
+	for (i = 0; i < plen; i += 32) {
+//		if (((i + 31) & ~0x1F) <= plen) {
 		if (i + 31 <= plen) {
-			res = pack_key(sel, addr.data[i/32],
-				       0xFFFFFFFF, off+4*(i/32), offmask);
+			res = pack_key(sel, addr.data[i / 32],
+				       0xFFFFFFFF, off + 4 * (i / 32), offmask);
 			if (res < 0)
 				return -1;
 		} else if (i < plen) {
-			__u32 mask = htonl(0xFFFFFFFF << (32 - (plen -i )));
-			res = pack_key(sel, addr.data[i/32],
-				       mask, off+4*(i/32), offmask);
+			__u32 mask = htonl(0xFFFFFFFF << (32 - (plen - i)));
+			res = pack_key(sel, addr.data[i / 32],
+				       mask, off + 4 * (i / 32), offmask);
 			if (res < 0)
 				return -1;
 		}
@@ -496,7 +496,8 @@ static int parse_ip(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 		NEXT_ARG();
 		res = parse_ip_addr(&argc, &argv, sel, 16);
 	} else if (strcmp(*argv, "tos") == 0 ||
-	    matches(*argv, "dsfield") == 0) {
+	    matches(*argv, "dsfield") == 0 ||
+	    matches(*argv, "precedence") == 0) {
 		NEXT_ARG();
 		res = parse_u8(&argc, &argv, sel, 1, 0);
 	} else if (strcmp(*argv, "ihl") == 0) {
@@ -505,9 +506,6 @@ static int parse_ip(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 	} else if (strcmp(*argv, "protocol") == 0) {
 		NEXT_ARG();
 		res = parse_u8(&argc, &argv, sel, 9, 0);
-	} else if (matches(*argv, "precedence") == 0) {
-		NEXT_ARG();
-		res = parse_u8(&argc, &argv, sel, 1, 0);
 	} else if (strcmp(*argv, "nofrag") == 0) {
 		argc--; argv++;
 		res = pack_key16(sel, 0, 0x3FFF, 6, 0);
@@ -1072,9 +1070,9 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			if (sample_ok)
-				htid = (htid&0xFF000)|(handle&0xFFF00000);
+				htid = (htid & 0xFF000) | (handle & 0xFFF00000);
 			else
-				htid = (handle&0xFFFFF000);
+				htid = (handle & 0xFFFFF000);
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
 			unsigned divisor = 0x100;
@@ -1103,10 +1101,10 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 				}
 				NEXT_ARG();
 			}
-			hash = sel2.sel.keys[0].val&sel2.sel.keys[0].mask;
-			hash ^= hash>>16;
-			hash ^= hash>>8;
-			htid = ((hash%divisor)<<12)|(htid&0xFFF00000);
+			hash = sel2.sel.keys[0].val & sel2.sel.keys[0].mask;
+			hash ^= hash >> 16;
+			hash ^= hash >> 8;
+			htid = ((hash % divisor) << 12) | (htid & 0xFFF00000);
 			sample_ok = 1;
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
@@ -1165,7 +1163,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 		addattr_l(n, MAX_MSG, TCA_U32_HASH, &htid, 4);
 	if (sel_ok)
 		addattr_l(n, MAX_MSG, TCA_U32_SEL, &sel,
-			  sizeof(sel.sel)+sel.sel.nkeys*sizeof(struct tc_u32_key));
+			  sizeof(sel.sel) + sel.sel.nkeys * sizeof(struct tc_u32_key));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -1173,7 +1171,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 			 __u32 handle)
 {
-	struct rtattr *tb[TCA_U32_MAX+1];
+	struct rtattr *tb[TCA_U32_MAX + 1];
 	struct tc_u32_sel *sel = NULL;
 	struct tc_u32_pcnt *pf = NULL;
 
@@ -1209,9 +1207,9 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	if (tb[TCA_U32_CLASSID]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "%sflowid %s ",
-			!sel || !(sel->flags&TC_U32_TERMINAL) ? "*" : "",
+			!sel || !(sel->flags & TC_U32_TERMINAL) ? "*" : "",
 			sprint_tc_classid(rta_getattr_u32(tb[TCA_U32_CLASSID]), b1));
-	} else if (sel && sel->flags&TC_U32_TERMINAL) {
+	} else if (sel && sel->flags & TC_U32_TERMINAL) {
 		fprintf(f, "terminal flowid ??? ");
 	}
 	if (tb[TCA_U32_LINK]) {
@@ -1254,16 +1252,16 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 			}
 		}
 
-		if (sel->flags&(TC_U32_VAROFFSET|TC_U32_OFFSET)) {
+		if (sel->flags & (TC_U32_VAROFFSET | TC_U32_OFFSET)) {
 			fprintf(f, "\n    offset ");
-			if (sel->flags&TC_U32_VAROFFSET)
+			if (sel->flags & TC_U32_VAROFFSET)
 				fprintf(f, "%04x>>%d at %d ",
 					ntohs(sel->offmask),
 					sel->offshift,  sel->offoff);
 			if (sel->off)
 				fprintf(f, "plus %d ", sel->off);
 		}
-		if (sel->flags&TC_U32_EAT)
+		if (sel->flags & TC_U32_EAT)
 			fprintf(f, " eat ");
 
 		if (sel->hmask) {
-- 
2.1.2
