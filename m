From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4381] New: When i try to start a pppoe conn., crash at net/core/skbuff.c:91
Date: Wed, 23 Mar 2005 13:49:01 +1100
Message-ID: <E1DDvvZ-000350-00@gondolin.me.apana.org.au>
References: <4240D266.4080403@trash.net>
Cc: akpm@osdl.org, netdev@oss.sgi.com, o.cornu@gmail.com, paulus@samba.org
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <4240D266.4080403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> ===== drivers/net/ppp_async.c 1.26 vs edited =====
> --- 1.26/drivers/net/ppp_async.c        2005-01-21 06:02:12 +01:00
> +++ edited/drivers/net/ppp_async.c      2005-03-23 03:15:31 +01:00
> @@ -183,6 +183,7 @@
>        ap->chan.private = ap;
>        ap->chan.ops = &async_ops;
>        ap->chan.mtu = PPP_MRU;
> +       ap->chan.hdrlen = 2;
>        err = ppp_register_channel(&ap->chan);

I'm not sure whether this could cause the original crash that we saw.
If ap->chan.hdrlen is not set then it should be zero.  It being zero
should not cause skb_over_panic to trigger in ppp_write, should it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
