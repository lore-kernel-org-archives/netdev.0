From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6]: Check against correct policy list in ip_forward/ip6_forward
Date: Mon, 18 Oct 2004 09:12:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017231258.GA29294@gondor.apana.org.au>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4172F1AB.4020305@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 18, 2004 at 12:26:51AM +0200, Patrick McHardy wrote:
>
> I only looked for pfkey symbolic names. So it seems only racoon
> needs to be fixed.

Agreed.

> I think we should apply the attached patch
> to make xfrm_policy_check reject packets decapsulated by IPsec
> without a policy for this direction, so people will notice
> something is wrong. It also prevents skipping checks against the

Well it's too late to change the default policy.  People rely on the
default policy being allow so changing it will wreak havoc.  Even if
you do it only for packets with an IPsec encapsulation by checking
skb->sp it may still break people who use manual keying and rely on
the property that you can always add optional SAs.  More importantly
that it'll stick out like a sore thumb in terms of its semantics.

So let's just fix racoon.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
