From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v8 net-next 2/7] net: add low latency
	socket poll
Date: Mon, 03 Jun 2013 06:05:04 -0700
Message-ID: <1370264704.24311.129.camel@edumazet-glaptop>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
	<20130603080128.18273.2408.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eilon Greenstien <eilong@broadcom.com>, David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130603080128.18273.2408.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-03 at 11:01 +0300, Eliezer Tamir wrote:
> Adds an ndo_ll_poll method and the code that supports it.
> This method can be used by low latency applications to busy-poll
> Ethernet device queues directly from the socket code.
> sysctl_net_ll_poll controls how many microseconds to poll.
> Default is zero (disabled).
> Individual protocol support will be added by subsequent patches.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
...
> diff --git a/include/net/ll_poll.h b/include/net/ll_poll.h

> +
> +static inline bool sk_valid_ll(struct sock *sk)
> +{
> +	return 0;

	return false;

> +}
> +
> +static inline bool sk_poll_ll(struct sock *sk, int nonblock)
> +{
> +	return 0;

	return false;
> +}
> +
> +static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
> +{
> +}


>  	/*
>  	 * Before updating sk_refcnt, we must commit prior changes to memory
>  	 * (Documentation/RCU/rculist_nulls.txt for details)
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index 741db5fc..ae98c95 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -19,6 +19,7 @@
>  #include <net/ip.h>
>  #include <net/sock.h>
>  #include <net/net_ratelimit.h>
> +#include <net/ll_poll.h>
>  
>  static int one = 1;
>  
> @@ -284,6 +285,15 @@ static struct ctl_table net_core_table[] = {
>  		.proc_handler	= flow_limit_table_len_sysctl
>  	},
>  #endif /* CONFIG_NET_FLOW_LIMIT */
> +#ifdef CONFIG_NET_LL_RX_POLL
> +	{
> +		.procname	= "low_latency_poll",
> +		.data		= &sysctl_net_ll_poll,
> +		.maxlen		= sizeof(unsigned long),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec

proc_doulongvec_minmax




------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite
It's a free troubleshooting tool designed for production
Get down to code-level detail for bottlenecks, with <2% overhead.
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
