From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 05:38:55 +0300
Message-ID: <20081213023855.GA807@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au> <20081212194618.GA27281@ioremap.net> <20081212214125.GA11046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:33724 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbYLMCi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 21:38:58 -0500
Content-Disposition: inline
In-Reply-To: <20081212214125.GA11046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 08:41:25AM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > +			nskb->truesize += skb_end_pointer(nskb) - nskb->head -
> > > +					  hsize;
> > > +			skb_release_head_state(nskb);
> > > +			__skb_push(nskb, doffset);
> > > +		} else {
> > > +			nskb = alloc_skb(hsize + doffset + headroom,
> > > +					 GFP_ATOMIC);
> > > +
> > > +			if (unlikely(!nskb))
> > > +				goto err;
> > > +
> > 
> > The same.
> 
> nskb is NULL here.

Yup, I meant below 'goto err' when we failed to clone skb.

> > > +		if (pos < offset + len) {
> > > +			struct sk_buff *fskb2 = fskb;
> > > +
> > > +			BUG_ON(pos + fskb->len != offset + len);
> > > +
> > > +			pos += fskb->len;
> > > +			fskb = fskb->next;
> > > +
> > > +			if (fskb2->next) {
> > > +				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
> > > +				if (!fskb2)
> > > +					goto err;
> > > +			} else
> > > +				skb_get(fskb2);
> > > +
> > > +			skb_shinfo(nskb)->frag_list = fskb2;

-- 
	Evgeniy Polyakov
