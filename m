From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Set TTL from route
Date: Tue, 24 Aug 2004 20:56:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824105641.GA10202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is the promised patch that sets the TTL from the route parameter.
I decided against adding an option to inherit the TTL like IPIP/GRE
as I think that it doesn't really make sense with IPsec.  But it
can be easily added later if someone needs it.

This isn't completely right when nested tunnels are involved.  The
TTL for intervening tunnels should be set from the routes to the
intervening nodes.  But fixing that involves using information that
isn't currently in the bundle.  I'll revisit this once the MTU stuff
is fixed since that'll also involving adding the intervening routes
to the bundle.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/xfrm4_output.c 1.4 vs edited =====
--- 1.4/net/ipv4/xfrm4_output.c	2004-08-20 20:39:43 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2004-08-24 20:03:26 +10:00
@@ -58,8 +58,7 @@
 	if (!top_iph->frag_off)
 		__ip_select_ident(top_iph, dst, 0);
 
-	/* TTL disclosed */
-	top_iph->ttl = iph->ttl;
+	top_iph->ttl = dst_path_metric(dst, RTAX_HOPLIMIT);
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
===== net/ipv6/xfrm6_output.c 1.4 vs edited =====
--- 1.4/net/ipv6/xfrm6_output.c	2004-08-20 20:39:43 +10:00
+++ edited/net/ipv6/xfrm6_output.c	2004-08-24 20:52:19 +10:00
@@ -64,7 +64,7 @@
 	top_iph->flow_lbl[1] = iph->flow_lbl[1];
 	top_iph->flow_lbl[2] = iph->flow_lbl[2];
 	top_iph->nexthdr = IPPROTO_IPV6; 
-	top_iph->hop_limit = iph->hop_limit;
+	top_iph->hop_limit = dst_path_metric(dst, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 }

--Dxnq1zWXvFF0Q93v--
