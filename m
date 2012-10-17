From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] netfilter: nf_conntrack: fix rt_gateway checks for
 h323
Date: Wed, 17 Oct 2012 22:44:19 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210172240160.1654@ja.ssi.bg>
References: <1349823647-2166-1-git-send-email-ja@ssi.bg> <20121016235534.GA2805@1984> <alpine.LFD.2.00.1210171111150.1679@ja.ssi.bg> <20121017123957.GA31202@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	zhaojingmin@users.sourceforge.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121017123957.GA31202@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 17 Oct 2012, Pablo Neira Ayuso wrote:

> > 	But if creating expectation is considered harmless
> > then better to use just the rt_nexthop check because
> > checking for subnets is too risky, hosts can use different
> > subnet masks. By this way we reduce the risk to connect
> > internal hosts without expectation.
> 
> It creates an expection for the IP parsed as result of the call
> forwarding that will expire after 240 seconds. So it consumes memory
> but it will expire after that time.
> 
> I prefer not to modify this code unless someone using the H.323 helper
> reports a problem.

	Agreed

> Thanks for your comments. I'll take your patch and extend the
> description a bit to explain the current situation of that chunk of
> code for the history.

	Yes, it needs better description. Thanks!

> > > > diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> > > > index 1b30b0d..962795e 100644
> > > > --- a/net/netfilter/nf_conntrack_h323_main.c
> > > > +++ b/net/netfilter/nf_conntrack_h323_main.c
> > > > @@ -753,7 +753,8 @@ static int callforward_do_filter(const union nf_inet_addr *src,
> > > >  				   flowi4_to_flowi(&fl1), false)) {
> > > >  			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
> > > >  					   flowi4_to_flowi(&fl2), false)) {
> > > > -				if (rt1->rt_gateway == rt2->rt_gateway &&
> > > > +				if (rt_nexthop(rt1, fl1.daddr) ==
> > > > +				    rt_nexthop(rt2, fl2.daddr) &&
> > > >  				    rt1->dst.dev  == rt2->dst.dev)
> > > >  					ret = 1;
> > > >  				dst_release(&rt2->dst);
> > > > -- 
> > > > 1.7.3.4

Regards

--
Julian Anastasov <ja@ssi.bg>
