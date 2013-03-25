From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 7/7] ip/xfrm: Improve error strings
Date: Mon, 25 Mar 2013 10:23:19 -0400
Message-ID: <1364221399-1024-7-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42079 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758265Ab3CYOXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:30 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2cx023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:29 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quotation marks are now used only to indicate literal text on the
command line.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/ipxfrm.c      |   64 +++++++++++++++++++++++++++---------------------------
 ip/xfrm_policy.c |   28 +++++++++++-----------
 ip/xfrm_state.c  |   40 ++++++++++++++++----------------
 3 files changed, 66 insertions(+), 66 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 3113573..0495ff4 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -660,7 +660,7 @@ int xfrm_parse_mark(struct xfrm_mark *mark, int *argcp, char ***argvp)
 
 	NEXT_ARG();
 	if (get_u32(&mark->v, *argv, 0)) {
-		invarg("Illegal \"mark\" value\n", *argv);
+		invarg("MARK value is invalid\n", *argv);
 	}
 	if (argc > 1)
 		NEXT_ARG();
@@ -672,7 +672,7 @@ int xfrm_parse_mark(struct xfrm_mark *mark, int *argcp, char ***argvp)
 	if (strcmp(*argv, "mask") == 0) {
 		NEXT_ARG();
 		if (get_u32(&mark->m, *argv, 0)) {
-			invarg("Illegal \"mark\" mask\n", *argv);
+			invarg("MASK value is invalid\n", *argv);
 		}
 	} else {
 		mark->m = 0xffffffff;
@@ -1010,7 +1010,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 
 			get_prefix(&src, *argv, preferred_family);
 			if (src.family == AF_UNSPEC)
-				invarg("\"src\" address family is AF_UNSPEC", *argv);
+				invarg("value after \"src\" has an unrecognized address family", *argv);
 			if (family)
 				*family = src.family;
 
@@ -1023,7 +1023,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 
 			get_prefix(&dst, *argv, preferred_family);
 			if (dst.family == AF_UNSPEC)
-				invarg("\"dst\" address family is AF_UNSPEC", *argv);
+				invarg("value after \"dst\" has an unrecognized address family", *argv);
 			if (family)
 				*family = dst.family;
 
@@ -1038,7 +1038,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 
 			ret = xfrm_xfrmproto_getbyname(*argv);
 			if (ret < 0)
-				invarg("\"XFRM-PROTO\" is invalid", *argv);
+				invarg("XFRM-PROTO value is invalid", *argv);
 
 			id->proto = (__u8)ret;
 
@@ -1049,7 +1049,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 
 			NEXT_ARG();
 			if (get_u32(&spi, *argv, 0))
-				invarg("\"SPI\" is invalid", *argv);
+				invarg("SPI value is invalid", *argv);
 
 			spi = htonl(spi);
 			id->spi = spi;
@@ -1067,7 +1067,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 	}
 
 	if (src.family && dst.family && (src.family != dst.family))
