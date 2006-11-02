From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 3/6] IPv6: Allow link-local tunnel endpoints
Date: Thu, 02 Nov 2006 13:33:48 +0200
Message-ID: <4549D79C.1040309@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030401070907020406010305"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:52617 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1752833AbWKBLd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:33:57 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030401070907020406010305
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------030401070907020406010305
Content-Type: text/plain;
 name="0003-IPv6-Allow-link-local-tunnel-endpoints.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0003-IPv6-Allow-link-local-tunnel-endpoints.txt"

>From de1ad3df949303a1454ae0cdee0a599c0fc95e45 Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 12:45:08 +0200
Subject: [PATCH 3/6] IPv6: Allow link-local tunnel endpoints

Allow link-local tunnel endpoints if the underlying link is defined.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2467b04..008bd11 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -460,6 +460,7 @@ ip6ip6_err(struct sk_buff *skb, struct i
 	if (rel_msg &&  pskb_may_pull(skb, offset + sizeof (*ipv6h))) {
 		struct rt6_info *rt;
 		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 		if (!skb2)
 			goto out;
 
@@ -823,7 +824,7 @@ static void ip6_tnl_set_cap(struct ip6_t
 	if (ltype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
 	    rtype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
 	    !((ltype|rtype) & IPV6_ADDR_LOOPBACK) &&
-	    !((ltype|rtype) & IPV6_ADDR_LINKLOCAL)) {
+	    (!((ltype|rtype) & IPV6_ADDR_LINKLOCAL) || p->link)) {
 		if (ltype&IPV6_ADDR_UNICAST)
 			p->flags |= IP6_TNL_F_CAP_XMIT;
 		if (rtype&IPV6_ADDR_UNICAST)
@@ -861,8 +862,11 @@ static void ip6ip6_tnl_link_config(struc
 	dev->iflink = p->link;
 
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
+		int strict = (ipv6_addr_type(&p->raddr) &
+			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
+
 		struct rt6_info *rt = rt6_lookup(&p->raddr, &p->laddr,
-						 p->link, 0);
+						 p->link, strict);
 
 		if (rt == NULL)
 			return;
-- 
1.4.3.2


--------------030401070907020406010305--
