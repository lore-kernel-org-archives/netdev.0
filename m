From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Thu, 28 Jul 2005 21:36:25 +1000
Message-ID: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au>
References: <1122295307.14873.37.camel@odysse>
Cc: netdev@oss.sgi.com, infrahip@HIIT.FI, gurtov@cs.helsinki.fi,
        jeffrey.m.ahrenholz@boeing.com, kristian.slavov@nomadiclab.com,
        hipl-users@freelists.org, hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: diego.beltrami@HIIT.FI
In-Reply-To: <1122295307.14873.37.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Diego Beltrami <diego.beltrami@hiit.fi> wrote:
> 
> we have been working for three months to implement a new IPsec mode,
> the "BEET" mode, for Linux. Below is a link to the BEET specification
> and
> the abstract:
> 
> http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt

Thanks for the patch guys, this is really interesting.

> extern int xfrm4_rcv_encap(struct sk_buff *skb, __u16 encap_type);
> diff -urN linux-2.6.12.2/net/ipv4/esp4.c
> linux-beet-2.6.12.2/net/ipv4/esp4.c
> --- linux-2.6.12.2/net/ipv4/esp4.c      2005-06-30 02:00:53.000000000 +0300
> +++ linux-beet-2.6.12.2/net/ipv4/esp4.c 2005-07-25 14:39:11.000000000

Although the document only talks about ESP, as far as I can see
the encapsulation can be applied to AH/IPComp just as well.
So how about moving this stuff to the generic xfrm_input/xfrm_output
functions?

Also, if you're going to do cross-family transforms, it should be
done for both BEET and plain tunnel-mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
