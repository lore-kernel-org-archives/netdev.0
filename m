From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch 1/1] ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
Date: Tue, 30 Apr 2013 11:24:17 +0900
Message-ID: <20130430022417.GA24214@verge.net.au>
References: <20130429185510.DFBB031C266@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	zhangyanfei@cn.fujitsu.com, ja@ssi.bg
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57960 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3D3CYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 22:24:21 -0400
Content-Disposition: inline
In-Reply-To: <20130429185510.DFBB031C266@corp2gmr1-1.hot.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 11:55:10AM -0700, akpm@linux-foundation.org wrote:
> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Subject: ipvs: change type of netns_ipvs->sysctl_sync_qlen_max
> 
> This member of struct netns_ipvs is calculated from nr_free_buffer_pages
> so change its type to unsigned long in case of overflow.  Also, type of
> its related proc var sync_qlen_max and the return type of function
> sysctl_sync_qlen_max() should be changed to unsigned long, too.
> 
> Besides, the type of ipvs_master_sync_state->sync_queue_len should be
> changed to unsigned long accordingly.
> 
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Andrew, David,

It seems most appropriate for me to
queue this up for v3.11 in the ipvs-next tree.

Is that fine?

> ---
> 
>  include/net/ip_vs.h            |    8 ++++----
>  net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
>  2 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff -puN include/net/ip_vs.h~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max include/net/ip_vs.h
> --- a/include/net/ip_vs.h~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max
> +++ a/include/net/ip_vs.h
> @@ -905,7 +905,7 @@ struct ip_vs_app {
>  struct ipvs_master_sync_state {
>  	struct list_head	sync_queue;
>  	struct ip_vs_sync_buff	*sync_buff;
> -	int			sync_queue_len;
> +	unsigned long		sync_queue_len;
>  	unsigned int		sync_queue_delay;
>  	struct task_struct	*master_thread;
>  	struct delayed_work	master_wakeup_work;
> @@ -998,7 +998,7 @@ struct netns_ipvs {
>  	int			sysctl_snat_reroute;
>  	int			sysctl_sync_ver;
>  	int			sysctl_sync_ports;
> -	int			sysctl_sync_qlen_max;
> +	unsigned long		sysctl_sync_qlen_max;
>  	int			sysctl_sync_sock_size;
>  	int			sysctl_cache_bypass;
>  	int			sysctl_expire_nodest_conn;
> @@ -1085,7 +1085,7 @@ static inline int sysctl_sync_ports(stru
>  	return ACCESS_ONCE(ipvs->sysctl_sync_ports);
>  }
>  
> -static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
> +static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
>  {
>  	return ipvs->sysctl_sync_qlen_max;
>  }
> @@ -1138,7 +1138,7 @@ static inline int sysctl_sync_ports(stru
>  	return 1;
>  }
>  
> -static inline int sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
> +static inline unsigned long sysctl_sync_qlen_max(struct netns_ipvs *ipvs)
>  {
>  	return IPVS_SYNC_QLEN_MAX;
>  }
> diff -puN net/netfilter/ipvs/ip_vs_ctl.c~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max net/netfilter/ipvs/ip_vs_ctl.c
> --- a/net/netfilter/ipvs/ip_vs_ctl.c~ipvs-change-type-of-netns_ipvs-sysctl_sync_qlen_max
> +++ a/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1705,9 +1705,9 @@ static struct ctl_table vs_vars[] = {
>  	},
>  	{
>  		.procname	= "sync_qlen_max",
> -		.maxlen		= sizeof(int),
> +		.maxlen		= sizeof(unsigned long),
>  		.mode		= 0644,
> -		.proc_handler	= proc_dointvec,
> +		.proc_handler	= proc_doulongvec_minmax,
>  	},
>  	{
>  		.procname	= "sync_sock_size",
> _
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
