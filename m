From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2] xfrm: Update documentation
Date: Sat, 11 Jun 2011 22:13:30 -0400
Message-ID: <201106120405.p5C44N7I010008@outgoing.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-2.MIT.EDU ([18.9.25.13]:47881 "EHLO
	dmz-mailsec-scanner-2.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750749Ab1FLEMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 00:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ip(8) man page and the "ip xfrm [ XFRM-OBJECT ] help" command output
are updated to include missing options, fix errors, and improve grammar.
There are no functional changes made.

The documentation for the ip command has many different meanings for the
same formatting symbols (which really needs to be fixed). This patch makes
consistent use of brackets [ ] to indicate optional parameters, pipes | to
mean "OR", braces { } to group things together, and dashes - instead of
underscores _ inside of parameter names. The parameters are listed in the
order in which they are parsed in the source code.

There are several parameters and options that are still not mentioned or
need to be described more thoroughly in the "COMMAND SYNTAX" section of
the ip(8) man page. I would appreciate help from the developers with this.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/ipxfrm.c       |    8 +-
 ip/xfrm_monitor.c |    2 +-
 ip/xfrm_policy.c  |   72 +++---
 ip/xfrm_state.c   |  120 ++++-----
 man/man8/ip.8     |  751 +++++++++++++++++++++++++++++------------------------
 5 files changed, 515 insertions(+), 438 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 48a732f..f55bff9 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -59,8 +59,8 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr,
-		"Usage: ip xfrm XFRM_OBJECT { COMMAND | help }\n"
-		"where  XFRM_OBJECT := { state | policy | monitor }\n");
+		"Usage: ip xfrm XFRM-OBJECT { COMMAND | help }\n"
+		"where  XFRM-OBJECT := state | policy | monitor\n");
 	exit(-1);
 }
 
@@ -1040,7 +1040,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 
 			ret = xfrm_xfrmproto_getbyname(*argv);
 			if (ret < 0)
-				invarg("\"XFRM_PROTO\" is invalid", *argv);
+				invarg("\"XFRM-PROTO\" is invalid", *argv);
 
 			id->proto = (__u8)ret;
 
@@ -1072,7 +1072,7 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
 
 	if (loose == 0 && id->proto == 0)
-		missarg("XFRM_PROTO");
+		missarg("XFRM-PROTO");
 	if (argc == *argcp)
 		missarg("ID");
 
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index dc12fca..6a5b331 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -37,7 +37,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm monitor [ all | LISTofOBJECTS ]\n");
+	fprintf(stderr, "Usage: ip xfrm monitor [ all | LISTofXFRM-OBJECTS ]\n");
 	exit(-1);
 }
 
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 7827f91..2a14903 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -54,50 +54,50 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ ctx SEC_CTX ][ index INDEX ] [ ptype PTYPE ]\n");
-	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ] [ LIMIT-LIST ] [ TMPL-LIST ] [mark MARK [mask MASK]]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ] [ ctx SEC_CTX ][ ptype PTYPE ] [mark MARK [mask MASK]]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ dir DIR ] [ SELECTOR ]\n");
-	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]  [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { add | update } SELECTOR dir DIR [ ctx CTX ]\n");
+	fprintf(stderr, "        [ mark MARK [ mask MASK ] ] [ index INDEX ] [ ptype PTYPE ]\n");
+	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "        [ LIMIT-LIST ] [ TMPL-LIST ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { delete | get } { SELECTOR | index INDEX } dir DIR\n");
+	fprintf(stderr, "        [ ctx CTX ] [ mark MARK [ mask MASK ] ] [ ptype PTYPE ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ SELECTOR ] [ dir DIR ]\n");
+	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
+	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
 	fprintf(stderr, "Usage: ip xfrm count\n");
-	fprintf(stderr, "PTYPE := [ main | sub ](default=main)\n");
-	fprintf(stderr, "DIR := [ in | out | fwd ]\n");
-
-	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
-
-	fprintf(stderr, "UPSPEC := proto PROTO [ [ sport PORT ] [ dport PORT ] |\n");
-	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBER ] |\n");
-	fprintf(stderr, "                        [ key { DOTTED_QUAD | NUMBER } ] ]\n");
-
-	//fprintf(stderr, "DEV - device name(default=none)\n");
-
-	fprintf(stderr, "ACTION := [ allow | block ](default=allow)\n");
-
-	//fprintf(stderr, "PRIORITY - priority value(default=0)\n");
-
+	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
+	fprintf(stderr, "UPSPEC := proto { { ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_TCP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_UDP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_SCTP));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_DCCP));
+	fprintf(stderr, " } [ sport PORT ] [ dport PORT ] |\n");
+	fprintf(stderr, "                  { ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ICMP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ICMPV6));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
+	fprintf(stderr, " } [ type NUMBER ] [ code NUMBER ] |\n");
+	fprintf(stderr, "                  %s", strxf_proto(IPPROTO_GRE));
+	fprintf(stderr, " [ key { DOTTED-QUAD | NUMBER } ] | PROTO }\n");
+	fprintf(stderr, "DIR := in | out | fwd\n");
+	fprintf(stderr, "PTYPE := main | sub\n");
+	fprintf(stderr, "ACTION := allow | block\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ localok | icmp ]\n");
-
-	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] | [ limit LIMIT ]\n");
-	fprintf(stderr, "LIMIT := [ [time-soft|time-hard|time-use-soft|time-use-hard] SECONDS ] |\n");
-	fprintf(stderr, "         [ [byte-soft|byte-hard] SIZE ] | [ [packet-soft|packet-hard] NUMBER ]\n");
-
-	fprintf(stderr, "TMPL-LIST := [ TMPL-LIST ] | [ tmpl TMPL ]\n");
+	fprintf(stderr, "FLAG := localok | icmp\n");
+	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] limit LIMIT\n");
+	fprintf(stderr, "LIMIT := { time-soft | time-hard | time-use-soft | time-use-hard } SECONDS |\n");
+	fprintf(stderr, "         { byte-soft | byte-hard } SIZE | { packet-soft | packet-hard } COUNT\n");
+	fprintf(stderr, "TMPL-LIST := [ TMPL-LIST ] tmpl TMPL\n");
 	fprintf(stderr, "TMPL := ID [ mode MODE ] [ reqid REQID ] [ level LEVEL ]\n");
