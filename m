From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9-rc1-mm5: TCP oopses
Date: Tue, 14 Sep 2004 13:34:20 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1C745E-00024r-00@gondolin.me.apana.org.au>
References: <20040913190858.12544431.davem@davemloft.net>
Cc: jmorris@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268670AbUINDen@vger.kernel.org>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040913190858.12544431.davem@davemloft.net>
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
>
> @@ -968,11 +972,17 @@
>                return -EAGAIN;
> 
>        if (skb->len > cur_mss) {
> +               int old_factor = TCP_SKB_CB(skb)->tso_factor;
> +               int new_factor;
> +
>                if (tcp_fragment(sk, skb, cur_mss))
>                        return -ENOMEM; /* We'll try again later. */
> 
>                /* New SKB created, account for it. */
> -               tcp_inc_pcount(&tp->packets_out, skb);
> +               new_factor = TCP_SKB_CB(skb)->tso_factor;
> +               tcp_dec_pcount_explicit(&tp->packets_out,
> +                                       new_factor - old_factor);

That should be tcp_inc_pcount_explicit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