-		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
+		invarg("the same address family is required between values after \"src\" and \"dst\"", *argv);
 
 	if (id->spi && id->proto) {
 		if (xfrm_xfrmproto_is_ro(id->proto)) {
@@ -1108,7 +1108,7 @@ int xfrm_mode_parse(__u8 *mode, int *argcp, char ***argvp)
 	else if (matches(*argv, "beet") == 0)
 		*mode = XFRM_MODE_BEET;
 	else
-		invarg("\"MODE\" is invalid", *argv);
+		invarg("MODE value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
@@ -1126,7 +1126,7 @@ int xfrm_encap_type_parse(__u16 *type, int *argcp, char ***argvp)
 	else if (strcmp(*argv, "espinudp") == 0)
 		*type = 2;
 	else
-		invarg("\"ENCAP-TYPE\" is invalid", *argv);
+		invarg("ENCAP-TYPE value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
@@ -1141,7 +1141,7 @@ int xfrm_reqid_parse(__u32 *reqid, int *argcp, char ***argvp)
 	char **argv = *argvp;
 
 	if (get_u32(reqid, *argv, 0))
-		invarg("\"REQID\" is invalid", *argv);
+		invarg("REQID value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
@@ -1175,7 +1175,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 					upspec = pp->p_proto;
 				else {
 					if (get_u8(&upspec, *argv, 0))
-						invarg("\"PROTO\" is invalid", *argv);
+						invarg("PROTO value is invalid", *argv);
 				}
 			}
 			sel->proto = upspec;
@@ -1188,7 +1188,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 			NEXT_ARG();
 
 			if (get_u16(&sel->sport, *argv, 0))
-				invarg("\"PORT\" is invalid", *argv);
+				invarg("value after \"sport\" is invalid", *argv);
 			sel->sport = htons(sel->sport);
 			if (sel->sport)
 				sel->sport_mask = ~((__u16)0);
@@ -1201,7 +1201,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 			NEXT_ARG();
 
 			if (get_u16(&sel->dport, *argv, 0))
-				invarg("\"PORT\" is invalid", *argv);
+				invarg("value after \"dport\" is invalid", *argv);
 			sel->dport = htons(sel->dport);
 			if (sel->dport)
 				sel->dport_mask = ~((__u16)0);
@@ -1215,7 +1215,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 
 			if (get_u16(&sel->sport, *argv, 0) ||
 			    (sel->sport & ~((__u16)0xff)))
-				invarg("\"type\" value is invalid", *argv);
+				invarg("value after \"type\" is invalid", *argv);
 			sel->sport = htons(sel->sport);
 			sel->sport_mask = ~((__u16)0);
 
@@ -1229,7 +1229,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 
 			if (get_u16(&sel->dport, *argv, 0) ||
 			    (sel->dport & ~((__u16)0xff)))
-				invarg("\"code\" value is invalid", *argv);
+				invarg("value after \"code\" is invalid", *argv);
 			sel->dport = htons(sel->dport);
 			sel->dport_mask = ~((__u16)0);
 
@@ -1246,7 +1246,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 				uval = htonl(get_addr32(*argv));
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
-					fprintf(stderr, "invalid value for \"key\"; it should be an unsigned integer\n");
+					fprintf(stderr, "value after \"key\" is invalid\n");
 					exit(-1);
 				}
 			}
@@ -1277,7 +1277,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 		case IPPROTO_DCCP:
 			break;
 		default:
-			fprintf(stderr, "\"sport\" and \"dport\" are invalid with proto=%s\n", strxf_proto(sel->proto));
+			fprintf(stderr, "\"sport\" and \"dport\" are invalid with PROTO value \"%s\"\n", strxf_proto(sel->proto));
 			exit(1);
 		}
 	}
@@ -1288,7 +1288,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 		case IPPROTO_MH:
 			break;
 		default:
-			fprintf(stderr, "\"type\" and \"code\" are invalid with proto=%s\n", strxf_proto(sel->proto));
+			fprintf(stderr, "\"type\" and \"code\" are invalid with PROTO value \"%s\"\n", strxf_proto(sel->proto));
 			exit(1);
 		}
 	}
@@ -1297,7 +1297,7 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 		case IPPROTO_GRE:
 			break;
 		default:
-			fprintf(stderr, "\"key\" is invalid with proto=%s\n", strxf_proto(sel->proto));
+			fprintf(stderr, "\"key\" is invalid with PROTO value \"%s\"\n", strxf_proto(sel->proto));
 			exit(1);
 		}
 	}
@@ -1325,7 +1325,7 @@ int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp)
 
 			get_prefix(&src, *argv, preferred_family);
 			if (src.family == AF_UNSPEC)
-				invarg("\"src\" address family is AF_UNSPEC", *argv);
+				invarg("value after \"src\" has an unrecognized address family", *argv);
 			sel->family = src.family;
 
 			memcpy(&sel->saddr, &src.data, sizeof(sel->saddr));
@@ -1338,7 +1338,7 @@ int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp)
 
 			get_prefix(&dst, *argv, preferred_family);
 			if (dst.family == AF_UNSPEC)
-				invarg("\"dst\" address family is AF_UNSPEC", *argv);
+				invarg("value after \"dst\" has an unrecognized address family", *argv);
 			sel->family = dst.family;
 
 			memcpy(&sel->daddr, &dst.data, sizeof(sel->daddr));
@@ -1356,7 +1356,7 @@ int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp)
 			else {
 				ifindex = ll_name_to_index(*argv);
 				if (ifindex <= 0)
-					invarg("\"DEV\" is invalid", *argv);
+					invarg("DEV value is invalid", *argv);
 			}
 			sel->ifindex = ifindex;
 
@@ -1379,7 +1379,7 @@ int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp)
 	}
 
 	if (src.family && dst.family && (src.family != dst.family))
-		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
+		invarg("the same address family is required between values after \"src\" and \"dst\"", *argv);
 
 	if (argc == *argcp)
 		missarg("SELECTOR");
