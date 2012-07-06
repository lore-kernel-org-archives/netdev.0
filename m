From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] ipv6: Initialize the neighbour pointer of
 rt6_info on allocation
Date: Fri, 6 Jul 2012 08:54:26 +0200
Message-ID: <20120706065426.GF1869@secunet.com>
References: <20120705131828.GE1869@secunet.com>
 <1341501404.2583.4267.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39184 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab2GFGy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 02:54:28 -0400
Content-Disposition: inline
In-Reply-To: <1341501404.2583.4267.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 05, 2012 at 05:16:44PM +0200, Eric Dumazet wrote:
> On Thu, 2012-07-05 at 15:18 +0200, Steffen Klassert wrote:
> >  
> >  	if (rt) {
> > -		memset(&rt->rt6i_table, 0,
> > +		memset(&rt->n, 0,
> >  		       sizeof(*rt) - sizeof(struct dst_entry));
> >  		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
> >  	}
> 
> Hmm, could we find a way to avoid this for future changes ?
> 
> We know dst_entry is the first field, so maybe :
> 
> if (rt) {
> 	struct dst_entry *dst = (struct dst_entry *)rt;
> 
> 	memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
> 

Yes, I think we need to do something like this.

I've just noticed that ip6_blackhole_route, xfrm_alloc_dst,
dn_route_output_slow and dn_route_input_slow have the same issue.
