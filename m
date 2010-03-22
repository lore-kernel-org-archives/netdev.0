From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch v2] netpoll: warn when there are spaces in parameters
Date: Mon, 22 Mar 2010 08:30:46 -0400
Message-ID: <20100322123046.GA4288@hmsreliant.think-freely.org>
References: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	elendil@planet.nl, David Miller <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45572 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686Ab0CVMa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 08:30:58 -0400
Content-Disposition: inline
In-Reply-To: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 22, 2010 at 04:59:58AM -0400, Amerigo Wang wrote:
> v2: update according to Frans' comments.
> 
> Currently, if we leave spaces before dst port,
> netconsole will silently accept it as 0. Warn about this.
> 
> Also, when spaces appear in other places, make them
> visible in error messages.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David Miller <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 7aa6972..6df1863 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -614,7 +614,7 @@ void netpoll_print_options(struct netpoll *np)
>  			 np->name, np->local_port);
>  	printk(KERN_INFO "%s: local IP %pI4\n",
>  			 np->name, &np->local_ip);
> -	printk(KERN_INFO "%s: interface %s\n",
> +	printk(KERN_INFO "%s: interface '%s'\n",
>  			 np->name, np->dev_name);
>  	printk(KERN_INFO "%s: remote port %d\n",
>  			 np->name, np->remote_port);
> @@ -661,6 +661,9 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
>  		if ((delim = strchr(cur, '@')) == NULL)
>  			goto parse_failed;
>  		*delim = 0;
> +		if (*cur == ' ' || *cur == '\t')
> +			printk(KERN_INFO "%s: warning: whitespace"
> +					"is not allowed\n", np->name);
>  		np->remote_port = simple_strtol(cur, NULL, 10);
>  		cur = delim;
>  	}
> @@ -708,7 +711,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
>  	return 0;
>  
>   parse_failed:
> -	printk(KERN_INFO "%s: couldn't parse config at %s!\n",
> +	printk(KERN_INFO "%s: couldn't parse config at '%s'!\n",
>  	       np->name, cur);
>  	return -1;
>  }
Acked-by: Neil Horman <nhorman@tuxdriver.com>

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
