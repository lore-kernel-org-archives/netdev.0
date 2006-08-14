From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Mon, 14 Aug 2006 15:32:56 +0400
Message-ID: <20060814113256.GB27132@2ka.mipt.ru>
References: <20060814110359.GA27704@2ka.mipt.ru> <20060814.042206.85411651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:24793 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1752001AbWHNLdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 07:33:21 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060814.042206.85411651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 04:22:06AM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Mon, 14 Aug 2006 15:04:03 +0400
> 
> >  	/* These elements must be at the end, see alloc_skb() for details.  */
> > -	unsigned int		truesize;
> > +	unsigned int		truesize, __tsize;
> 
> There is no real need for new member.
> 
> > -		kfree(skb->head);
> > +		avl_free(skb->head, skb->__tsize);
> 
> Just use "skb->end - skb->head + sizeof(struct skb_shared_info)"
> as the size argument.
> 
> Then, there is no reason for skb->__tsize :-)

Oh, my fault - that simple calculation dropped out of my head...

-- 
	Evgeniy Polyakov
