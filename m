From: jamal <hadi@cyberus.ca>
Subject: [PATCH] xfrm: use proper kernel types
Date: Tue, 09 Feb 2010 18:21:17 -0500
Message-ID: <1265757677.3688.87.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-9PL0QV5Sp7Z77X1WThM6"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:29492 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab0BIXVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 18:21:20 -0500
Received: by qw-out-2122.google.com with SMTP id 9so979190qwb.37
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 15:21:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9PL0QV5Sp7Z77X1WThM6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

One of those pedantic cowboy fixes ..

cheers,
jamal

--=-9PL0QV5Sp7Z77X1WThM6
Content-Disposition: attachment; filename="xfrm-types"
Content-Type: text/plain; name="xfrm-types"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 69207e6f507a596496d54b9b1b56028f310c3ee5
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Feb 9 18:16:42 2010 -0500

    xfrm: use proper kernel types
    
    kernel side should use uxx instead of __uxx types
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 60c2770..66d1586 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -317,8 +317,8 @@ extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 struct xfrm_type {
 	char			*description;
 	struct module		*owner;
-	__u8			proto;
-	__u8			flags;
+	u8			proto;
+	u8			flags;
 #define XFRM_TYPE_NON_FRAGMENT	1
 #define XFRM_TYPE_REPLAY_PROT	2
 #define XFRM_TYPE_LOCAL_COADDR	4
@@ -434,24 +434,24 @@ struct xfrm_tmpl {
 
 	unsigned short		encap_family;
 
-	__u32			reqid;
+	u32			reqid;
 
 /* Mode: transport, tunnel etc. */
-	__u8			mode;
+	u8			mode;
 
 /* Sharing mode: unique, this session only, this user only etc. */
-	__u8			share;
+	u8			share;
 
 /* May skip this transfomration if no SA is found */
-	__u8			optional;
+	u8			optional;
 
 /* Skip aalgos/ealgos/calgos checks. */
-	__u8			allalgs;
+	u8			allalgs;
 
 /* Bit mask of algos allowed for acquisition */
-	__u32			aalgos;
-	__u32			ealgos;
-	__u32			calgos;
+	u32			aalgos;
+	u32			ealgos;
+	u32			calgos;
 };
 
 #define XFRM_MAX_DEPTH		6
@@ -770,7 +770,7 @@ static __inline__ int addr_match(void *token1, void *token2, int prefixlen)
 	int pdw;
 	int pbi;
 
-	pdw = prefixlen >> 5;	  /* num of whole __u32 in prefix */
+	pdw = prefixlen >> 5;	  /* num of whole u32 in prefix */
 	pbi = prefixlen &  0x1f;  /* num of bits in incomplete u32 in prefix */
 
 	if (pdw)
@@ -1259,7 +1259,7 @@ struct xfrm_algo_desc {
 /* XFRM tunnel handlers.  */
 struct xfrm_tunnel {
 	int (*handler)(struct sk_buff *skb);
-	int (*err_handler)(struct sk_buff *skb, __u32 info);
+	int (*err_handler)(struct sk_buff *skb, u32 info);
 
 	struct xfrm_tunnel *next;
 	int priority;
@@ -1500,7 +1500,7 @@ static inline int xfrm_addr_cmp(xfrm_address_t *a, xfrm_address_t *b,
 	switch (family) {
 	default:
 	case AF_INET:
-		return (__force __u32)a->a4 - (__force __u32)b->a4;
+		return (__force u32)a->a4 - (__force u32)b->a4;
 	case AF_INET6:
 		return ipv6_addr_cmp((struct in6_addr *)a,
 				     (struct in6_addr *)b);

--=-9PL0QV5Sp7Z77X1WThM6--

