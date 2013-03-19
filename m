From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table bucket lists
Date: Tue, 19 Mar 2013 15:22:28 +0100
Message-ID: <20130319142228.GB23421@order.stressinduktion.org>
References: <20130315213230.GB24041@order.stressinduktion.org> <20130319.100324.927922515830950770.davem@davemloft.net> <1363702543.2558.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jbrouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44474 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab3CSOWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:22:30 -0400
Content-Disposition: inline
In-Reply-To: <1363702543.2558.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 07:15:43AM -0700, Eric Dumazet wrote:
> On Tue, 2013-03-19 at 10:03 -0400, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Fri, 15 Mar 2013 22:32:30 +0100
> > 
> > > This patch introduces a constant limit of the fragment queue hash
> > > table bucket list lengths. Currently the limit 128 is choosen somewhat
> > > arbitrary and just ensures that we can fill up the fragment cache with
> > > empty packets up to the default ip_frag_high_thresh limits. It should
> > > just protect from list iteration eating considerable amounts of cpu.
> > > 
> > > If we reach the maximum length in one hash bucket a warning is printed.
> > > This is implemented on the caller side of inet_frag_find to distinguish
> > > between the different users of inet_fragment.c.
> > > 
> > > I dropped the out of memory warning in the ipv4 fragment lookup path,
> > > because we already get a warning by the slab allocator.
> > > 
> > > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > > Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> > > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > 
> > This looks mostly fine to me, Eric could you give it a quick review?
> > 
> 
> Sure, it looks ok for me
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> > Although one comment from me:
> > 
> > > +/* averaged:
> > > + * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
> > > + *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
> > > + *	       struct frag_queue))
> > > + */
> > > +#define INETFRAGS_MAXDEPTH		128
> > 
> > If we deem this to be the ideal formula, maybe we can maintain it
> > accurately and very cheaply at run time.  We'd do this by adding a
> > handler for the ipfrag_high_thresh sysctl, and use that to recalculate
> > the maxdepth any time ipfrag_high_thresh is changed by the user.
> 
> This can probably be done in a second patch for net-next

I'll rebase the old patch introducing inet_frag_update_high_thresh ontop
this one. I think the dynamic update might be useful if we lower the
maxdepth limit in future.
