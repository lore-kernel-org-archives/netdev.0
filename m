From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 03 Jan 2008 15:40:07 -0800
Message-ID: <1199403607.4888.6.camel@localhost>
References: <200801031115.34886.paul.moore@hp.com>
	 <200801031620.06603.paul.moore@hp.com>
	 <20080103.150518.05131300.davem@davemloft.net>
	 <200801031813.57621.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	hadi@cyberus.ca, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2952 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752895AbYACXkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 18:40:53 -0500
In-Reply-To: <200801031813.57621.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-01-03 at 18:13 -0500, Paul Moore wrote:
> static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff 
> *skb)
> {
> #define C(x) n->x = skb->x
> 
> 	n->next = n->prev = NULL;
> 	n->sk = NULL;
> 	__copy_skb_header(n, skb);
> 
> 	C(len);
> 	C(data_len);
> 	C(mac_len);
> 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
> 	n->cloned = 1;
> 	n->nohdr = 0;
> 	n->destructor = NULL;
> 	C(iif);
> 	C(tail);
> 	C(end);
> 	C(head);
> 	C(data);
> 	C(truesize);
> 	atomic_set(&n->users, 1);
> 
> 	atomic_inc(&(skb_shinfo(skb)->dataref));
> 	skb->cloned = 1;
> 
> 	return n;
> #undef C

Perhaps move the skb->cloned = 1 to just after n->cloned = 1
or
	skb->cloned = n->cloned = 1;
or maybe
	skb->cloned = 1;
	C(cloned);

