From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 6/7] ip/xfrm: Improve usage text and documentation
Date: Mon, 25 Mar 2013 10:23:18 -0400
Message-ID: <1364221399-1024-6-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42078 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758260Ab3CYOXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:30 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEHQ1s017624 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:29 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ALGO-KEY to ALGO-KEYMAT to make it more obvious that the
keying material might need to contain more than just the key (such
as a salt or nonce value).

List the algorithm names that currently exist in the kernel.

Indicate that for IPComp, the Compression Parameter Index (CPI) is
used as the SPI.

Group the list of mode values by transform protocol.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/xfrm_policy.c   |    2 +-
 ip/xfrm_state.c    |   18 ++++----
 man/man8/ip-xfrm.8 |  112 +++++++++++++++++++++++++++++++++++-----------------
 3 files changed, 85 insertions(+), 47 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index bf263e0..27c9a65 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -96,7 +96,7 @@ static void usage(void)
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_COMP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ROUTING));
 	fprintf(stderr, "%s\n", strxf_xfrmproto(IPPROTO_DSTOPTS));
- 	fprintf(stderr, "MODE := transport | tunnel | ro | in_trigger | beet\n");
+ 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
 	fprintf(stderr, "LEVEL := required | use\n");
 
 	exit(-1);
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 9b374ee..ee06f7d 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -79,14 +79,14 @@ static void usage(void)
 	fprintf(stderr, "ALGO := { ");
 	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
 	fprintf(stderr, "%s", strxf_algotype(XFRMA_ALG_AUTH));
-	fprintf(stderr, " } ALGO-NAME ALGO-KEY |\n");
+	fprintf(stderr, " } ALGO-NAME ALGO-KEYMAT |\n");
 	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AUTH_TRUNC));
-	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-TRUNC-LEN |\n");
+	fprintf(stderr, " ALGO-NAME ALGO-KEYMAT ALGO-TRUNC-LEN |\n");
 	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_AEAD));
-	fprintf(stderr, " ALGO-NAME ALGO-KEY ALGO-ICV-LEN |\n");
+	fprintf(stderr, " ALGO-NAME ALGO-KEYMAT ALGO-ICV-LEN |\n");
 	fprintf(stderr, "        %s", strxf_algotype(XFRMA_ALG_COMP));
 	fprintf(stderr, " ALGO-NAME\n");
- 	fprintf(stderr, "MODE := transport | tunnel | ro | in_trigger | beet\n");
+ 	fprintf(stderr, "MODE := transport | tunnel | beet | ro | in_trigger\n");
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
 	fprintf(stderr, "FLAG := noecn | decap-dscp | nopmtudisc | wildrecv | icmp | af-unspec | align4\n");
 	fprintf(stderr, "SELECTOR := [ src ADDR[/PLEN] ] [ dst ADDR[/PLEN] ] [ dev DEV ] [ UPSPEC ]\n");
@@ -119,7 +119,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 
 #if 0
 	/* XXX: verifying both name and key is required! */
