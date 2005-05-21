From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG 2.6.12-rc4] IPv6 xfrm tunnel oops with large packets
Date: Sun, 22 May 2005 05:49:32 +1000
Message-ID: <20050521194932.GA10959@gondor.apana.org.au>
References: <1116702611.14509.10.camel@leto.cs.pocnet.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-net-owner@vger.kernel.org>
To: Christophe Saout <christophe@saout.de>
Content-Disposition: inline
In-Reply-To: <1116702611.14509.10.camel@leto.cs.pocnet.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 21, 2005 at 07:10:11PM +0000, Christophe Saout wrote:
> 
> The oops occurs in line 391 in net/ipv6/icmp.c:
> 
> >        idev = in6_dev_get(skb->dev);

Here is a minimal fix.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I wonder why I've never seen it before.

BTW, icmpv6_send seems to ignore its dev argument altogether.
Any reason why we can't just use it instead of skb->dev?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -84,6 +84,7 @@ static int xfrm6_tunnel_check_size(struc
 		mtu = IPV6_MIN_MTU;
 
 	if (skb->len > mtu) {
+		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
 		ret = -EMSGSIZE;
 	}

--HlL+5n6rz5pIUxbD--
