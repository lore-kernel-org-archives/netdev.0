From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: dst underflow (again)
Date: Sat, 06 Nov 2004 12:53:04 +1100
Message-ID: <E1CQFlI-0003va-00@gondolin.me.apana.org.au>
References: <20041105162319.6e2917c5.davem@davemloft.net>
Cc: buytenh@wantstofly.org, acme@conectiva.com.br, hadi@cyberus.ca,
        yoshfuji@linux-ipv6.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20041105162319.6e2917c5.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> Well, xfrm_lookup() is returning an error somehow, that's the only
> way to execute dst_release() in udpv6_sendmsg().  And xfrm_lookup()

Actually, there are other calls to dst_release in udpv6_sendmsg.  For
example, the inline function ip6_dst_store may call dst_release.

I'm afraid that we really have to audit all dst_release callers,
both direct and indirect, as well as all places where dst is stored.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
