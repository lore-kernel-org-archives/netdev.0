From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/3] net: Kill ratelimit.h dependency in linux/net.h
Date: Fri, 27 May 2011 10:44:03 +0200
Message-ID: <20110527084403.GD21386@elte.hu>
References: <20110526.164330.2076981043593394399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:50030 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753556Ab1E0IoI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 04:44:08 -0400
Content-Disposition: inline
In-Reply-To: <20110526.164330.2076981043593394399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> Ingo Molnar noticed that we have this unnecessary ratelimit.h
> dependency in linux/net.h, which hid compilation problems from
> people doing builds only with CONFIG_NET enabled.
> 
> Move this stuff out to a seperate net/net_ratelimit.h file and
> include that in the only two places where this thing is needed.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/net.h        |    6 ------
>  net/core/sysctl_net_core.c |    1 +
>  net/core/utils.c           |    1 +
>  3 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 1da55e9..b299230 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -289,11 +289,5 @@ extern int kernel_sock_shutdown(struct socket *sock,
>  	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
>  		     "-type-" __stringify(type))
>  
> -#ifdef CONFIG_SYSCTL
> -#include <linux/sysctl.h>
> -#include <linux/ratelimit.h>
> -extern struct ratelimit_state net_ratelimit_state;
> -#endif
> -

Assuming that this moved into net_ratelimit.h with a guard define 
this looks good to me:

Acked-by: Ingo Molnar <mingo@elte.hu>

Thanks,

	Ingo
