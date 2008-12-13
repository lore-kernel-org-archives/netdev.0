From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 13:43:05 +1100
Message-ID: <20081213024305.GA14056@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au> <20081212194618.GA27281@ioremap.net> <20081212214125.GA11046@gondor.apana.org.au> <20081213023855.GA807@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47207 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752269AbYLMCnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 21:43:11 -0500
Content-Disposition: inline
In-Reply-To: <20081213023855.GA807@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 05:38:55AM +0300, Evgeniy Polyakov wrote:
>
> Yup, I meant below 'goto err' when we failed to clone skb.
> 
> > > > +		if (pos < offset + len) {
> > > > +			struct sk_buff *fskb2 = fskb;
> > > > +
> > > > +			BUG_ON(pos + fskb->len != offset + len);
> > > > +
> > > > +			pos += fskb->len;
> > > > +			fskb = fskb->next;
> > > > +
> > > > +			if (fskb2->next) {
> > > > +				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
> > > > +				if (!fskb2)
> > > > +					goto err;
> > > > +			} else
> > > > +				skb_get(fskb2);
> > > > +
> > > > +			skb_shinfo(nskb)->frag_list = fskb2;

This isn't a problem.  fskb2 is still on the original frag_list so
we don't need to free it if skb_clone fails.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
