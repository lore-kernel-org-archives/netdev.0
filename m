From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipcomp regression in 2.6.24
Date: Thu, 31 Jan 2008 16:32:21 +1100
Message-ID: <20080131053221.GA4739@gondor.apana.org.au>
References: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au> <BAY103-DAV204C57458B3E41DE1AA365B2360@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Daniel.Beschorner@facton.com,
	netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32927 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751186AbYAaFc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 00:32:29 -0500
Content-Disposition: inline
In-Reply-To: <BAY103-DAV204C57458B3E41DE1AA365B2360@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2008 at 10:14:46AM +0100, Marco Berizzi wrote:
>
> Sorry for bother you again.
> I have applied to 2.6.24, but ipcomp doesn't work anyway.
> I have patched a clean 2.6.24 tree and I did a complete
> rebuild.
> With tcpdump I see both the esp packets going in/out but
> I don't see the clear packets on the interface.

After testing it here it looks like there is this little typo
which means that you can't actually use IPComp for anything
that's not compressible :)

[IPCOMP]: Fix reception of incompressible packets

I made a silly typo by entering IPPROTO_IP (== 0) instead of
IPPROTO_IPIP (== 4).  This broke the reception of incompressible
packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index 3268451..152f83d 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -50,7 +50,7 @@ static struct xfrm_type ipip_type = {
 
 static int xfrm_tunnel_rcv(struct sk_buff *skb)
 {
-	return xfrm4_rcv_spi(skb, IPPROTO_IP, ip_hdr(skb)->saddr);
+	return xfrm4_rcv_spi(skb, IPPROTO_IPIP, ip_hdr(skb)->saddr);
 }
 
 static int xfrm_tunnel_err(struct sk_buff *skb, u32 info)
