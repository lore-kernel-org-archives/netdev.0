From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Replace bogus instances of inet->recverr
Date: Thu, 14 Apr 2005 22:34:23 +1000
Message-ID: <20050414123423.GA16334@gondor.apana.org.au>
References: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com> <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Cc: davem@davemloft.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

While looking at this problem I noticed that IPv6 was sometimes
looking at inet->recverr which is bogus.  Here is a patch to
correct that and use np->recverr.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=raw6-2

===== net/ipv6/ip6_output.c 1.91 vs edited =====
--- 1.91/net/ipv6/ip6_output.c	2005-03-19 05:44:52 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-04-14 22:30:22 +10:00
@@ -1149,7 +1149,7 @@
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
-			err = inet->recverr ? net_xmit_errno(err) : 0;
+			err = np->recverr ? net_xmit_errno(err) : 0;
 		if (err)
 			goto error;
 	}
--- linux-2.6/net/ipv6/raw.c.orig	2005-04-14 22:27:07.000000000 +1000
+++ linux-2.6/net/ipv6/raw.c	2005-04-14 22:29:58.000000000 +1000
@@ -533,7 +533,7 @@
 			struct flowi *fl, struct rt6_info *rt, 
 			unsigned int flags)
 {
-	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	unsigned int hh_len;
@@ -570,7 +570,7 @@
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
-		err = inet->recverr ? net_xmit_errno(err) : 0;
+		err = np->recverr ? net_xmit_errno(err) : 0;
 	if (err)
 		goto error;
 out:
@@ -807,8 +807,6 @@
 	ip6_dst_store(sk, dst,
 		      ipv6_addr_equal(&fl.fl6_dst, &np->daddr) ?
 		      &np->daddr : NULL);
-	if (err > 0)
-		err = np->recverr ? net_xmit_errno(err) : 0;
 
 	release_sock(sk);
 out:	

--GvXjxJ+pjyke8COw--