@@ -1401,44 +1401,44 @@ int xfrm_lifetime_cfg_parse(struct xfrm_lifetime_cfg *lft,
 		NEXT_ARG();
 		ret = get_u64(&lft->soft_add_expires_seconds, *argv, 0);
 		if (ret)
-			invarg("\"time-soft\" value is invalid", *argv);
+			invarg("value after \"time-soft\" is invalid", *argv);
 	} else if (strcmp(*argv, "time-hard") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->hard_add_expires_seconds, *argv, 0);
 		if (ret)
-			invarg("\"time-hard\" value is invalid", *argv);
+			invarg("value after \"time-hard\" is invalid", *argv);
 	} else if (strcmp(*argv, "time-use-soft") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->soft_use_expires_seconds, *argv, 0);
 		if (ret)
-			invarg("\"time-use-soft\" value is invalid", *argv);
+			invarg("value after \"time-use-soft\" is invalid", *argv);
 	} else if (strcmp(*argv, "time-use-hard") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->hard_use_expires_seconds, *argv, 0);
 		if (ret)
-			invarg("\"time-use-hard\" value is invalid", *argv);
+			invarg("value after \"time-use-hard\" is invalid", *argv);
 	} else if (strcmp(*argv, "byte-soft") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->soft_byte_limit, *argv, 0);
 		if (ret)
-			invarg("\"byte-soft\" value is invalid", *argv);
+			invarg("value after \"byte-soft\" is invalid", *argv);
 	} else if (strcmp(*argv, "byte-hard") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->hard_byte_limit, *argv, 0);
 		if (ret)
-			invarg("\"byte-hard\" value is invalid", *argv);
+			invarg("value after \"byte-hard\" is invalid", *argv);
 	} else if (strcmp(*argv, "packet-soft") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->soft_packet_limit, *argv, 0);
 		if (ret)
-			invarg("\"packet-soft\" value is invalid", *argv);
+			invarg("value after \"packet-soft\" is invalid", *argv);
 	} else if (strcmp(*argv, "packet-hard") == 0) {
 		NEXT_ARG();
 		ret = get_u64(&lft->hard_packet_limit, *argv, 0);
 		if (ret)
-			invarg("\"packet-hard\" value is invalid", *argv);
+			invarg("value after \"packet-hard\" is invalid", *argv);
 	} else
-		invarg("\"LIMIT\" is invalid", *argv);
+		invarg("LIMIT value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 27c9a65..9bc584e 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -114,7 +114,7 @@ static int xfrm_policy_dir_parse(__u8 *dir, int *argcp, char ***argvp)
 	else if (strcmp(*argv, "fwd") == 0)
 		*dir = XFRM_POLICY_FWD;
 	else
-		invarg("\"DIR\" is invalid", *argv);
+		invarg("DIR value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
@@ -132,7 +132,7 @@ static int xfrm_policy_ptype_parse(__u8 *ptype, int *argcp, char ***argvp)
 	else if (strcmp(*argv, "sub") == 0)
 		*ptype = XFRM_POLICY_TYPE_SUB;
 	else
-		invarg("\"PTYPE\" is invalid", *argv);
+		invarg("PTYPE value is invalid", *argv);
 
 	*argcp = argc;
 	*argvp = argv;
@@ -150,7 +150,7 @@ static int xfrm_policy_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 		__u8 val = 0;
 
 		if (get_u8(&val, *argv, 16))
-			invarg("\"FLAG\" is invalid", *argv);
+			invarg("FLAG value is invalid", *argv);
 		*flags = val;
 	} else {
 		while (1) {
@@ -197,7 +197,7 @@ static int xfrm_tmpl_parse(struct xfrm_user_tmpl *tmpl,
 			else if (strcmp(*argv, "use") == 0)
 				tmpl->optional = 1;
 			else
-				invarg("\"LEVEL\" is invalid\n", *argv);
+				invarg("LEVEL value is invalid\n", *argv);
 
 		} else {
 			if (idp) {
@@ -300,7 +300,7 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.index, *argv, 0))
-				invarg("\"INDEX\" is invalid", *argv);
+				invarg("INDEX value is invalid", *argv);
 		} else if (strcmp(*argv, "ptype") == 0) {
 			if (ptypep)
 				duparg("ptype", *argv);
@@ -315,11 +315,11 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 			else if (strcmp(*argv, "block") == 0)
 				req.xpinfo.action = XFRM_POLICY_BLOCK;
 			else
-				invarg("\"action\" value is invalid\n", *argv);
+				invarg("ACTION value is invalid\n", *argv);
 		} else if (strcmp(*argv, "priority") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.priority, *argv, 0))
-				invarg("\"PRIORITY\" is invalid", *argv);
+				invarg("PRIORITY value is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_policy_flag_parse(&req.xpinfo.flags, &argc,
@@ -359,7 +359,7 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 	}
 
 	if (!dirp) {
-		fprintf(stderr, "Not enough information: \"DIR\" is required.\n");
+		fprintf(stderr, "Not enough information: DIR is required.\n");
 		exit(1);
 	}
 
@@ -611,7 +611,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 
 			NEXT_ARG();
 			if (get_u32(&req.xpid.index, *argv, 0))
-				invarg("\"INDEX\" is invalid", *argv);
+				invarg("INDEX value is invalid", *argv);
 
 		} else if (strcmp(*argv, "ptype") == 0) {
 			if (ptypep)
@@ -636,7 +636,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 	}
 
 	if (!dirp) {
-		fprintf(stderr, "Not enough information: \"DIR\" is required.\n");
+		fprintf(stderr, "Not enough information: DIR is required.\n");
 		exit(1);
 	}
 	if (ptypep) {
@@ -644,7 +644,7 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 			  (void *)&upt, sizeof(upt));
 	}
 	if (!selp && !indexp) {
-		fprintf(stderr, "Not enough information: either \"SELECTOR\" or \"INDEX\" is required.\n");
+		fprintf(stderr, "Not enough information: either SELECTOR or INDEX is required.\n");
 		exit(1);
 	}
 	if (selp && indexp)