-	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEY will send to kernel promiscuously! (verifying them isn't implemented yet)\n");
+	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEYMAT values will be sent to the kernel promiscuously! (verifying them isn't implemented yet)\n");
 #endif
 
 	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
@@ -139,7 +139,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 		/* calculate length of the converted values(real key) */
 		len = (plen + 1) / 2;
 		if (len > max)
-			invarg("\"ALGO-KEY\" makes buffer overflow\n", key);
+			invarg("ALGO-KEYMAT value makes buffer overflow\n", key);
 
 		for (i = - (plen % 2), j = 0; j < len; i += 2, j++) {
 			char vbuf[3];
@@ -150,7 +150,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 			vbuf[2] = '\0';
 
 			if (get_u8(&val, vbuf, 16))
-				invarg("\"ALGO-KEY\" is invalid", key);
+				invarg("ALGO-KEYMAT value is invalid", key);
 
 			buf[j] = val;
 		}
@@ -158,7 +158,7 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 		len = slen;
 		if (len > 0) {
 			if (len > max)
-				invarg("\"ALGO-KEY\" makes buffer overflow\n", key);
+				invarg("ALGO-KEYMAT value makes buffer overflow\n", key);
 
 			strncpy(buf, key, len);
 		}
@@ -416,7 +416,7 @@ static int xfrm_state_modify(int cmd, unsigned flags, int argc, char **argv)
 				case XFRMA_ALG_AUTH:
 				case XFRMA_ALG_AUTH_TRUNC:
 					if (!NEXT_ARG_OK())
-						missarg("ALGO-KEY");
+						missarg("ALGO-KEYMAT");
 					NEXT_ARG();
 					key = *argv;
 					break;
diff --git a/man/man8/ip-xfrm.8 b/man/man8/ip-xfrm.8
index 6017bc2..1d33eed 100644
--- a/man/man8/ip-xfrm.8
+++ b/man/man8/ip-xfrm.8
@@ -118,20 +118,20 @@ ip-xfrm \- transform configuration
 .ti -8
 .IR ALGO " :="
 .RB "{ " enc " | " auth " } " 
-.IR ALGO-NAME " " ALGO-KEY " |"
+.IR ALGO-NAME " " ALGO-KEYMAT " |"
 .br
 .B auth-trunc
-.IR ALGO-NAME " " ALGO-KEY " " ALGO-TRUNC-LEN " |"
+.IR ALGO-NAME " " ALGO-KEYMAT " " ALGO-TRUNC-LEN " |"
 .br
 .B aead
-.IR ALGO-NAME " " ALGO-KEY " " ALGO-ICV-LEN " |"
+.IR ALGO-NAME " " ALGO-KEYMAT " " ALGO-ICV-LEN " |"
 .br
 .B comp
 .IR ALGO-NAME
 
 .ti -8
 .IR MODE " := "
-.BR transport " | " tunnel " | " ro " | " in_trigger " | " beet
+.BR transport " | " tunnel " | " beet " | " ro " | " in_trigger
 
 .ti -8
 .IR FLAG-LIST " := [ " FLAG-LIST " ] " FLAG
@@ -345,7 +345,7 @@ ip-xfrm \- transform configuration
 
 .ti -8
 .IR MODE " := "
-.BR transport " | " tunnel " | " ro " | " in_trigger " | " beet
+.BR transport " | " tunnel " | " beet " | " ro " | " in_trigger
 
 .ti -8
 .IR LEVEL " :="
@@ -393,6 +393,8 @@ is specified by a source address, destination address,
 .RI "transform protocol " XFRM-PROTO ","
 and/or Security Parameter Index
 .IR SPI "."
+(For IP Payload Compression, the Compression Parameter Index or CPI is used for
+.IR SPI ".)"
 
 .TP
 .I XFRM-PROTO
@@ -405,37 +407,68 @@ specifies a transform protocol:
 
 .TP
 .I ALGO-LIST
-specifies one or more algorithms
-.IR ALGO
-to use. Algorithm types include
+contains one or more algorithms to use. Each algorithm
+.I ALGO
+is specified by:
+.RS
+.IP \[bu]
+the algorithm type:
 .RB "encryption (" enc "),"
-.RB "authentication (" auth "),"
-.RB "authentication with a specified truncation length (" auth-trunc "),"
-.RB "authenticated encryption with associated data (" aead "), and"
-.RB "compression (" comp ")."
-For each algorithm used, the algorithm type, the algorithm name
-.IR ALGO-NAME ","
-and the key
-.I ALGO-KEY
-must be specified. For
-.BR aead ","
+.RB "authentication (" auth " or " auth-trunc "),"
+.RB "authenticated encryption with associated data (" aead "), or"
+.RB "compression (" comp ")"
+.IP \[bu]
+the algorithm name
+.IR ALGO-NAME
+(see below)
+.IP \[bu]
+.RB "(for all except " comp ")"
+the keying material
+.IR ALGO-KEYMAT ","
+which may include both a key and a salt or nonce value; refer to the
+corresponding RFC
+.IP \[bu]
+.RB "(for " auth-trunc " only)"
+the truncation length
+.I ALGO-TRUNC-LEN
+in bits
+.IP \[bu]
+.RB "(for " aead " only)"
 the Integrity Check Value length
 .I ALGO-ICV-LEN
-must additionally be specified.
-For
-.BR auth-trunc ","
-the signature truncation length
-.I ALGO-TRUNC-LEN
-must additionally be specified.
+in bits
+.RE
+
+.nh
+.RS
+Encryption algorithms include
+.BR ecb(cipher_null) ", " cbc(des) ", " cbc(des3_ede) ", " cbc(cast5) ","
+.BR cbc(blowfish) ", " cbc(aes) ", " cbc(serpent) ", " cbc(camellia) ","
+.BR cbc(twofish) ", and " rfc3686(ctr(aes)) "."
+
+Authentication algorithms include
+.BR digest_null ", " hmac(md5) ", " hmac(sha1) ", " hmac(sha256) ","
+.BR hmac(sha384) ", " hmac(sha512) ", " hmac(rmd610) ", and " xcbc(aes) "."
+
+Authenticated encryption with associated data (AEAD) algorithms include
+.BR rfc4106(gcm(aes)) ", " rfc4309(ccm(aes)) ", and " rfc4543(gcm(aes)) "."
+
+Compression algorithms include
+.BR deflate ", " lzs ", and " lzjh "."
+.RE
+.hy
 
 .TP
 .I MODE
-specifies a mode of operation:
-.RB "IPsec transport mode (" transport "), "
-.RB "IPsec tunnel mode (" tunnel "), "
-.RB "Mobile IPv6 route optimization mode (" ro "), "
-.RB "Mobile IPv6 inbound trigger mode (" in_trigger "), or "
-.RB "IPsec ESP Bound End-to-End Tunnel Mode (" beet ")."
+specifies a mode of operation for the transform protocol. IPsec and IP Payload
+Compression modes are
+.BR transport ", " tunnel ","
+and (for IPsec ESP only) Bound End-to-End Tunnel
+.RB "(" beet ")."
+Mobile IPv6 modes are route optimization
+.RB "(" ro ")"
+and inbound trigger
+.RB "(" in_trigger ")."
 
 .TP
 .I FLAG-LIST
@@ -553,6 +586,8 @@ is specified by a source address, destination address,
 .RI "transform protocol " XFRM-PROTO ","
 and/or Security Parameter Index
 .IR SPI "."
+(For IP Payload Compression, the Compression Parameter Index or CPI is used for
+.IR SPI ".)"
 
 .TP
 .I XFRM-PROTO
@@ -565,12 +600,15 @@ specifies a transform protocol:
 
 .TP
 .I MODE
-specifies a mode of operation:
-.RB "IPsec transport mode (" transport "), "
-.RB "IPsec tunnel mode (" tunnel "), "
-.RB "Mobile IPv6 route optimization mode (" ro "), "
-.RB "Mobile IPv6 inbound trigger mode (" in_trigger "), or "
-.RB "IPsec ESP Bound End-to-End Tunnel Mode (" beet ")."
+specifies a mode of operation for the transform protocol. IPsec and IP Payload
+Compression modes are
+.BR transport ", " tunnel ","
+and (for IPsec ESP only) Bound End-to-End Tunnel
+.RB "(" beet ")."
+Mobile IPv6 modes are route optimization
+.RB "(" ro ")"
+and inbound trigger
+.RB "(" in_trigger ")."
 
 .TP
 .I LEVEL
@@ -581,4 +619,4 @@ can be
 The xfrm objects to monitor can be optionally specified.
 
 .SH AUTHOR
-Manpage by David Ward
+Manpage revised by David Ward <david.ward@ll.mit.edu>
-- 
1.7.1
