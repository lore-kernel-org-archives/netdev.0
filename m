From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] tc filter u32: Coding style fixes
Date: Wed, 25 May 2016 06:11:55 -0400
Message-ID: <1464171115-7770-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34445 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771AbcEYKMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 06:12:03 -0400
Received: by mail-it0-f67.google.com with SMTP id k76so4857063ita.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 03:12:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

"handle" was being used several times for different things.
Fix the 80 character limit abuse and other little issues while at it.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/f_u32.c | 66 +++++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 40 insertions(+), 26 deletions(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index 6299515..1962dfe 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -171,7 +171,8 @@ static int pack_key16(struct tc_u32_sel *sel, __u32 key, __u32 mask,
 	return pack_key(sel, key, mask, off, offmask);
 }
 
-static int pack_key8(struct tc_u32_sel *sel, __u32 key, __u32 mask, int off, int offmask)
+static int pack_key8(struct tc_u32_sel *sel, __u32 key, __u32 mask, int off,
+		     int offmask)
 {
 	if (key > 0xFF || mask > 0xFF)
 		return -1;
@@ -835,16 +836,19 @@ static void print_ipv4(FILE *f, const struct tc_u32_key *key)
 	case 0:
 		switch (ntohl(key->mask)) {
 		case 0x0f000000:
-			fprintf(f, "\n  match IP ihl %u", ntohl(key->val) >> 24);
+			fprintf(f, "\n  match IP ihl %u",
+				ntohl(key->val) >> 24);
 			return;
 		case 0x00ff0000:
-			fprintf(f, "\n  match IP dsfield %#x", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP dsfield %#x",
+				ntohl(key->val) >> 16);
 			return;
 		}
 		break;
 	case 8:
 		if (ntohl(key->mask) == 0x00ff0000) {
-			fprintf(f, "\n  match IP protocol %d", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP protocol %d",
+				ntohl(key->val) >> 16);
 			return;
 		}
 		break;
@@ -892,16 +896,19 @@ static void print_ipv6(FILE *f, const struct tc_u32_key *key)
 	case 0:
 		switch (ntohl(key->mask)) {
 		case 0x0f000000:
-			fprintf(f, "\n  match IP ihl %u", ntohl(key->val) >> 24);
+			fprintf(f, "\n  match IP ihl %u",
+				ntohl(key->val) >> 24);
 			return;
 		case 0x00ff0000:
-			fprintf(f, "\n  match IP dsfield %#x", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP dsfield %#x",
+				ntohl(key->val) >> 16);
 			return;
 		}
 		break;
 	case 8:
 		if (ntohl(key->mask) == 0x00ff0000) {
-			fprintf(f, "\n  match IP protocol %d", ntohl(key->val) >> 16);
+			fprintf(f, "\n  match IP protocol %d",
+				ntohl(key->val) >> 16);
 			return;
 		}
 		break;
@@ -1031,14 +1038,14 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			continue;
 		} else if (matches(*argv, "classid") == 0 ||
 			   strcmp(*argv, "flowid") == 0) {
-			unsigned int handle;
+			unsigned int flowid;
 
 			NEXT_ARG();
-			if (get_tc_classid(&handle, *argv)) {
+			if (get_tc_classid(&flowid, *argv)) {
 				fprintf(stderr, "Illegal \"classid\"\n");
 				return -1;
 			}
-			addattr_l(n, MAX_MSG, TCA_U32_CLASSID, &handle, 4);
+			addattr_l(n, MAX_MSG, TCA_U32_CLASSID, &flowid, 4);
 			sel.sel.flags |= TC_U32_TERMINAL;
 		} else if (matches(*argv, "divisor") == 0) {
 			unsigned int divisor;
@@ -1058,34 +1065,34 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 		} else if (strcmp(*argv, "link") == 0) {
-			unsigned int handle;
+			unsigned int linkid;
 
 			NEXT_ARG();
-			if (get_u32_handle(&handle, *argv)) {
+			if (get_u32_handle(&linkid, *argv)) {
 				fprintf(stderr, "Illegal \"link\"\n");
 				return -1;
 			}
-			if (handle && TC_U32_NODE(handle)) {
+			if (linkid && TC_U32_NODE(linkid)) {
 				fprintf(stderr, "\"link\" must be a hash table.\n");
 				return -1;
 			}
 			addattr_l(n, MAX_MSG, TCA_U32_LINK, &handle, 4);
 		} else if (strcmp(*argv, "ht") == 0) {
-			unsigned int handle;
+			unsigned int ht;
 
 			NEXT_ARG();
-			if (get_u32_handle(&handle, *argv)) {
+			if (get_u32_handle(&ht, *argv)) {
 				fprintf(stderr, "Illegal \"ht\"\n");
 				return -1;
 			}
-			if (handle && TC_U32_NODE(handle)) {
+			if (handle && TC_U32_NODE(ht)) {
 				fprintf(stderr, "\"ht\" must be a hash table.\n");
 				return -1;
 			}
 			if (sample_ok)
-				htid = (htid & 0xFF000) | (handle & 0xFFF00000);
+				htid = (htid & 0xFF000) | (ht & 0xFFF00000);
 			else
-				htid = (handle & 0xFFFFF000);
+				htid = (ht & 0xFFFFF000);
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
 			unsigned int divisor = 0x100;
@@ -1106,8 +1113,9 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			}
 			if (*argv != 0 && strcmp(*argv, "divisor") == 0) {
 				NEXT_ARG();
-				if (get_unsigned(&divisor, *argv, 0) || divisor == 0 ||
-				    divisor > 0x100 || ((divisor - 1) & divisor)) {
+				if (get_unsigned(&divisor, *argv, 0) ||
+				    divisor == 0 || divisor > 0x100 ||
+				    ((divisor - 1) & divisor)) {
 					fprintf(stderr, "Illegal sample \"divisor\"\n");
 					return -1;
 				}
@@ -1130,7 +1138,8 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			strncpy(ind, *argv, sizeof(ind) - 1);
-			addattr_l(n, MAX_MSG, TCA_U32_INDEV, ind, strlen(ind) + 1);
+			addattr_l(n, MAX_MSG, TCA_U32_INDEV, ind,
+				  strlen(ind) + 1);
 
 		} else if (matches(*argv, "action") == 0) {
 			NEXT_ARG();
@@ -1165,7 +1174,8 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 		sel.sel.flags |= TC_U32_TERMINAL;
 
 	if (order) {
-		if (TC_U32_NODE(t->tcm_handle) && order != TC_U32_NODE(t->tcm_handle)) {
+		if (TC_U32_NODE(t->tcm_handle) &&
+		    order != TC_U32_NODE(t->tcm_handle)) {
 			fprintf(stderr, "\"order\" contradicts \"handle\"\n");
 			return -1;
 		}
@@ -1176,7 +1186,8 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 		addattr_l(n, MAX_MSG, TCA_U32_HASH, &htid, 4);
 	if (sel_ok)
 		addattr_l(n, MAX_MSG, TCA_U32_SEL, &sel,
-			  sizeof(sel.sel) + sel.sel.nkeys * sizeof(struct tc_u32_key));
+			  sizeof(sel.sel) +
+			  sel.sel.nkeys * sizeof(struct tc_u32_key));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -1209,7 +1220,8 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 	}
 
 	if (tb[TCA_U32_DIVISOR]) {
-		fprintf(f, "ht divisor %d ", rta_getattr_u32(tb[TCA_U32_DIVISOR]));
+		fprintf(f, "ht divisor %d ",
+			rta_getattr_u32(tb[TCA_U32_DIVISOR]));
 	} else if (tb[TCA_U32_HASH]) {
 		__u32 htid = rta_getattr_u32(tb[TCA_U32_HASH]);
 
@@ -1222,14 +1234,16 @@ static int u32_print_opt(struct filter_util *qu, FILE *f, struct rtattr *opt,
 		SPRINT_BUF(b1);
 		fprintf(f, "%sflowid %s ",
 			!sel || !(sel->flags & TC_U32_TERMINAL) ? "*" : "",
-			sprint_tc_classid(rta_getattr_u32(tb[TCA_U32_CLASSID]), b1));
+			sprint_tc_classid(rta_getattr_u32(tb[TCA_U32_CLASSID]),
+					  b1));
 	} else if (sel && sel->flags & TC_U32_TERMINAL) {
 		fprintf(f, "terminal flowid ??? ");
 	}
 	if (tb[TCA_U32_LINK]) {
 		SPRINT_BUF(b1);
 		fprintf(f, "link %s ",
-			sprint_u32_handle(rta_getattr_u32(tb[TCA_U32_LINK]), b1));
+			sprint_u32_handle(rta_getattr_u32(tb[TCA_U32_LINK]),
+					  b1));
 	}
 
 	if (tb[TCA_U32_PCNT]) {
-- 
1.9.1