@@ -786,7 +786,7 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&filter.xpinfo.index, *argv, 0))
-				invarg("\"INDEX\" is invalid", *argv);
+				invarg("INDEX value is invalid", *argv);
 
 			filter.index_mask = XFRM_FILTER_MASK_FULL;
 
@@ -803,14 +803,14 @@ static int xfrm_policy_list_or_deleteall(int argc, char **argv, int deleteall)
 			else if (strcmp(*argv, "block") == 0)
 				filter.xpinfo.action = XFRM_POLICY_BLOCK;
 			else
-				invarg("\"ACTION\" is invalid\n", *argv);
+				invarg("ACTION value is invalid\n", *argv);
 
 			filter.action_mask = XFRM_FILTER_MASK_FULL;
 
 		} else if (strcmp(*argv, "priority") == 0) {
 			NEXT_ARG();
 			if (get_u32(&filter.xpinfo.priority, *argv, 0))
-				invarg("\"PRIORITY\" is invalid", *argv);
+				invarg("PRIORITY value is invalid", *argv);
 
 			filter.priority_mask = XFRM_FILTER_MASK_FULL;
 
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index ee06f7d..88a1a56 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -175,7 +175,7 @@ static int xfrm_seq_parse(__u32 *seq, int *argcp, char ***argvp)
 	char **argv = *argvp;
 
 	if (get_u32(seq, *argv, 0))
-		invarg("\"SEQ\" is invalid", *argv);
+		invarg("SEQ value is invalid", *argv);
 
 	*seq = htonl(*seq);
 
@@ -195,7 +195,7 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 		__u8 val = 0;
 
 		if (get_u8(&val, *argv, 16))
-			invarg("\"FLAG\" is invalid", *argv);
+			invarg("FLAG value is invalid", *argv);
 		*flags = val;
 	} else {
 		while (1) {
@@ -281,15 +281,15 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 		} else if (strcmp(*argv, "replay-window") == 0) {
 			NEXT_ARG();
 			if (get_u8(&req.xsinfo.replay_window, *argv, 0))
-				invarg("\"replay-window\" value is invalid", *argv);
+				invarg("value after \"replay-window\" is invalid", *argv);
 		} else if (strcmp(*argv, "replay-seq") == 0) {
 			NEXT_ARG();
 			if (get_u32(&replay.seq, *argv, 0))
-				invarg("\"replay-seq\" value is invalid", *argv);
+				invarg("value after \"replay-seq\" is invalid", *argv);
 		} else if (strcmp(*argv, "replay-oseq") == 0) {
 			NEXT_ARG();
 			if (get_u32(&replay.oseq, *argv, 0))
-				invarg("\"replay-oseq\" value is invalid", *argv);
+				invarg("value after \"replay-oseq\" is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
@@ -308,11 +308,11 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			xfrm_encap_type_parse(&encap.encap_type, &argc, &argv);
 			NEXT_ARG();
 			if (get_u16(&encap.encap_sport, *argv, 0))
-				invarg("\"encap\" sport value is invalid", *argv);
+				invarg("SPORT value after \"encap\" is invalid", *argv);
 			encap.encap_sport = htons(encap.encap_sport);
 			NEXT_ARG();
 			if (get_u16(&encap.encap_dport, *argv, 0))
-				invarg("\"encap\" dport value is invalid", *argv);
+				invarg("DPORT value after \"encap\" is invalid", *argv);
 			encap.encap_dport = htons(encap.encap_dport);
 			NEXT_ARG();
 			get_addr(&oa, *argv, AF_UNSPEC);
@@ -331,9 +331,9 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			get_prefix(&coa, *argv, preferred_family);
 			if (coa.family == AF_UNSPEC)
-				invarg("\"coa\" address family is AF_UNSPEC", *argv);
+				invarg("value after \"coa\" has an unrecognized address family", *argv);
 			if (coa.bytelen > sizeof(xcoa))
-				invarg("\"coa\" address length is too large", *argv);
+				invarg("value after \"coa\" is too large", *argv);
 
 			memset(&xcoa, 0, sizeof(xcoa));
 			memcpy(&xcoa, &coa.data, coa.bytelen);
@@ -402,7 +402,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 					break;
 				default:
 					/* not reached */
-					invarg("\"ALGO-TYPE\" is invalid\n", *argv);
+					invarg("ALGO-TYPE value is invalid\n", *argv);
 				}
 
 				if (!NEXT_ARG_OK())
@@ -431,7 +431,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 						missarg("ALGO-ICV-LEN");
 					NEXT_ARG();
 					if (get_u32(&icvlen, *argv, 0))
-						invarg("\"aead\" ICV length is invalid",
+						invarg("ALGO-ICV-LEN value is invalid",
 						       *argv);
 					alg.u.aead.alg_icv_len = icvlen;
 
@@ -443,7 +443,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 						missarg("ALGO-TRUNC-LEN");
 					NEXT_ARG();
 					if (get_u32(&trunclen, *argv, 0))
-						invarg("\"auth\" trunc length is invalid",
+						invarg("ALGO-TRUNC-LEN value is invalid",
 						       *argv);
 					alg.u.auth.alg_trunc_len = trunclen;
 
@@ -481,7 +481,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 			  (void *)&replay, sizeof(replay));
 
 	if (!idp) {
-		fprintf(stderr, "Not enough information: \"ID\" is required\n");
+		fprintf(stderr, "Not enough information: ID is required\n");
 		exit(1);
 	}
 
@@ -660,7 +660,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			NEXT_ARG();
 
 			if (get_u32(&req.xspi.min, *argv, 0))
-				invarg("\"min\" value is invalid", *argv);
+				invarg("value after \"min\" is invalid", *argv);
 		} else if (strcmp(*argv, "max") == 0) {
 			if (maxp)
 				duparg("max", *argv);
@@ -669,7 +669,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			NEXT_ARG();
 
 			if (get_u32(&req.xspi.max, *argv, 0))
-				invarg("\"max\" value is invalid", *argv);
+				invarg("value after \"max\" is invalid", *argv);
 		} else {
 			/* try to assume ID */
 			if (idp)
@@ -680,7 +680,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			xfrm_id_parse(&req.xspi.info.saddr, &req.xspi.info.id,
 				      &req.xspi.info.family, 0, &argc, &argv);
 			if (req.xspi.info.id.spi) {
-				fprintf(stderr, "\"SPI\" must be zero\n");
+				fprintf(stderr, "\"spi\" is invalid\n");
 				exit(1);
 			}
 			if (preferred_family == AF_UNSPEC)
@@ -690,7 +690,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 	}
 
 	if (!idp) {
-		fprintf(stderr, "Not enough information: \"ID\" is required\n");
+		fprintf(stderr, "Not enough information: ID is required\n");
 		exit(1);
 	}
 
@@ -700,7 +700,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			exit(1);
 		}
 		if (req.xspi.min > req.xspi.max) {
-			fprintf(stderr, "\"min\" value is larger than \"max\" value\n");
+			fprintf(stderr, "value after \"min\" is larger than value after \"max\"\n");
 			exit(1);
 		}
 	} else {
@@ -1215,7 +1215,7 @@ static int xfrm_state_flush(int argc, char **argv)
 
 			ret = xfrm_xfrmproto_getbyname(*argv);
 			if (ret < 0)
-				invarg("\"XFRM-PROTO\" is invalid", *argv);
+				invarg("XFRM-PROTO value is invalid", *argv);
 
 			req.xsf.proto = (__u8)ret;
 		} else
@@ -1228,7 +1228,7 @@ static int xfrm_state_flush(int argc, char **argv)
 		exit(1);
 
 	if (show_stats > 1)
-		fprintf(stderr, "Flush state proto=%s\n",
+		fprintf(stderr, "Flush state with XFRM-PROTO value \"%s\"\n",
 			strxf_xfrmproto(req.xsf.proto));
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-- 
1.7.1
