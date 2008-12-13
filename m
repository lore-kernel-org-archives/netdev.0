From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 06:11:10 +0300
Message-ID: <20081213031110.GF807@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au> <20081212194618.GA27281@ioremap.net> <20081212214125.GA11046@gondor.apana.org.au> <20081213023855.GA807@ioremap.net> <20081213024305.GA14056@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:54721 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbYLMDLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 22:11:12 -0500
Content-Disposition: inline
In-Reply-To: <20081213024305.GA14056@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 01:43:05PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > > > +		if (pos < offset + len) {
> > > > > +			struct sk_buff *fskb2 = fskb;
> > > > > +
> > > > > +			BUG_ON(pos + fskb->len != offset + len);
> > > > > +
> > > > > +			pos += fskb->len;
> > > > > +			fskb = fskb->next;
> > > > > +
> > > > > +			if (fskb2->next) {
> > > > > +				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
> > > > > +				if (!fskb2)
> > > > > +					goto err;
> > > > > +			} else
> > > > > +				skb_get(fskb2);
> > > > > +
> > > > > +			skb_shinfo(nskb)->frag_list = fskb2;
> 
> This isn't a problem.  fskb2 is still on the original frag_list so
> we don't need to free it if skb_clone fails.

But nskb was not added into the list or it was?

-- 
	Evgeniy Polyakov
