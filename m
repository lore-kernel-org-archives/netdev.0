From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan Users] 	DPD Problem - message from kernel malformed:
	unknown address family
Date: Thu, 21 Oct 2004 08:02:44 +1000
Sender: users-bounces@openswan.org
Message-ID: <E1CKOXc-0002Kq-00@gondolin.me.apana.org.au>
References: <417675C6.3040704@gmx.ch>
Cc: netdev@oss.sgi.com
Return-path: <users-bounces@openswan.org>
To: mailing-lists@gmx.ch (Eric Marchionni)
In-Reply-To: <417675C6.3040704@gmx.ch>
Cc: users@openswan.org
Cc: davem@davemloft.net
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/users>
List-Post: <mailto:users@openswan.org>
List-Help: <mailto:users-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/users>,
	<mailto:users-request@openswan.org?subject=subscribe>
Errors-To: users-bounces@openswan.org
List-Id: netdev.vger.kernel.org

Eric Marchionni <mailing-lists@gmx.ch> wrote:
> 
> the ping times out and this occurs in the log:
> Oct 20 10:36:11 localhost pluto[12528]: XFRM_MSG_ACQUIRE message from 
> kernel malformed: unknown address family

Looks like nobody has tested shunt routes for a while.

It's a kernel bug.  We're not setting the family field in the selector.
This patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv4/xfrm4_state.c 1.10 vs edited =====
--- 1.10/net/ipv4/xfrm4_state.c	2004-08-01 16:28:12 +10:00
+++ edited/net/ipv4/xfrm4_state.c	2004-10-21 07:58:54 +10:00
@@ -18,6 +18,7 @@
 		     struct xfrm_tmpl *tmpl,
 		     xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
+	x->sel.family = AF_INET;
 	x->sel.daddr.a4 = fl->fl4_dst;
 	x->sel.saddr.a4 = fl->fl4_src;
 	x->sel.dport = fl->fl_ip_dport;
@@ -85,11 +86,11 @@
 		x0->sel.saddr.a4 = saddr->a4;
 		x0->sel.prefixlen_d = 32;
 		x0->sel.prefixlen_s = 32;
+		x0->sel.family = AF_INET;
 		x0->props.saddr.a4 = saddr->a4;
 		x0->km.state = XFRM_STATE_ACQ;
 		x0->id.daddr.a4 = daddr->a4;
 		x0->id.proto = proto;
-		x0->props.family = AF_INET;
 		x0->props.mode = mode;
 		x0->props.reqid = reqid;
 		x0->props.family = AF_INET;
===== net/ipv6/xfrm6_state.c 1.12 vs edited =====
--- 1.12/net/ipv6/xfrm6_state.c	2004-08-01 16:28:12 +10:00
+++ edited/net/ipv6/xfrm6_state.c	2004-10-21 07:59:23 +10:00
@@ -25,6 +25,7 @@
 {
 	/* Initialize temporary selector matching only
 	 * to current session. */
+	x->sel.family = AF_INET6;
 	ipv6_addr_copy((struct in6_addr *)&x->sel.daddr, &fl->fl6_dst);
 	ipv6_addr_copy((struct in6_addr *)&x->sel.saddr, &fl->fl6_src);
 	x->sel.dport = fl->fl_ip_dport;
@@ -88,6 +89,7 @@
 		    }
 	}
 	if (!x0 && create && (x0 = xfrm_state_alloc()) != NULL) {
+		x0->sel.family = AF_INET6;
 		ipv6_addr_copy((struct in6_addr *)x0->sel.daddr.a6,
 			       (struct in6_addr *)daddr);
 		ipv6_addr_copy((struct in6_addr *)x0->sel.saddr.a6,
