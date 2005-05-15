From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/1] xfrm: skb_cow_data() does not set proper owner for new skbs.
Date: Sun, 15 May 2005 18:01:09 +1000
Message-ID: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
References: <20050514134834.GA2698@uganda.factory.vocord.ru>
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20050514134834.GA2698@uganda.factory.vocord.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>
> As far as I can see, current code sets destructor and socket
> for the first one skb only and uses truesize of the first skb
> only to increment sk_wmem_alloc value.
> 
> If above "analysis" is correct then attached patch fixes that.

Yes you're absolutely right.

> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

In fact you've uncovered a couple of bugs elsewhere too.  IPv4's
ip_push_pending_frames attributes all the data to the first skb
which breaks when the packet is sent through ip_fragment since
the latter does not undo the truesize attribution.  skb_linearize
is broken as well since it ignores truesize/owner altogether.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
