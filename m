From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: action stats double dip
Date: Fri, 25 Mar 2005 21:41:10 +0100
Message-ID: <20050325204110.GF3086@postel.suug.ch>
References: <1111767913.1091.530.camel@jzny.localdomain> <1111768884.1092.533.camel@jzny.localdomain> <20050325200650.GC3086@postel.suug.ch> <1111782325.1089.641.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111782325.1089.641.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1111782325.1089.641.camel@jzny.localdomain> 2005-03-25 15:25
> On Fri, 2005-03-25 at 15:06, Thomas Graf wrote:
> > * jamal <1111768884.1092.533.camel@jzny.localdomain> 2005-03-25 11:41
> > >  
> > > -	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> > > -		goto rtattr_failure;
> > > +	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
> > > +		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> > > +			goto rtattr_failure;
> > 
> > Why is this needed? Maybe I'm missing something in the logic but
> > tcf_exts_dump_stats checks for exts->action and if in compat mode
> > provides the old stats TLVs. I'm not claiming that the current code
> > is correct but the fix should go into tcf_exts_dump_stats rather
> > than into every classifier.
> 
> tcf_exts_dump (called above the those calls) already dumps stats if you
> are not in old compatibility mode. It doesnt when you are in old compat
> mode. 
> You could probably play tricks to move things into it; 
> The main exception would be cls_u32 where you need to check
> TC_U32_KEY(n->handle) and old compatibility;

Right, I had to leave it splitted for u32 but there are still
issues. With your changes, the old policer will not get its stats
dumped anymore. Any reason for keeping the old policer alive? or
can we purge it and make everyone use the compatibility police
action?  Don't waste any time on this, it's my fault so let me
resolve this.
