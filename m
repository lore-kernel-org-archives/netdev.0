From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6]: Mark some xfrm-functions/data static
Date: Sat, 21 Aug 2004 14:43:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41274373.1020001@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090909020708040803030009"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090909020708040803030009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch marks some xfrm-functions/data static.


--------------090909020708040803030009
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/08/21 14:23:10+02:00 kaber@coreworks.de 
#   [XFRM]: mark some functions/data static
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/xfrm6_policy.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +7 -7
#   [XFRM]: mark some functions/data static
# 
# net/ipv6/esp6.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +7 -7
#   [XFRM]: mark some functions/data static
# 
# net/ipv6/ah6.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +5 -5
#   [XFRM]: mark some functions/data static
# 
# net/ipv4/xfrm4_policy.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +6 -6
#   [XFRM]: mark some functions/data static
# 
# net/ipv4/esp4.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +6 -6
#   [XFRM]: mark some functions/data static
# 
# net/ipv4/ah4.c
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +2 -2
#   [XFRM]: mark some functions/data static
# 
# include/net/xfrm.h
#   2004/08/21 14:22:47+02:00 kaber@coreworks.de +0 -2
#   [XFRM]: mark some functions/data static
# 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2004-08-21 14:38:16 +02:00
+++ b/include/net/xfrm.h	2004-08-21 14:38:16 +02:00
@@ -848,8 +848,6 @@
 #endif
 
 void xfrm_policy_init(void);
-void xfrm4_policy_init(void);
-void xfrm6_policy_init(void);
 struct xfrm_policy *xfrm_policy_alloc(int gfp);
 extern int xfrm_policy_walk(int (*func)(struct xfrm_policy *, int, int, void*), void *);
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl);
diff -Nru a/net/ipv4/ah4.c b/net/ipv4/ah4.c
--- a/net/ipv4/ah4.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv4/ah4.c	2004-08-21 14:38:16 +02:00
@@ -116,7 +116,7 @@
 	return err;
 }
 
-int ah_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
+static int ah_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
 	int ah_hlen;
 	struct iphdr *iph;
@@ -184,7 +184,7 @@
 	return -EINVAL;
 }
 
-void ah4_err(struct sk_buff *skb, u32 info)
+static void ah4_err(struct sk_buff *skb, u32 info)
 {
 	struct iphdr *iph = (struct iphdr*)skb->data;
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+(iph->ihl<<2));
diff -Nru a/net/ipv4/esp4.c b/net/ipv4/esp4.c
--- a/net/ipv4/esp4.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv4/esp4.c	2004-08-21 14:38:16 +02:00
@@ -17,7 +17,7 @@
 	__u8		proto;
 };
 
-int esp_output(struct sk_buff *skb)
+static int esp_output(struct sk_buff *skb)
 {
 	int err;
 	struct dst_entry *dst = skb->dst;
@@ -139,7 +139,7 @@
  * expensive, so we only support truncated data, which is the recommended
  * and common case.
  */
-int esp_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
+static int esp_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
 	struct iphdr *iph;
 	struct ip_esp_hdr *esph;
@@ -246,7 +246,7 @@
 	return -EINVAL;
 }
 
-int esp_post_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
+static int esp_post_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
   
 	if (x->encap) {
@@ -320,7 +320,7 @@
 	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
 }
 
-void esp4_err(struct sk_buff *skb, u32 info)
+static void esp4_err(struct sk_buff *skb, u32 info)
 {
 	struct iphdr *iph = (struct iphdr*)skb->data;
 	struct ip_esp_hdr *esph = (struct ip_esp_hdr*)(skb->data+(iph->ihl<<2));
@@ -338,7 +338,7 @@
 	xfrm_state_put(x);
 }
 
-void esp_destroy(struct xfrm_state *x)
+static void esp_destroy(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
 
@@ -364,7 +364,7 @@
 	kfree(esp);
 }
 
-int esp_init_state(struct xfrm_state *x, void *args)
+static int esp_init_state(struct xfrm_state *x, void *args)
 {
 	struct esp_data *esp = NULL;
 
diff -Nru a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
--- a/net/ipv4/xfrm4_policy.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv4/xfrm4_policy.c	2004-08-21 14:38:16 +02:00
@@ -12,8 +12,8 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 
-extern struct dst_ops xfrm4_dst_ops;
-extern struct xfrm_policy_afinfo xfrm4_policy_afinfo;
+static struct dst_ops xfrm4_dst_ops;
+static struct xfrm_policy_afinfo xfrm4_policy_afinfo;
 
 static struct xfrm_type_map xfrm4_type_map = { .lock = RW_LOCK_UNLOCKED };
 
@@ -243,7 +243,7 @@
 	path->ops->update_pmtu(path, mtu);
 }
 
-struct dst_ops xfrm4_dst_ops = {
+static struct dst_ops xfrm4_dst_ops = {
 	.family =		AF_INET,
 	.protocol =		__constant_htons(ETH_P_IP),
 	.gc =			xfrm4_garbage_collect,
@@ -252,7 +252,7 @@
 	.entry_size =		sizeof(struct xfrm_dst),
 };
 
-struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
+static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 	.family = 		AF_INET,
 	.lock = 		RW_LOCK_UNLOCKED,
 	.type_map = 		&xfrm4_type_map,
@@ -263,12 +263,12 @@
 	.decode_session =	_decode_session4,
 };
 
