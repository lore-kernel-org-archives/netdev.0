From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPCOMP6] Fix ICMP type check
Date: Thu, 22 Jul 2004 21:34:29 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722113429.GA15083@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

It looks like IPCOMP was missed when the same problem was fixed in AH/ESP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="1.1806"

diff -Nru a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
--- a/net/ipv6/ipcomp6.c	2004-07-16 20:46:17 +10:00
+++ b/net/ipv6/ipcomp6.c	2004-07-16 20:46:17 +10:00
@@ -240,7 +240,7 @@
 	struct ipv6_comp_hdr *ipcomph = (struct ipv6_comp_hdr*)(skb->data+offset);
 	struct xfrm_state *x;
 
-	if (type != ICMPV6_DEST_UNREACH || type != ICMPV6_PKT_TOOBIG)
+	if (type != ICMPV6_DEST_UNREACH && type != ICMPV6_PKT_TOOBIG)
 		return;
 
 	spi = ntohl(ntohs(ipcomph->cpi));

--lrZ03NoBR/3+SXJZ--
