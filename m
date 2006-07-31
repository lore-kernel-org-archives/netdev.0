From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Mon, 31 Jul 2006 17:34:24 +0200
Message-ID: <20060731153424.GJ14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.495778268@postel.suug.ch> <44CE0BE6.1070108@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13779 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030192AbWGaPeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 11:34:04 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44CE0BE6.1070108@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-07-31 16:55
> > When locating routes for redirects only the main table is
> > searched for now. Since policy rules will not be reversible
> > it is unclear whether it makes sense to change this.
> 
> This is a good point. You are absolutely correct about the policy rules.
> 
> IIRC, I initially looked through all the tables, but skipped this
> behavior when I rewrote the code for 2.6.11. Currently I'm once again
> in favor of looping through them all. This is IMO at least closer to the
> spirit of RFC 2461 section 8.3. where a host SHOULD update its
> destination cache upon receiving a redirect. If we don't look through
> all tables, we can't ensure this happens.

I agree, it will depend on what way is being followed regarding a
flow cache or route cache.

> > +#define RT6_TABLE_UNSPEC	RT_TABLE_UNSPEC
> > +#define RT6_TABLE_MAIN		RT_TABLE_MAIN
> > +#define RT6_TABLE_LOCAL		RT6_TABLE_MAIN
> > +#define RT6_TABLE_DFLT		RT6_TABLE_MAIN
> > +#define RT6_TABLE_INFO		RT6_TABLE_MAIN
> 
> IMO it's a bit inconsistent to define a separate table entry for Route
> Information generated routes, but not Prefix Information based ones.
> What do you say about adding a RT6_TABLE_PRFX?

Sounds good.

> > @@ -1435,12 +1523,15 @@ static struct rt6_info *rt6_add_route_in
> >  struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *dev)
> >  {	
> >  	struct rt6_info *rt;
> > -	struct fib6_node *fn;
> > +	struct fib6_table *table;
> >  
> > -	fn = &ip6_routing_table;
> > +	/* TODO: It might be better to search all tables */
> > +	table = fib6_get_table(RT6_TABLE_DFLT);
> 
> As long as the table for default routes is RT6_TABLE_DFLT and can't be
> configured by the user, I think the correct behavior is just to search
> RT6_TABLE_DFLT.

I agree, I intended to remove that comment but missed it.
