From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Fix IP ID selection
Date: Thu, 27 Apr 2006 21:56:45 +1000
Message-ID: <20060427115645.GA20140@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7JfCtLOvnd9MIVvH"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:28932 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964898AbWD0L4s
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 07:56:48 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I was looking through the xfrm input/output code in order to abstract
out the address family specific encapsulation/decapsulation code.  During
that process I found this bug in the IP ID selection code in xfrm4_output.c.

At that point dst is still the xfrm_dst for the current SA which
represents an internal flow as far as the IPsec tunnel is concerned.
Since the IP ID is going to sit on the outside of the encapsulated
packet, we obviously want the external flow which is just dst->child.

The fix is trivial.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="xfrm4-output-fid.patch"

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 32ad229..4ef8efa 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -62,7 +62,7 @@
 	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
 		0 : (iph->frag_off & htons(IP_DF));
 	if (!top_iph->frag_off)
-		__ip_select_ident(top_iph, dst, 0);
+		__ip_select_ident(top_iph, dst->child, 0);
 
 	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
 

--7JfCtLOvnd9MIVvH--
