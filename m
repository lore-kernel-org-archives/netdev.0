From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 22:19:03 -0500
Message-ID: <200801032219.04223.paul.moore@hp.com>
References: <200801031115.34886.paul.moore@hp.com> <200801031813.57621.paul.moore@hp.com> <1199403607.4888.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:4636 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbYADDTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 22:19:11 -0500
In-Reply-To: <1199403607.4888.6.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 6:40:07 pm Joe Perches wrote:
> On Thu, 2008-01-03 at 18:13 -0500, Paul Moore wrote:
> > static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff
> > *skb)
> > {
> > #define C(x) n->x = skb->x
> >
> > 	n->next = n->prev = NULL;
> > 	n->sk = NULL;
> > 	__copy_skb_header(n, skb);
> >
> > 	C(len);
> > 	C(data_len);
> > 	C(mac_len);
> > 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
> > 	n->cloned = 1;
> > 	n->nohdr = 0;
> > 	n->destructor = NULL;
> > 	C(iif);
> > 	C(tail);
> > 	C(end);
> > 	C(head);
> > 	C(data);
> > 	C(truesize);
> > 	atomic_set(&n->users, 1);
> >
> > 	atomic_inc(&(skb_shinfo(skb)->dataref));
> > 	skb->cloned = 1;
> >
> > 	return n;
> > #undef C
>
> Perhaps move the skb->cloned = 1 to just after n->cloned = 1
> or
> 	skb->cloned = n->cloned = 1;
> or maybe
> 	skb->cloned = 1;
> 	C(cloned);

I thought about that, but I kinda like how the parent-skb-only changes are 
grouped together at the end.  I think the distinction helps readability, but 
then again we've already seen how subjective readability can be :)

-- 
paul moore
linux security @ hp