-	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
-
-	fprintf(stderr, "XFRM_PROTO := [ ");
+	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM-PROTO ] [ spi SPI ]\n");
+	fprintf(stderr, "XFRM-PROTO := ");
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_COMP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ROUTING));
-	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_DSTOPTS));
-	fprintf(stderr, "]\n");
-
- 	fprintf(stderr, "MODE := [ transport | tunnel | beet ](default=transport)\n");
- 	//fprintf(stderr, "REQID - number(default=0)\n");
-	fprintf(stderr, "LEVEL := [ required | use ](default=required)\n");
+	fprintf(stderr, "%s\n", strxf_xfrmproto(IPPROTO_DSTOPTS));
+ 	fprintf(stderr, "MODE := transport | tunnel | ro | in_trigger | beet\n");
+	fprintf(stderr, "LEVEL := required | use\n");
 
 	exit(-1);
 }
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 8ac3437..a76be47 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -56,63 +56,57 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ ctx SEC_CTX ] [ mode MODE ]\n");
-	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
-	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ replay-seq SEQ ]\n");
-	fprintf(stderr, "        [ replay-oseq SEQ ] [ LIMIT-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ reqid REQID ] [ seq SEQ ]\n");
-	fprintf(stderr, "        [ min SPI max SPI ]\n");
-	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
+	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ ALGO-LIST ] [ mode MODE ]\n");
+	fprintf(stderr, "        [ mark MARK [ mask MASK ] ] [ reqid REQID ] [ seq SEQ ]\n");
+	fprintf(stderr, "        [ replay-window SIZE ] [ replay-seq SEQ ] [ replay-oseq SEQ ]\n");
+	fprintf(stderr, "        [ flag FLAG-LIST ] [ sel SELECTOR ] [ LIMIT-LIST ] [ encap ENCAP ]\n");
+	fprintf(stderr, "        [ coa ADDR[/PLEN] ] [ ctx CTX ]\n");
+	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ mark MARK [ mask MASK ] ]\n");
+	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ min SPI max SPI ]\n");
+	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM_PROTO ]\n");
-	fprintf(stderr, "Usage: ip xfrm state count \n");
-
-	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ] [mark MARK [mask MASK]]\n");
-	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
-	fprintf(stderr, "XFRM_PROTO := [ ");
+	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM-PROTO ]\n");
+	fprintf(stderr, "Usage: ip xfrm state count\n");
+	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM-PROTO ] [ spi SPI ]\n");
+	fprintf(stderr, "XFRM-PROTO := ");
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_COMP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ROUTING));
-	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_DSTOPTS));
-	fprintf(stderr, "]\n");
-
-	//fprintf(stderr, "SPI - security parameter index(default=0)\n");
-
- 	fprintf(stderr, "MODE := [ transport | tunnel | ro | beet ](default=transport)\n");
- 	//fprintf(stderr, "REQID - number(default=0)\n");
-
-	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4 ]\n");
-
-        fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
-        fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
-
-	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
-	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY "
-			"[ ALGO_ICV_LEN | ALGO_TRUNC_LEN ]\n");
-	fprintf(stderr, "ALGO_TYPE := [ ");
-	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AEAD));
+	fprintf(stderr, "%s\n", strxf_xfrmproto(IPPROTO_DSTOPTS));
+	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] ALGO\n");
+	fprintf(stderr, "ALGO := { ");
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));
-	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
-	fprintf(stderr, "%s ", strxf_algotype(XFRMA_ALG_COMP));
-	fprintf(stderr, "]\n");
-
-	//fprintf(stderr, "ALGO_NAME - algorithm name\n");
-	//fprintf(stderr, "ALGO_KEY - algorithm key\n");
-
-	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
-
-	fprintf(stderr, "UPSPEC := proto PROTO [ [ sport PORT ] [ dport PORT ] |\n");
-	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBER ] ]\n");
-
+	fprintf(stderr, "%s", strxf_algotype(XFRMA_ALG_COMP));
+	fprintf(stderr, " } ALGO-NAME ALGO-KEY |\n");
+	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AEAD));
+	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-ICV-LEN |\n");
+	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
+	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-TRUNC-LEN\n");
+ 	fprintf(stderr, "MODE := transport | tunnel | ro | in_trigger | beet\n");
+	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
+	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4\n");
+	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
+	fprintf(stderr, "UPSPEC := proto { { ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_TCP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_UDP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_SCTP));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_DCCP));
+	fprintf(stderr, " } [ sport PORT ] [ dport PORT ] |\n");
+	fprintf(stderr, "                  { ");
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ICMP));
+	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ICMPV6));
+	fprintf(stderr, "%s", strxf_proto(IPPROTO_MH));
+	fprintf(stderr, " } [ type NUMBER ] [ code NUMBER ] |\n");
+	fprintf(stderr, "                  %s", strxf_proto(IPPROTO_GRE));
+	fprintf(stderr, " [ key { DOTTED-QUAD | NUMBER } ] | PROTO }\n");
+	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] limit LIMIT\n");
+	fprintf(stderr, "LIMIT := { time-soft | time-hard | time-use-soft | time-use-hard } SECONDS |\n");
+	fprintf(stderr, "         { byte-soft | byte-hard } SIZE | { packet-soft | packet-hard } COUNT\n");
+        fprintf(stderr, "ENCAP := { espinudp | espinudp-nonike } SPORT DPORT OADDR\n");
 
