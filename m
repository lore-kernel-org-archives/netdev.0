From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: action stats double dip
Date: Fri, 25 Mar 2005 21:06:50 +0100
Message-ID: <20050325200650.GC3086@postel.suug.ch>
References: <1111767913.1091.530.camel@jzny.localdomain> <1111768884.1092.533.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111768884.1092.533.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1111768884.1092.533.camel@jzny.localdomain> 2005-03-25 11:41
>  
> -	if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> -		goto rtattr_failure;
> +	if (f->exts.action && f->exts.action->type == TCA_OLD_COMPAT)
> +		if (tcf_exts_dump_stats(skb, &f->exts, &route_ext_map) < 0)
> +			goto rtattr_failure;

Why is this needed? Maybe I'm missing something in the logic but
tcf_exts_dump_stats checks for exts->action and if in compat mode
provides the old stats TLVs. I'm not claiming that the current code
is correct but the fix should go into tcf_exts_dump_stats rather
than into every classifier.
