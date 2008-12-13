From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 6/8] tcp: Add GRO support
Date: Sat, 13 Dec 2008 05:40:46 +0300
Message-ID: <20081213024046.GB807@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d1-0000rd-B2@gondolin.me.apana.org.au> <20081212195615.GC27281@ioremap.net> <20081212214627.GC11046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:33734 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754061AbYLMCkr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 21:40:47 -0500
Content-Disposition: inline
In-Reply-To: <20081212214627.GC11046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 08:46:27AM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > > +	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
> > > +
> > > +	total = p->len;
> > > +	mss = total;
> > > +	if (skb_shinfo(p)->frag_list)
> > > +		mss = skb_shinfo(p)->frag_list->len;
> > > +
> > > +	flush |= skb->len > mss || skb->len <= 0;
> > > +	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
> > > +
> > 
> > No timestamp check?
> 
> The memcmp does that for us.

So it will fail if timestamp changed? Or if some new option added?

-- 
	Evgeniy Polyakov
