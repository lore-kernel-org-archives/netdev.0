From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: [PATCH] IPV6: make several ndisc private stuff static
Date: Thu, 26 Jun 2003 16:23:07 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030626.162307.85181540.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Make several ndisc private stuff static.
Thanks.

Index: linux-2.5/include/net/ndisc.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/ndisc.h,v
retrieving revision 1.5
diff -u -d -r1.5 ndisc.h
--- linux-2.5/include/net/ndisc.h	27 Sep 2002 02:20:35 -0000	1.5
+++ linux-2.5/include/net/ndisc.h	26 Jun 2003 05:28:50 -0000
@@ -56,20 +56,6 @@
 	__u8		nd_opt_len;
 } __attribute__((__packed__));
 
-struct ndisc_options {
-	struct nd_opt_hdr *nd_opt_array[7];
-	struct nd_opt_hdr *nd_opt_piend;
-};
-
-#define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
-#define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
-#define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
-#define nd_opts_pi_end		nd_opt_piend
-#define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
-#define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
-
-extern struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur, struct nd_opt_hdr *end);
-extern struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len, struct ndisc_options *ndopts);
 
 extern int			ndisc_init(struct net_proto_family *ops);
 
Index: linux-2.5/net/ipv6/ndisc.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/ndisc.c,v
retrieving revision 1.40
diff -u -d -r1.40 ndisc.c
--- linux-2.5/net/ipv6/ndisc.c	21 Jun 2003 16:21:01 -0000	1.40
+++ linux-2.5/net/ipv6/ndisc.c	26 Jun 2003 05:28:50 -0000
@@ -144,6 +144,19 @@
 	.gc_thresh3 =	1024,
 };
 
+/* ND options */
+struct ndisc_options {
+	struct nd_opt_hdr *nd_opt_array[7];
+	struct nd_opt_hdr *nd_opt_piend;
+};
+
+#define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
+#define nd_opts_tgt_lladdr	nd_opt_array[ND_OPT_TARGET_LL_ADDR]
+#define nd_opts_pi		nd_opt_array[ND_OPT_PREFIX_INFO]
+#define nd_opts_pi_end		nd_opt_piend
+#define nd_opts_rh		nd_opt_array[ND_OPT_REDIRECT_HDR]
+#define nd_opts_mtu		nd_opt_array[ND_OPT_MTU]
+
 #define NDISC_OPT_SPACE(len) (((len)+2+7)&~7)
 
 static u8 *ndisc_fill_option(u8 *opt, int type, void *data, int data_len)
@@ -160,8 +173,8 @@
 	return opt + space;
 }
 
-struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
-				     struct nd_opt_hdr *end)
+static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
+					    struct nd_opt_hdr *end)
 {
 	int type;
 	if (!cur || !end || cur >= end)
@@ -173,8 +186,8 @@
 	return (cur <= end && cur->nd_opt_type == type ? cur : NULL);
 }
 
-struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
-					  struct ndisc_options *ndopts)
+static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
+						 struct ndisc_options *ndopts)
 {
 	struct nd_opt_hdr *nd_opt = (struct nd_opt_hdr *)opt;
 
@@ -375,7 +388,7 @@
  *	Send a Neighbour Advertisement
  */
 
-int ndisc_output(struct sk_buff *skb)
+static int ndisc_output(struct sk_buff *skb)
 {
 	if (skb) {
 		struct neighbour *neigh = (skb->dst ? skb->dst->neighbour : NULL);
@@ -701,7 +714,7 @@
 	}
 }
 
-void ndisc_recv_ns(struct sk_buff *skb)
+static void ndisc_recv_ns(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb->h.raw;
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;
@@ -897,7 +910,7 @@
 	return;
 }
 
-void ndisc_recv_na(struct sk_buff *skb)
+static void ndisc_recv_na(struct sk_buff *skb)
 {
 	struct nd_msg *msg = (struct nd_msg *)skb->h.raw;
 	struct in6_addr *saddr = &skb->nh.ipv6h->saddr;


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
