From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 12:14:47 +0400
Message-ID: <20060807081447.GA22282@2ka.mipt.ru>
References: <20060807060155.GA6487@2ka.mipt.ru> <200608071005.57517.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37295 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751150AbWHGIPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 04:15:17 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200608071005.57517.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 10:05:57AM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > +	if ((1UL << order) > size + sizeof(void *) + sizeof(struct
> > skb_shared_info)) { +		data = ____kmalloc(size + sizeof(struct
> > skb_shared_info), gfp_mask); +		if (!data)
> > +			goto nodata;
> > +		memset(skb, 0, offsetof(struct sk_buff, truesize));
> > +	} else {
> > +		unsigned long *ptr;
> > +
> > +		data = ____kmalloc(size, gfp_mask);
> 
> You certainly want to kmalloc(size + sizeof(void *)) here, dont you ?

Yep.
I think in next iteration of this patch I will add additional argument
which will present order of aligned size (to eliminate get_order() loop
for those who know it in advance like e1000). In case there are no
place even for sizeof(void *) (what happens with e1000) and allocation 
order is quite high (more than half of the page), then additional field 
in skb can be used (or we can reuse it unconditionally to store pointer
to shared info if skb is being allocated through alloc_skb_aligned()
function).

> Eric

-- 
	Evgeniy Polyakov
