From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: action stats double dip
Date: 25 Mar 2005 15:25:25 -0500
Message-ID: <1111782325.1089.641.camel@jzny.localdomain>
References: <1111767913.1091.530.camel@jzny.localdomain>
	 <1111768884.1092.533.camel@jzny.localdomain>
	 <20050325200650.GC3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050325200650.GC3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 15:06, Thomas Graf wrote:
> * jamal <1111768884.1092.533.camel@jzny.localdomain> 2005-03-25 11:41
> >  
> > -	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> > -		goto rtattr_failure;
> > +	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
> > +		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> > +			goto rtattr_failure;
> 
> Why is this needed? Maybe I'm missing something in the logic but
> tcf_exts_dump_stats checks for exts->action and if in compat mode
> provides the old stats TLVs. I'm not claiming that the current code
> is correct but the fix should go into tcf_exts_dump_stats rather
> than into every classifier.

tcf_exts_dump (called above the those calls) already dumps stats if you
are not in old compatibility mode. It doesnt when you are in old compat
mode. 
You could probably play tricks to move things into it; 
The main exception would be cls_u32 where you need to check
TC_U32_KEY(n->handle) and old compatibility;
I take it when you were creating the patches you left things
in the classifiers for consistency? I just followed the way you already
had it (which is fine in my opinion).
Otherwise all classifiers but u32 could have their code moved.

cheers,
jamal
