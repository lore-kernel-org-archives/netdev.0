From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/2] NET: Clone the sk_buff 'iif' field in __skb_clone()
Date: Thu, 3 Jan 2008 13:40:35 -0500
Message-ID: <200801031340.35320.paul.moore@hp.com>
References: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net> <20080103172545.14445.95317.stgit@flek.americas.hpqcorp.net> <1199385186.10508.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:48959 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbYACSkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 13:40:40 -0500
In-Reply-To: <1199385186.10508.11.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 1:33:05 pm Joe Perches wrote:
> On Thu, 2008-01-03 at 12:25 -0500, Paul Moore wrote:
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 5b4ce9b..c726cd4 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -407,31 +407,29 @@ static void __copy_skb_header(struct sk_buff
> > *new, const struct sk_buff *old)
> >
> >  static struct sk_buff *__skb_clone(struct sk_buff *n, struct
> > sk_buff *skb) {
> > -#define C(x) n->x = skb->x
> > -
> >  	n->next = n->prev = NULL;
> >  	n->sk = NULL;
> >  	__copy_skb_header(n, skb);
> >
> > -	C(len);
> > -	C(data_len);
> > -	C(mac_len);
> > +	n->iif = skb->iif;
> > +	n->len = skb->len;
> > +	n->data_len = skb->data_len;
> > +	n->mac_len = skb->mac_len;
> >  	n->cloned = 1;
> >  	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
> >  	n->nohdr = 0;
>
> To reduce possible cacheline bounces, shouldn't the order of
> operation on the elements be in struct order?

Sounds reasonable to me, I'll adjust the function to match the field 
offsets.

-- 
paul moore
linux security @ hp
