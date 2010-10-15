From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] xfrm6: make xfrm6_tunnel_free_spi local
Date: Fri, 15 Oct 2010 08:15:59 -0700
Message-ID: <20101015081559.6ede35a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43132 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754210Ab0JOPQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:16:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function only defined and used in one file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/xfrm.h	2010-10-05 23:33:55.959118983 +0900
+++ b/include/net/xfrm.h	2010-10-05 23:34:05.079117188 +0900
@@ -1419,7 +1419,6 @@ extern int xfrm6_input_addr(struct sk_bu
 extern int xfrm6_tunnel_register(struct xfrm6_tunnel *handler, unsigned short family);
 extern int xfrm6_tunnel_deregister(struct xfrm6_tunnel *handler, unsigned short family);
 extern __be32 xfrm6_tunnel_alloc_spi(struct net *net, xfrm_address_t *saddr);
-extern void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr);
 extern __be32 xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr);
 extern int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
--- a/net/ipv6/xfrm6_tunnel.c	2010-10-05 23:33:56.039118393 +0900
+++ b/net/ipv6/xfrm6_tunnel.c	2010-10-05 23:34:21.011117560 +0900
@@ -199,7 +199,7 @@ static void x6spi_destroy_rcu(struct rcu
 			container_of(head, struct xfrm6_tunnel_spi, rcu_head));
 }
 
-void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr)
+static void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
 	struct xfrm6_tunnel_spi *x6spi;
@@ -223,8 +223,6 @@ void xfrm6_tunnel_free_spi(struct net *n
 	spin_unlock_bh(&xfrm6_tunnel_spi_lock);
 }
 
-EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
-
 static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	skb_push(skb, -skb_network_offset(skb));
