From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] inet: limit length of fragment queue hash table bucket lists
Date: Tue, 19 Mar 2013 15:08:45 +0100
Message-ID: <20130319140845.GA23421@order.stressinduktion.org>
References: <20130315213230.GB24041@order.stressinduktion.org> <20130319.100324.927922515830950770.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbrouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44430 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621Ab3CSOIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:08:47 -0400
Content-Disposition: inline
In-Reply-To: <20130319.100324.927922515830950770.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 19, 2013 at 10:03:24AM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 15 Mar 2013 22:32:30 +0100
> 
> > This patch introduces a constant limit of the fragment queue hash
> > table bucket list lengths. Currently the limit 128 is choosen somewhat
> > arbitrary and just ensures that we can fill up the fragment cache with
> > empty packets up to the default ip_frag_high_thresh limits. It should
> > just protect from list iteration eating considerable amounts of cpu.
> > 
> > If we reach the maximum length in one hash bucket a warning is printed.
> > This is implemented on the caller side of inet_frag_find to distinguish
> > between the different users of inet_fragment.c.
> > 
> > I dropped the out of memory warning in the ipv4 fragment lookup path,
> > because we already get a warning by the slab allocator.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> This looks mostly fine to me, Eric could you give it a quick review?
> 
> Although one comment from me:
> 
> > +/* averaged:
> > + * max_depth = default ipfrag_high_thresh / INETFRAGS_HASHSZ /
> > + *	       rounded up (SKB_TRUELEN(0) + sizeof(struct ipq or
> > + *	       struct frag_queue))
> > + */
> > +#define INETFRAGS_MAXDEPTH		128
> 
> If we deem this to be the ideal formula, maybe we can maintain it
> accurately and very cheaply at run time.  We'd do this by adding a
> handler for the ipfrag_high_thresh sysctl, and use that to recalculate
> the maxdepth any time ipfrag_high_thresh is changed by the user.

I already did this, have a look at patch
<20130313012715.GE14801@order.stressinduktion.org>, here:
<http://patchwork.ozlabs.org/patch/227136/>

Other comments regarding this patch are in the thread:
"ipv6: use stronger hash for reassembly queue hash table"

Thanks,

  Hannes