-void __init xfrm4_policy_init(void)
+static void __init xfrm4_policy_init(void)
 {
 	xfrm_policy_register_afinfo(&xfrm4_policy_afinfo);
 }
 
-void __exit xfrm4_policy_fini(void)
+static void __exit xfrm4_policy_fini(void)
 {
 	xfrm_policy_unregister_afinfo(&xfrm4_policy_afinfo);
 }
diff -Nru a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv6/ah6.c	2004-08-21 14:38:16 +02:00
@@ -154,7 +154,7 @@
 	return 0;
 }
 
-int ah6_output(struct sk_buff *skb)
+static int ah6_output(struct sk_buff *skb)
 {
 	int err;
 	int extlen;
@@ -229,7 +229,7 @@
 	return err;
 }
 
-int ah6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
+static int ah6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
 	/*
 	 * Before process AH
@@ -319,8 +319,8 @@
 	return -EINVAL;
 }
 
-void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt, 
-	 int type, int code, int offset, __u32 info)
+static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt, 
+                    int type, int code, int offset, __u32 info)
 {
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
 	struct ip_auth_hdr *ah = (struct ip_auth_hdr*)(skb->data+offset);
@@ -448,7 +448,7 @@
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
-int __init ah6_init(void)
+static int __init ah6_init(void)
 {
 	if (xfrm_register_type(&ah6_type, AF_INET6) < 0) {
 		printk(KERN_INFO "ipv6 ah init: can't add xfrm type\n");
diff -Nru a/net/ipv6/esp6.c b/net/ipv6/esp6.c
--- a/net/ipv6/esp6.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv6/esp6.c	2004-08-21 14:38:16 +02:00
@@ -37,7 +37,7 @@
 #include <net/ipv6.h>
 #include <linux/icmpv6.h>
 
-int esp6_output(struct sk_buff *skb)
+static int esp6_output(struct sk_buff *skb)
 {
 	int err;
 	int hdr_len;
@@ -129,7 +129,7 @@
 	return err;
 }
 
-int esp6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
+static int esp6_input(struct xfrm_state *x, struct xfrm_decap_state *decap, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph;
 	struct ipv6_esp_hdr *esph;
@@ -252,8 +252,8 @@
 	return mtu + x->props.header_len + esp->auth.icv_full_len;
 }
 
-void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-		int type, int code, int offset, __u32 info)
+static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+                     int type, int code, int offset, __u32 info)
 {
 	struct ipv6hdr *iph = (struct ipv6hdr*)skb->data;
 	struct ipv6_esp_hdr *esph = (struct ipv6_esp_hdr*)(skb->data+offset);
@@ -272,7 +272,7 @@
 	xfrm_state_put(x);
 }
 
-void esp6_destroy(struct xfrm_state *x)
+static void esp6_destroy(struct xfrm_state *x)
 {
 	struct esp_data *esp = x->data;
 
@@ -298,7 +298,7 @@
 	kfree(esp);
 }
 
-int esp6_init_state(struct xfrm_state *x, void *args)
+static int esp6_init_state(struct xfrm_state *x, void *args)
 {
 	struct esp_data *esp = NULL;
 
@@ -402,7 +402,7 @@
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
-int __init esp6_init(void)
+static int __init esp6_init(void)
 {
 	if (xfrm_register_type(&esp6_type, AF_INET6) < 0) {
 		printk(KERN_INFO "ipv6 esp init: can't add xfrm type\n");
diff -Nru a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
--- a/net/ipv6/xfrm6_policy.c	2004-08-21 14:38:16 +02:00
+++ b/net/ipv6/xfrm6_policy.c	2004-08-21 14:38:16 +02:00
@@ -17,12 +17,12 @@
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 
-extern struct dst_ops xfrm6_dst_ops;
-extern struct xfrm_policy_afinfo xfrm6_policy_afinfo;
+static struct dst_ops xfrm6_dst_ops;
+static struct xfrm_policy_afinfo xfrm6_policy_afinfo;
 
 static struct xfrm_type_map xfrm6_type_map = { .lock = RW_LOCK_UNLOCKED };
 
-int xfrm6_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
+static int xfrm6_dst_lookup(struct xfrm_dst **dst, struct flowi *fl)
 {
 	int err = 0;
 	*dst = (struct xfrm_dst*)ip6_route_output(NULL, fl);
@@ -253,7 +253,7 @@
 	return;
 }
 
-struct dst_ops xfrm6_dst_ops = {
+static struct dst_ops xfrm6_dst_ops = {
 	.family =		AF_INET6,
 	.protocol =		__constant_htons(ETH_P_IPV6),
 	.gc =			xfrm6_garbage_collect,
@@ -262,7 +262,7 @@
 	.entry_size =		sizeof(struct xfrm_dst),
 };
 
-struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
+static struct xfrm_policy_afinfo xfrm6_policy_afinfo = {
 	.family =		AF_INET6,
 	.lock = 		RW_LOCK_UNLOCKED,
 	.type_map = 		&xfrm6_type_map,
@@ -273,12 +273,12 @@
 	.decode_session =	_decode_session6,
 };
 
-void __init xfrm6_policy_init(void)
+static void __init xfrm6_policy_init(void)
 {
 	xfrm_policy_register_afinfo(&xfrm6_policy_afinfo);
 }
 
-void __exit xfrm6_policy_fini(void)
+static void __exit xfrm6_policy_fini(void)
 {
 	xfrm_policy_unregister_afinfo(&xfrm6_policy_afinfo);
 }

--------------090909020708040803030009--
