From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] IPVS: Removed unused conntrack sysctl entry
Date: Sun, 25 Sep 2011 11:29:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1109251125010.1474@ja.ssi.bg>
References: <1316911743-28269-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38084 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab1IYI2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 04:28:38 -0400
In-Reply-To: <1316911743-28269-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 25 Sep 2011, Simon Horman wrote:

> This does not appear to be used anywhere.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |   11 -----------
>  1 files changed, 0 insertions(+), 11 deletions(-)
> 
> Julian, I cant see any users of this sysctl in the current code.
> Am I missing something?

	It is used, see ip_vs_conntrack_enabled() in
include/net/ip_vs.h, after the netns changes the var is
named sysctl_conntrack.

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 36f4495..49befca 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -1605,14 +1605,6 @@ static struct ctl_table vs_vars[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_do_defense_mode,
>  	},
> -#ifdef CONFIG_IP_VS_NFCT
> -	{
> -		.procname	= "conntrack",
> -		.maxlen		= sizeof(int),
> -		.mode		= 0644,
> -		.proc_handler	= &proc_dointvec,
> -	},
> -#endif
>  	{
>  		.procname	= "secure_tcp",
>  		.maxlen		= sizeof(int),
> @@ -3535,9 +3527,6 @@ int __net_init __ip_vs_control_init_sysctl(struct net *net)
>  	tbl[idx++].data = &ipvs->sysctl_am_droprate;
>  	tbl[idx++].data = &ipvs->sysctl_drop_entry;
>  	tbl[idx++].data = &ipvs->sysctl_drop_packet;
> -#ifdef CONFIG_IP_VS_NFCT
> -	tbl[idx++].data = &ipvs->sysctl_conntrack;
> -#endif
>  	tbl[idx++].data = &ipvs->sysctl_secure_tcp;
>  	ipvs->sysctl_snat_reroute = 1;
>  	tbl[idx++].data = &ipvs->sysctl_snat_reroute;
> -- 
> 1.7.5.4

Regards

--
Julian Anastasov <ja@ssi.bg>
