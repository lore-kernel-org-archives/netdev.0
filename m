From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next v3] ipv6: do not overwrite inetpeer metrics
 prematurely
Date: Wed, 26 Mar 2014 16:56:06 +0100
Message-ID: <20140326155606.GC27720@unicorn.suse.cz>
References: <20140325191155.GB22086@order.stressinduktion.org>
 <20140326154245.10C6CE6E05@unicorn.suse.cz>
 <20140326155047.GG22086@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48128 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbaCZP4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 11:56:07 -0400
Content-Disposition: inline
In-Reply-To: <20140326155047.GG22086@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 04:50:47PM +0100, Hannes Frederic Sowa wrote:
> On Wed, Mar 26, 2014 at 04:42:45PM +0100, Michal Kubecek wrote:
> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index fba54a4..b6dda6a 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -149,8 +149,10 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
> >  		unsigned long prev, new;
> >  
> >  		p = peer->metrics;
> > -		if (inet_metrics_new(peer))
> > +		if (inet_metrics_new(peer) || (dst->flags | DST_KEEP_METRICS)) {
> >  			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> > +			dst->flags &= ~DST_KEEP_METRICS;
> > +		}
> 
> The (dst->flags | DST_KEEP_METRICS) looks very suspicious. ;)

Oops. I already fixed this typo... and then did the submission from a
different branch. :-(

                                                       Michal Kubecek
