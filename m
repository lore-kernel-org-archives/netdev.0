From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: skb_shared_info()
Date: Wed, 9 Aug 2006 09:35:24 +0400
Message-ID: <20060809053524.GC17446@2ka.mipt.ru>
References: <20060808.163915.03600382.davem@davemloft.net> <20060809003616.GC19881@gondor.apana.org.au> <20060808.175839.85396148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:29421 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965067AbWHIFfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:35:51 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.175839.85396148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 05:58:39PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 9 Aug 2006 10:36:16 +1000
> 
> > I'm not sure whether the problem is where we store skb_shared_info,
> > or the fact that we can't put kmalloc'ed memory into
> > skb_shinfo->frags.
> 
> That's a good point.

It is second problem actually.
If we want to change memory usage in skbs, we have problems with
frag_list and place where shared info lives, since it's addon only for
1500 MTU does not change alignment.

> I guess we could do something like:
> 
> struct skb_frag_struct {
> 	union {
> 		struct page *page;
> 		void *data;
> 	} u;
> 	__u16 page_offset;
> 	__u16 size;
> };
> 
> and something clever like a special page_offset encoding
> means "use data, not page".

We can separate kmalloced data from page by using internal page structures
(lru pointers and PG_slab bit).

-- 
	Evgeniy Polyakov