-	//fprintf(stderr, "DEV - device name(default=none)\n");
-	fprintf(stderr, "LIMIT-LIST := [ LIMIT-LIST ] | [ limit LIMIT ]\n");
-	fprintf(stderr, "LIMIT := [ [time-soft|time-hard|time-use-soft|time-use-hard] SECONDS ] |\n");
-	fprintf(stderr, "         [ [byte-soft|byte-hard] SIZE ] | [ [packet-soft|packet-hard] COUNT ]\n");
 	exit(-1);
 }
 
@@ -124,7 +118,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 
 #if 0
 	/* XXX: verifying both name and key is required! */
-	fprintf(stderr, "warning: ALGONAME/ALGOKEY will send to kernel promiscuously!(verifying them isn't implemented yet)\n");
+	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEY will send to kernel promiscuously! (verifying them isn't implemented yet)\n");
 #endif
 
 	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
@@ -144,7 +138,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 		/* calculate length of the converted values(real key) */
 		len = (plen + 1) / 2;
 		if (len > max)
-			invarg("\"ALGOKEY\" makes buffer overflow\n", key);
+			invarg("\"ALGO-KEY\" makes buffer overflow\n", key);
 
 		for (i = - (plen % 2), j = 0; j < len; i += 2, j++) {
 			char vbuf[3];
@@ -155,7 +149,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			vbuf[2] = '\0';
 
 			if (get_u8(&val, vbuf, 16))
-				invarg("\"ALGOKEY\" is invalid", key);
+				invarg("\"ALGO-KEY\" is invalid", key);
 
 			buf[j] = val;
 		}
@@ -163,7 +157,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 		len = slen;
 		if (len > 0) {
 			if (len > max)
-				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
+				invarg("\"ALGO-KEY\" makes buffer overflow\n", key);
 
 			strncpy(buf, key, len);
 		}
@@ -384,37 +378,37 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				switch (type) {
 				case XFRMA_ALG_AEAD:
 					if (aeadop)
-						duparg("ALGOTYPE", *argv);
+						duparg("ALGO-TYPE", *argv);
 					aeadop = *argv;
 					break;
 				case XFRMA_ALG_CRYPT:
 					if (ealgop)
-						duparg("ALGOTYPE", *argv);
+						duparg("ALGO-TYPE", *argv);
 					ealgop = *argv;
 					break;
 				case XFRMA_ALG_AUTH:
 				case XFRMA_ALG_AUTH_TRUNC:
 					if (aalgop)
-						duparg("ALGOTYPE", *argv);
+						duparg("ALGO-TYPE", *argv);
 					aalgop = *argv;
 					break;
 				case XFRMA_ALG_COMP:
 					if (calgop)
-						duparg("ALGOTYPE", *argv);
+						duparg("ALGO-TYPE", *argv);
 					calgop = *argv;
 					break;
 				default:
 					/* not reached */
-					invarg("\"ALGOTYPE\" is invalid\n", *argv);
+					invarg("\"ALGO-TYPE\" is invalid\n", *argv);
 				}
 
 				if (!NEXT_ARG_OK())
-					missarg("ALGONAME");
+					missarg("ALGO-NAME");
 				NEXT_ARG();
 				name = *argv;
 
 				if (!NEXT_ARG_OK())
-					missarg("ALGOKEY");
+					missarg("ALGO-KEY");
 				NEXT_ARG();
 				key = *argv;
 
@@ -424,7 +418,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				switch (type) {
 				case XFRMA_ALG_AEAD:
 					if (!NEXT_ARG_OK())
-						missarg("ALGOICVLEN");
+						missarg("ALGO-ICV-LEN");
 					NEXT_ARG();
 					if (get_u32(&icvlen, *argv, 0))
 						invarg("\"aead\" ICV length is invalid",
@@ -436,7 +430,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 					break;
 				case XFRMA_ALG_AUTH_TRUNC:
 					if (!NEXT_ARG_OK())
-						missarg("ALGOTRUNCLEN");
+						missarg("ALGO-TRUNC-LEN");
 					NEXT_ARG();
 					if (get_u32(&trunclen, *argv, 0))
 						invarg("\"auth\" trunc length is invalid",
@@ -649,7 +643,7 @@ static int xfrm_state_allocspi(int argc, char **argv)
 			exit(1);
 		}
 		if (req.xspi.min > req.xspi.max) {
-			fprintf(stderr, "\"min\" valie is larger than \"max\" one\n");
+			fprintf(stderr, "\"min\" value is larger than \"max\" value\n");
 			exit(1);
 		}
 	} else {
@@ -1164,7 +1158,7 @@ static int xfrm_state_flush(int argc, char **argv)
 
 			ret = xfrm_xfrmproto_getbyname(*argv);
 			if (ret < 0)
-				invarg("\"XFRM_PROTO\" is invalid", *argv);
+				invarg("\"XFRM-PROTO\" is invalid", *argv);
 
 			req.xsf.proto = (__u8)ret;
 		} else
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index c5248ef..4ddc78c 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -421,318 +421,348 @@ throw " | " unreachable " | " prohibit " | " blackhole " | " nat " ]"
 .ti -8
 .BR "ip monitor" " [ " all " |"
 .IR LISTofOBJECTS " ]"
+.sp
 
 .ti -8
-.BR "ip xfrm"
-.IR XFRM_OBJECT " { " COMMAND " }"
+.B "ip xfrm"
+.IR XFRM-OBJECT " { " COMMAND " | "
+.BR help " }"
+.sp
 
 .ti -8
-.IR XFRM_OBJECT " := { " state " | " policy " | " monitor " } "
+.IR XFRM-OBJECT " :="
+.BR state " | " policy " | " monitor
+.sp
 
 .ti -8
 .BR "ip xfrm state " { " add " | " update " } "
-.IR ID " [ "
-.IR XFRM_OPT " ] "
-.RB " [ " mode
-.IR MODE " ] "
-.br
-.RB " [ " reqid
-.IR REQID " ] "
-.RB " [ " seq
-.IR SEQ " ] "
-.RB " [ " replay-window
-.IR SIZE " ] "
-.br
-.RB " [ " flag
-.IR FLAG-LIST " ] "
-.RB " [ " encap
-.IR ENCAP " ] "
-.RB " [ " sel
-.IR SELECTOR " ] "
-.br
-.RB " [ "
-.IR LIMIT-LIST " ] "
-
-.ti -8
-.BR "ip xfrm state allocspi "
-.IR ID
-.RB " [ " mode
-.IR MODE " ] "
-.RB " [ " reqid
-.IR REQID " ] "
-.RB " [ " seq
-.IR SEQ " ] "
-.RB " [ " min
-.IR SPI
+.IR ID " [ " ALGO-LIST " ]"
+.RB "[ " mode
+.IR MODE " ]"
+.RB "[ " mark
+.I MARK
+.RB "[ " mask
+.IR MASK " ] ]"
+.RB "[ " reqid
+.IR REQID " ]"
+.RB "[ " seq
+.IR SEQ " ]"
+.RB "[ " replay-window
+.IR SIZE " ]"
+.RB "[ " replay-seq
+.IR SEQ " ]"
+.RB "[ " replay-oseq
+.IR SEQ " ]"
+.RB "[ " flag
+.IR FLAG-LIST " ]"
+.RB "[ " sel
+.IR SELECTOR " ] [ " LIMIT-LIST " ]"
+.RB "[ " encap
+.IR ENCAP " ]"
+.RB "[ " coa
+.IR ADDR "[/" PLEN "] ]"
+.RB "[ " ctx
+.IR CTX " ]"
+
+.ti -8
+.B "ip xfrm state allocspi"
+.I ID
+.RB "[ " mode
+.IR MODE " ]"
+.RB "[ " mark
+.I MARK
+.RB "[ " mask
+.IR MASK " ] ]"
+.RB "[ " reqid
+.IR REQID " ]"
+.RB "[ " seq
+.IR SEQ " ]"
+.RB "[ " min
+.I SPI
 .B max
-.IR SPI " ] "
+.IR SPI " ]"
 
 .ti -8
 .BR "ip xfrm state" " { " delete " | " get " } "
-.IR ID
+.I ID
+.RB "[ " mark
+.I MARK
+.RB "[ " mask
+.IR MASK " ] ]"
 
 .ti -8
-.BR "ip xfrm state" " { " deleteall " | " list " } [ "
-.IR ID " ] "
-.RB " [ " mode
-.IR MODE " ] "
-.br
-.RB " [ " reqid
-.IR REQID " ] "
-.RB " [ " flag
-.IR FLAG_LIST " ] "
+.BR "ip xfrm state" " { " deleteall " | " list " } ["
+.IR ID " ]"
+.RB "[ " mode
+.IR MODE " ]"
+.RB "[ " reqid
+.IR REQID " ]"
+.RB "[ " flag
+.IR FLAG-LIST " ]"
 
 .ti -8
 .BR "ip xfrm state flush" " [ " proto
-.IR XFRM_PROTO " ] "
+.IR XFRM-PROTO " ]"
 
 .ti -8
 .BR "ip xfrm state count"
 
 .ti -8
-.IR ID " := "
-.RB " [ " src
-.IR ADDR " ] "
-.RB " [ " dst
-.IR ADDR " ] "
-.RB " [ " proto
-.IR XFRM_PROTO " ] "
-.RB " [ " spi
-.IR SPI " ] "
-
-.ti -8
-.IR XFRM_PROTO " := "
-.RB " [ " esp " | " ah " | " comp " | " route2 " | " hao " ] "
-
-.ti -8
-.IR MODE " := "
-.RB " [ " transport " | " tunnel " | " ro " | " beet " ] "
-.B (default=transport)
+.IR ID " :="
+.RB "[ " src
+.IR ADDR " ]"
+.RB "[ " dst
+.IR ADDR " ]"
+.RB "[ " proto
+.IR XFRM-PROTO " ]"
+.RB "[ " spi
+.IR SPI " ]"
 
 .ti -8
-.IR FLAG-LIST " := "
-.RI " [ " FLAG-LIST " ] " FLAG
+.IR XFRM-PROTO " :="
+.BR esp " | " ah " | " comp " | " route2 " | " hao
 
 .ti -8
-.IR FLAG " := "
-.RB " [ " noecn " | " decap-dscp " | " wildrecv " ] "
+.IR ALGO-LIST " := [ " ALGO-LIST " ] " ALGO
 
 .ti -8
-.IR ENCAP " := " ENCAP-TYPE " " SPORT " " DPORT " " OADDR
-
-.ti -8
-.IR ENCAP-TYPE " := "
-.B espinudp
-.RB " | "
-.B espinudp-nonike
+.IR ALGO " :="
+.RB "{ " enc " | " auth " | " comp " } " 
+.IR ALGO-NAME " " ALGO-KEY
+.R "|"
+.br
+.B aead
+.IR ALGO-NAME " " ALGO-KEY " " ALGO-ICV-LEN
+.R "|"
+.br
+.B auth-trunc
+.IR ALGO-NAME " " ALGO-KEY " " ALGO-TRUNC-LEN
 
 .ti -8
-.IR ALGO-LIST " := [ "
-.IR ALGO-LIST " ] | [ "
-.IR ALGO " ] "
+.IR MODE " := "
+.BR transport " | " tunnel " | " ro " | " in_trigger " | " beet
 
 .ti -8
-.IR ALGO " := "
-.IR ALGO_TYPE
-.IR ALGO_NAME
-.IR ALGO_KEY
+.IR FLAG-LIST " := [ " FLAG-LIST " ] " FLAG
 
 .ti -8
-.IR ALGO_TYPE " := "
-.RB " [ " enc " | " auth " | " comp " ] "
+.IR FLAG " :="
+.BR noecn " | " decap-dscp " | " nopmtudisc " | " wildrecv " | " icmp " | " af-unspec " | " align4
 
 .ti -8
-.IR SELECTOR " := "
-.B src
-.IR ADDR "[/" PLEN "]"
-.B dst
-.IR ADDR "[/" PLEN "]"
-.RI " [ " UPSPEC " ] "
-.RB " [ " dev
-.IR DEV " ] "
+.IR SELECTOR " :="
+.RB "[ " src
+.IR ADDR "[/" PLEN "] ]"
+.RB "[ " dst
+.IR ADDR "[/" PLEN "] ]"
+.RB "[ " dev
+.IR DEV " ]"
+.br
+.RI "[ " UPSPEC " ]"
 
 .ti -8
 .IR UPSPEC " := "
-.B proto
-.IR PROTO " [[ "
-.B sport
-.IR PORT " ] "
-.RB " [ " dport
-.IR PORT " ] | "
+.BR proto " {"
+.IR PROTO " |"
+.br
+.RB "{ " tcp " | " udp " | " sctp " | " dccp " } [ " sport
+.IR PORT " ]"
+.RB "[ " dport
+.IR PORT " ] |"
 .br
-.RB " [ " type
-.IR NUMBER " ] "
-.RB " [ " code
-.IR NUMBER " ] | "
+.RB "{ " icmp " | " ipv6-icmp " | " mobility-header " } [ " type
+.IR NUMBER " ]"
+.RB "[ " code
+.IR NUMBER " ] |"
 .br
-.RB " [ " key
-.IR KEY " ]] "
+.BR gre " [ " key
+.RI "{ " DOTTED-QUAD " | " NUMBER " } ] }"
 
 .ti -8
-.IR LIMIT-LIST " := [ " LIMIT-LIST " ] |"
-.RB " [ "limit
-.IR LIMIT " ] "
+.IR LIMIT-LIST " := [ " LIMIT-LIST " ]"
+.B limit
+.I LIMIT
 
 .ti -8
-.IR LIMIT " := "
-.RB " [ [" time-soft "|" time-hard "|" time-use-soft "|" time-use-hard "]"
-.IR SECONDS " ] | "
-.RB "[ ["byte-soft "|" byte-hard "]"
-.IR SIZE " ] | "
+.IR LIMIT " :="
+.RB "{ " time-soft " | " time-hard " | " time-use-soft " | " time-use-hard " }"
+.IR "SECONDS" " |"
 .br
-.RB " [ ["packet-soft "|" packet-hard "]"
-.IR COUNT " ] "
-
-.ti -8
-.BR "ip xfrm policy" " { " add " | " update " } " " dir "
-.IR DIR
-.IR SELECTOR " [ "
-.BR index
-.IR INDEX " ] "
+.RB "{ " byte-soft " | " byte-hard " }"
+.IR SIZE " |"
 .br
-.RB " [ " ptype
-.IR PTYPE " ] "
-.RB " [ " action
-.IR ACTION " ] "
-.RB " [ " priority
-.IR PRIORITY " ] "
-.br
-.RI " [ " LIMIT-LIST " ] [ "
-.IR TMPL-LIST " ] "
+.RB "{ " packet-soft " | " packet-hard " }"
+.I COUNT
 
 .ti -8
-.BR "ip xfrm policy" " { " delete " | " get " } " " dir "
-.IR DIR " [ " SELECTOR " | "
-.BR index
-.IR INDEX
-.RB " ] "
-.br
-.RB " [ " ptype
-.IR PTYPE " ] "
+.IR ENCAP " :="
+.RB "{ " espinudp " | " espinudp-nonike " }"
+.IR SPORT " " DPORT " " OADDR
 
 .ti -8
-.BR "ip xfrm policy" " { " deleteall " | " list " } "
-.RB " [ " dir
-.IR DIR " ] [ "
-.IR SELECTOR " ] "
-.br
-.RB " [ " index
-.IR INDEX " ] "
-.RB " [ " action
-.IR ACTION " ] "
-.RB " [ " priority
-.IR PRIORITY " ] "
+.BR "ip xfrm policy" " { " add " | " update " }"
+.I SELECTOR
+.B dir
+.I DIR
+.RB "[ " ctx
+.IR CTX " ]"
+.RB "[ " mark
+.I MARK
+.RB "[ " mask
+.IR MASK " ] ]"
+.RB "[ " index
+.IR INDEX " ]"
+.RB "[ " ptype
+.IR PTYPE " ]"
+.RB "[ " action
+.IR ACTION " ]"
+.RB "[ " priority
+.IR PRIORITY " ]"
+.RB "[ " flag
+.IR FLAG-LIST " ]"
+.RI "[ " LIMIT-LIST " ] [ " TMPL-LIST " ]"
+
+.ti -8
+.BR "ip xfrm policy" " { " delete " | " get " }"
+.RI "{ " SELECTOR " | "
+.B index
+.IR INDEX " }"
+.B dir
+.I DIR
+.RB "[ " ctx
+.IR CTX " ]"
+.RB "[ " mark
+.I MARK
+.RB "[ " mask
+.IR MASK " ] ]"
+.RB "[ " ptype
+.IR PTYPE " ]"
+
+.ti -8
+.BR "ip xfrm policy" " { " deleteall " | " list " }"
+.RI "[ " SELECTOR " ]"
+.RB "[ " dir
+.IR DIR " ]"
+.RB "[ " index
+.IR INDEX " ]"
+.RB "[ " ptype
+.IR PTYPE " ]"
+.RB "[ " action
+.IR ACTION " ]"
+.RB "[ " priority
+.IR PRIORITY " ]"
 
 .ti -8
 .B "ip xfrm policy flush"
-.RB " [ " ptype
-.IR PTYPE " ] "
+.RB "[ " ptype
+.IR PTYPE " ]"
 
 .ti -8
-.B "ip xfrm count"
+.B "ip xfrm policy count"
 
 .ti -8
-.IR PTYPE " := "
-.RB " [ " main " | " sub " ] "
-.B (default=main)
+.IR SELECTOR " :="
+.RB "[ " src
+.IR ADDR "[/" PLEN "] ]"
+.RB "[ " dst
+.IR ADDR "[/" PLEN "] ]"
+.RB "[ " dev
+.IR DEV " ]"
+.RI "[ " UPSPEC " ]"
 
 .ti -8
-.IR DIR " := "
-.RB " [ " in " | " out " | " fwd " ] "
+.IR UPSPEC " := "
+.BR proto " {"
+.IR PROTO " |"
+.br
+.RB "{ " tcp " | " udp " | " sctp " | " dccp " } [ " sport
+.IR PORT " ]"
+.RB "[ " dport
+.IR PORT " ] |"
+.br
+.RB "{ " icmp " | " ipv6-icmp " | " mobility-header " } [ " type
+.IR NUMBER " ]"
+.RB "[ " code
+.IR NUMBER " ] |"
+.br
+.BR gre " [ " key
+.RI "{ " DOTTED-QUAD " | " NUMBER " } ] }"
 
 .ti -8
-.IR SELECTOR " := "
-.B src
-.IR ADDR "[/" PLEN "]"
-.B dst
-.IR ADDR "[/" PLEN] " [ " UPSPEC
-.RB " ] [ " dev
-.IR DEV " ] "
+.IR DIR " := "
+.BR in " | " out " | " fwd
 
 .ti -8
-.IR UPSPEC " := "
-.B proto
-.IR PROTO " [ "
-.RB " [ " sport
-.IR PORT " ] "
-.RB " [ " dport
-.IR PORT " ] | "
-.br
-.RB " [ " type
-.IR NUMBER " ] "
-.RB " [ " code
-.IR NUMBER " ] | "
-.br
-.RB " [ " key
-.IR KEY " ] ] "
+.IR PTYPE " := "
+.BR main " | " sub
 
 .ti -8
 .IR ACTION " := "
-.RB " [ " allow " | " block " ]"
-.B (default=allow)
+.BR allow " | " block
 
 .ti -8
-.IR LIMIT-LIST " := "
-.RB " [ "
-.IR LIMIT-LIST " ] | "
-.RB " [ " limit
-.IR LIMIT " ] "
+.IR FLAG-LIST " := [ " FLAG-LIST " ] " FLAG
 
 .ti -8
-.IR LIMIT " := "
-.RB " [ [" time-soft "|" time-hard "|" time-use-soft "|" time-use-hard "]"
-.IR SECONDS " ] | "
-.RB " [ [" byte-soft "|" byte-hard "]"
-.IR SIZE " ] | "
-.br [ "
-.RB "[" packet-soft "|" packet-hard "]"
-.IR NUMBER " ] "
+.IR FLAG " :="
+.BR localok " | " icmp
 
 .ti -8
-.IR TMPL-LIST " := "
-.B " [ "
-.IR TMPL-LIST " ] | "
-.RB " [ " tmpl
-.IR TMPL " ] "
+.IR LIMIT-LIST " := [ " LIMIT-LIST " ]"
+.B limit
+.I LIMIT
 
 .ti -8
-.IR TMPL " := "
-.IR ID " [ "
-.B mode
-.IR MODE " ] "
-.RB " [ " reqid
-.IR REQID " ] "
-.RB " [ " level
-.IR LEVEL " ] "
+.IR LIMIT " :="
+.RB "{ " time-soft " | " time-hard " | " time-use-soft " | " time-use-hard " }"
+.IR "SECONDS" " |"
+.br
+.RB "{ " byte-soft " | " byte-hard " }"
+.IR SIZE " |"
+.br
+.RB "{ " packet-soft " | " packet-hard " }"
+.I COUNT
 
 .ti -8
-.IR ID " := "
-.RB " [ " src
-.IR ADDR " ] "
-.RB " [ " dst
-.IR ADDR " ] "
-.RB " [ " proto
-.IR XFRM_PROTO " ] "
-.RB " [ " spi
-.IR SPI " ] "
+.IR TMPL-LIST " := [ " TMPL-LIST " ]"
+.B tmpl
+.I TMPL
 
 .ti -8
-.IR XFRM_PROTO " := "
-.RB " [ " esp " | " ah " | " comp " | " route2 " | " hao " ] "
+.IR TMPL " := " ID
+.RB "[ " mode
+.IR MODE " ]"
+.RB "[ " reqid
+.IR REQID " ]"
+.RB "[ " level
+.IR LEVEL " ]"
+
+.ti -8
+.IR ID " :="
+.RB "[ " src
+.IR ADDR " ]"
+.RB "[ " dst
+.IR ADDR " ]"
+.RB "[ " proto
+.IR XFRM-PROTO " ]"
+.RB "[ " spi
+.IR SPI " ]"
+
+.ti -8
+.IR XFRM-PROTO " :="
+.BR esp " | " ah " | " comp " | " route2 " | " hao
 
 .ti -8
 .IR MODE " := "
-.RB " [ " transport " | " tunnel " | " beet " ] "
-.B (default=transport)
+.BR transport " | " tunnel " | " ro " | " in_trigger " | " beet
 
 .ti -8
-.IR LEVEL " := "
-.RB " [ " required " | " use " ] "
-.B (default=required)
+.IR LEVEL " :="
+.BR required " | " use
 
 .ti -8
-.BR "ip xfrm monitor" " [ " all " | "
-.IR LISTofOBJECTS " ] "
+.BR "ip xfrm monitor" " [ " all " |"
+.IR LISTofXFRM-OBJECTS " ]"
 
 .in -8
 .ad b
@@ -849,10 +879,6 @@ host addresses.
 .B tunnel
 - tunnel over IP.
 
-.TP
-.B xfrm
-- framework for IPsec protocol.
-
 .PP
 The names of all objects may be written in full or
 abbreviated form, f.e.
@@ -2470,169 +2496,226 @@ at any time.
 It prepends the history with the state snapshot dumped at the moment
 of starting.
 
-.SH ip xfrm - setting xfrm
-xfrm is an IP framework, which can transform format of the datagrams,
-.br
-i.e. encrypt the packets with some algorithm. xfrm policy and xfrm state
-are associated through templates
-.IR TMPL_LIST "."
-This framework is used as a part of IPsec protocol.
+.SH ip xfrm - transform configuration
+xfrm is an IP framework for transforming packets (such as encrypting
+their payloads). This framework is used to implement the IPsec protocol
+suite (with the
+.B state
+object operating on the Security Association Database, and the
+.B policy
+object operating on the Security Policy Database). It is also used for
+the IP Payload Compression Protocol and features of Mobile IPv6.
 
 .SS ip xfrm state add - add new state into xfrm
 
-.SS ip xfrm state update - update existing xfrm state
+.SS ip xfrm state update - update existing state in xfrm
+
+.SS ip xfrm state allocspi - allocate an SPI value
+
+.SS ip xfrm state delete - delete existing state in xfrm
+
+.SS ip xfrm state get - get existing state in xfrm
 
-.SS ip xfrm state allocspi - allocate SPI value
+.SS ip xfrm state deleteall - delete all existing state in xfrm
+
+.SS ip xfrm state list - print out the list of existing state in xfrm
+
+.SS ip xfrm state flush - flush all state in xfrm
+
+.SS ip xfrm state count - count all existing state in xfrm
+
+.TP
+.IR ID
+is specified by a source address, destination address,
+.RI "transform protocol " XFRM-PROTO ","
+and/or Security Parameter Index
+.IR SPI "."
+
+.TP
+.I XFRM-PROTO
+specifies a transform protocol:
+.RB "IPsec Encapsulating Security Payload (" esp "),"
+.RB "IPsec Authentication Header (" ah "),"
+.RB "IP Payload Compression (" comp "),"
+.RB "Mobile IPv6 Type 2 Routing Header (" route2 "), or"
+.RB "Mobile IPv6 Home Address Option (" hao ")."
+
+.TP
+.I ALGO-LIST
+specifies one or more algorithms
+.IR ALGO
+to use. Algorithm types include
+.RB "encryption (" enc "),"
+.RB "authentication (" auth "),"
+.RB "authentication with a specified truncation length (" auth-trunc "),"
+.RB "authenticated encryption with associated data (" aead "), and"
+.RB "compression (" comp ")."
+For each algorithm used, the algorithm type, the algorithm name
+.IR ALGO-NAME ","
+and the key
+.I ALGO-KEY
+must be specified. For
+.BR aead ","
+the Integrity Check Value length
+.I ALGO-ICV-LEN
+must additionally be specified.
+For
+.BR auth-trunc ","
+the signature truncation length
+.I ALGO-TRUNC-LEN
+must additionally be specified.
 
 .TP
 .I MODE
-is set as default to
-.BR transport ","
-but it could be set to
-.BR tunnel "," ro " or " beet "."
+specifies a mode of operation:
+.RB "IPsec transport mode (" transport "), "
+.RB "IPsec tunnel mode (" tunnel "), "
+.RB "Mobile IPv6 route optimization mode (" ro "), "
+.RB "Mobile IPv6 inbound trigger mode (" in_trigger "), or "
+.RB "IPsec ESP Bound End-to-End Tunnel Mode (" beet ")."
 
 .TP
 .I FLAG-LIST
-contains one or more flags.
+contains one or more of the following optional flags:
+.BR noecn ", " decap-dscp ", " nopmtudisc ", " wildrecv ", " icmp ", "
+.BR af-unspec ", or " align4 "."
 
 .TP
-.I FLAG
-could be set to
-.BR noecn ", " decap-dscp " or " wildrecv "."
+.IR SELECTOR
+selects the traffic that will be controlled by the policy, based on the source
+address, the destination address, the network device, and/or
+.IR UPSPEC "."
 
 .TP
-.I ENCAP
-encapsulation is set to encapsulation type
-.IR ENCAP-TYPE ", source port " SPORT ", destination port "  DPORT " and " OADDR "."
+.IR UPSPEC
+selects traffic by protocol. For the
+.BR tcp ", " udp ", " sctp ", or " dccp
+protocols, the source and destination port can optionally be specified.
+For the
+.BR icmp ", " ipv6-icmp ", or " mobility-header
+protocols, the type and code numbers can optionally be specified.
+For the
+.B gre
+protocol, the key can optionally be specified as a dotted-quad or number.
+Other protocols can be selected by name or number
+.IR PROTO "."
 
 .TP
-.I ENCAP-TYPE
-could be set to
-.BR espinudp " or " espinudp-nonike "."
+.I LIMIT-LIST
+sets limits in seconds, bytes, or numbers of packets.
 
 .TP
-.I ALGO-LIST
-contains one or more algorithms
-.I ALGO
-which depend on the type of algorithm set by
-.IR ALGO_TYPE "."
-Valid algorithms are:
-.BR enc ", " auth " or " comp "."
+.I ENCAP
+encapsulates packets with protocol
+.BR espinudp " or " espinudp-nonike ","
+.RI "using source port " SPORT ", destination port "  DPORT
+.RI ", and original address " OADDR "."
 
 .SS ip xfrm policy add - add a new policy
 
 .SS ip xfrm policy update - update an existing policy
 
-.SS ip xfrm policy delete - delete existing policy
+.SS ip xfrm policy delete - delete an existing policy
 
-.SS ip xfrm policy get - get existing policy
+.SS ip xfrm policy get - get an existing policy
 
-.SS ip xfrm policy deleteall - delete all existing xfrm policy
+.SS ip xfrm policy deleteall - delete all existing xfrm policies
 
-.SS ip xfrm policy list - print out the list of xfrm policy
+.SS ip xfrm policy list - print out the list of xfrm policies
 
 .SS ip xfrm policy flush - flush policies
-It can be flush
-.BR all
-policies or only those specified with
-.BR ptype "."
 
-.TP
-.BI dir " DIR "
-directory could be one of these:
-.BR "inp", " out " or " fwd".
+.SS ip xfrm policy count - count existing policies
 
 .TP
 .IR SELECTOR
-selects for which addresses will be set up the policy. The selector
-is defined by source and destination address.
+selects the traffic that will be controlled by the policy, based on the source
+address, the destination address, the network device, and/or
+.IR UPSPEC "."
 
 .TP
 .IR UPSPEC
-is defined by source port
-.BR sport ", "
-destination port
-.BR dport ", " type
-as number,
-.B code
-also number and
-.BR key
-as dotted-quad or number.
+selects traffic by protocol. For the
+.BR tcp ", " udp ", " sctp ", or " dccp
+protocols, the source and destination port can optionally be specified.
+For the
+.BR icmp ", " ipv6-icmp ", or " mobility-header
+protocols, the type and code numbers can optionally be specified.
+For the
+.B gre
+protocol, the key can optionally be specified as a dotted-quad or number.
+Other protocols can be selected by name or number
+.IR PROTO "."
 
 .TP
-.BI dev " DEV "
-specify network device.
+.I DIR
+selects the policy direction as
+.BR in ", " out ", or " fwd "."
 
 .TP
-.BI index " INDEX "
-the number of indexed policy.
+.I CTX
+sets the security context.
 
 .TP
-.BI ptype " PTYPE "
-type is set as default on
-.BR "main" ,
-could be switch on
-.BR "sub" .
+.I PTYPE
+can be
+.BR main " (default) or " sub "."
 
 .TP
-.BI action " ACTION "
-is set as default on
-.BR "allow".
-It could be switch on
-.BR "block".
+.I ACTION
+can be
+.BR allow " (default) or " block "."
 
 .TP
-.BI priority " PRIORITY "
-priority is a number. Default priority is set on zero.
+.I PRIORITY
+is a number that defaults to zero.
 
 .TP
-.IR LIMIT-LIST
-limits are set in seconds, bytes or numbers of packets.
+.I FLAG-LIST
+contains one or both of the following optional flags:
+.BR local " or " icmp "."
 
 .TP
-.IR TMPL-LIST
-template list is based on
-.IR ID ","
-.BR mode ", " reqid " and " level ". "
+.I LIMIT-LIST
+sets limits in seconds, bytes, or numbers of packets.
 
 .TP
-.IR ID
-is specified by source address, destination address,
-.I proto
-and value of
-.IR spi "."
+.I TMPL-LIST
+is a template list specified using
+.IR ID ", " MODE ", " REQID ", and/or " LEVEL ". "
 
 .TP
-.IR XFRM_PROTO
-values:
-.BR esp ", " ah ", " comp ", " route2 " or " hao "."
+.IR ID
+is specified by a source address, destination address,
+.RI "transform protocol " XFRM-PROTO ","
+and/or Security Parameter Index
+.IR SPI "."
 
 .TP
-.IR MODE
-is set as default on
-.BR transport ","
-but it could be set on
-.BR tunnel " or " beet "."
+.I XFRM-PROTO
+specifies a transform protocol:
+.RB "IPsec Encapsulating Security Payload (" esp "),"
+.RB "IPsec Authentication Header (" ah "),"
+.RB "IP Payload Compression (" comp "),"
+.RB "Mobile IPv6 Type 2 Routing Header (" route2 "), or"
+.RB "Mobile IPv6 Home Address Option (" hao ")."
 
 .TP
-.IR LEVEL
-is set as default on
-.BR required
-and the other choice is
-.BR use "."
+.I MODE
+specifies a mode of operation:
+.RB "IPsec transport mode (" transport "), "
+.RB "IPsec tunnel mode (" tunnel "), "
+.RB "Mobile IPv6 route optimization mode (" ro "), "
+.RB "Mobile IPv6 inbound trigger mode (" in_trigger "), or "
+.RB "IPsec ESP Bound End-to-End Tunnel Mode (" beet ")."
 
 .TP
-.IR UPSPEC
-is specified by
-.BR sport " and " dport " (for UDP/TCP), "
-.BR type " and " code " (for ICMP; as number) or "
-.BR key " (for GRE; as dotted-quad or number)."
-.
+.I LEVEL
+can be
+.BR required " (default) or " use "."
 
-.SS ip xfrm monitor - is used for listing all objects or defined group of them.
-The
-.B xfrm monitor
-can monitor the policies for all objects or defined group of them.
+.SS ip xfrm monitor - state monitoring for xfrm objects
+The xfrm objects to monitor can be optionally specified.
 
 .SH HISTORY
 .B ip
-- 
1.7.1
