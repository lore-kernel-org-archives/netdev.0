From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Rename tunnel-mode functions to avoid collisions with tunnels
Date: Wed, 19 Dec 2007 14:38:33 +0800
Message-ID: <20071219063833.GA7041@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4424 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751263AbXLSGih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 01:38:37 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[IPSEC]: Rename tunnel-mode functions to avoid collisions with tunnels

It appears that I've managed to create two different functions both
called xfrm6_tunnel_output.  This is because we have the plain tunnel
encapsulation named xfrmX_tunnel as well as the tunnel-mode encapsulation
which lives in the files xfrmX_mode_tunnel.c.

This patch renames functions from the latter to use the xfrmX_mode_tunnel
prefix to avoid name-space conflicts.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index aa335db..8dee617 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -26,7 +26,7 @@ static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
  *
  * The top IP header will be constructed per RFC 2401.
  */
-static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm4_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct iphdr *top_iph;
@@ -63,7 +63,7 @@ static int xfrm4_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	const unsigned char *old_mac;
 	int err = -EINVAL;
@@ -94,21 +94,21 @@ out:
 }
 
 static struct xfrm_mode xfrm4_tunnel_mode = {
-	.input2 = xfrm4_tunnel_input,
+	.input2 = xfrm4_mode_tunnel_input,
 	.input = xfrm_prepare_input,
-	.output2 = xfrm4_tunnel_output,
+	.output2 = xfrm4_mode_tunnel_output,
 	.output = xfrm4_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
-static int __init xfrm4_tunnel_init(void)
+static int __init xfrm4_mode_tunnel_init(void)
 {
 	return xfrm_register_mode(&xfrm4_tunnel_mode, AF_INET);
 }
 
-static void __exit xfrm4_tunnel_exit(void)
+static void __exit xfrm4_mode_tunnel_exit(void)
 {
 	int err;
 
@@ -116,7 +116,7 @@ static void __exit xfrm4_tunnel_exit(void)
 	BUG_ON(err);
 }
 
-module_init(xfrm4_tunnel_init);
-module_exit(xfrm4_tunnel_exit);
+module_init(xfrm4_mode_tunnel_init);
+module_exit(xfrm4_mode_tunnel_exit);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_XFRM_MODE(AF_INET, XFRM_MODE_TUNNEL);
diff --git a/net/ipv6/xfrm6_mode_tunnel.c b/net/ipv6/xfrm6_mode_tunnel.c
index f7d0d66..0c742fa 100644
--- a/net/ipv6/xfrm6_mode_tunnel.c
+++ b/net/ipv6/xfrm6_mode_tunnel.c
@@ -29,7 +29,7 @@ static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
  *
  * The top IP header will be constructed per RFC 2401.
  */
-static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm6_mode_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *top_iph;
@@ -58,7 +58,7 @@ static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 	return 0;
 }
 
-static int xfrm6_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
+static int xfrm6_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err = -EINVAL;
 	const unsigned char *old_mac;
@@ -89,21 +89,21 @@ out:
 }
 
 static struct xfrm_mode xfrm6_tunnel_mode = {
-	.input2 = xfrm6_tunnel_input,
+	.input2 = xfrm6_mode_tunnel_input,
 	.input = xfrm_prepare_input,
-	.output2 = xfrm6_tunnel_output,
+	.output2 = xfrm6_mode_tunnel_output,
 	.output = xfrm6_prepare_output,
 	.owner = THIS_MODULE,
 	.encap = XFRM_MODE_TUNNEL,
 	.flags = XFRM_MODE_FLAG_TUNNEL,
 };
 
-static int __init xfrm6_tunnel_init(void)
+static int __init xfrm6_mode_tunnel_init(void)
 {
 	return xfrm_register_mode(&xfrm6_tunnel_mode, AF_INET6);
 }
 
-static void __exit xfrm6_tunnel_exit(void)
+static void __exit xfrm6_mode_tunnel_exit(void)
 {
 	int err;
 
@@ -111,7 +111,7 @@ static void __exit xfrm6_tunnel_exit(void)
 	BUG_ON(err);
 }
 
-module_init(xfrm6_tunnel_init);
-module_exit(xfrm6_tunnel_exit);
+module_init(xfrm6_mode_tunnel_init);
+module_exit(xfrm6_mode_tunnel_exit);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_XFRM_MODE(AF_INET6, XFRM_MODE_TUNNEL);

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
