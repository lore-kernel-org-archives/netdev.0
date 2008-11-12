From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 13:44:39 +0300
Message-ID: <20081112104439.GA4292@x200.localdomain>
References: <20081110.164424.167225199.davem@davemloft.net> <20081111110847.GC3665@x200.localdomain> <20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:7195 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbYKLKlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:41:15 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1001431ugf.37
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2008 02:41:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081111.164554.143409564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 04:45:54PM -0800, David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 11 Nov 2008 14:19:46 +0300
> 
> > @@ -35,7 +35,9 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
> >  	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
> >  
> >  	if (tb != NULL) {
> > +#ifdef CONFIG_NET_NS
> >  		tb->ib_net       = hold_net(net);
> > +#endif
> >  		tb->port      = snum;
> >  		tb->fastreuse = 0;
> >  		INIT_HLIST_HEAD(&tb->owners);
> 
> No, this is exactly what we don't want.
> 
> If you have to add ifdefs to core C files, you're doing something
> wrong.

It depends.

> All the details of ifdef this or ifdef that should be hidden in the
> header files.

It depends.

> You cited an example where there are a ton of ifdefs in some header
> fule inline function, but that is EXACTLY how this stuff should be
> done.  Those header files are where such ugly implementation details
> belong.
> 
> When people read actual code, they should be concerning themselves
> with control flow, what the code is trying to do, etc. rather then
> being continually interrupted with ifdef this and ifdef that.

On the other hand, people are interrupted with ctags jumping when suddenly
whole new file appears, so loss of context is even more. Distance between
static inline pair tend to increase as people add more stuff in between.

And how this one line ifdef (in one place -- allocation) can interrupt
control flow when you see it's start and immediately see it's end? Is it
because ifdef starts at column one, and code on average is two-three tabs
indented, so eye jumps to column one?

Whey you are suspicious of the code (say, look for a bug) these wrappers
are nuisaince, because some very smart one may do completely unexpected
thing wrt it's innocent name. And you check them all because you're
suspicious.

Netdevices use dev_net_set(). Add ib_net_set() and forget about this hungarian
pnet thing. const qualifier is also pointless, there maybe nothing wrong with
it, be there is nothing right as well.

Well, yes, Linus starts blogging and hungarian notation in core networking. :-)
