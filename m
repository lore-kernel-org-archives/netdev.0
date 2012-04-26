From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] IPVS: ip_vs_sync.c: local functions should not be exposed
 globally
Date: Thu, 26 Apr 2012 23:11:54 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1204262301160.2078@ja.ssi.bg>
References: <201204261129.53927.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204261129.53927.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 26 Apr 2012, H Hartley Sweeten wrote:

> Functions not referenced outside of a source file should be marked
> static to prevent it from being exposed globally.
> 
> This quiets the sparse warnings:
> 
> warning: symbol 'ip_vs_sync_conn_v0' was not declared. Should it be static?
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index bf5e538..49a1fe8 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -446,7 +446,7 @@ ip_vs_sync_buff_create_v0(struct netns_ipvs *ipvs)
>   *      Version 0 , could be switched in by sys_ctl.
>   *      Add an ip_vs_conn information into the current sync_buff.
>   */
> -void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)
> +static void ip_vs_sync_conn_v0(struct net *net, struct ip_vs_conn *cp)

	The 3 patches for IPVS look correct but this change
is already not needed after one of our planned changes:

"ipvs: reduce sync rate with time thresholds"

	Not sure how we will avoid the collision, may be
Simon will take only the other 2 changes? Or David will
take all changes and we have to rebase?

>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  	struct ip_vs_sync_mesg_v0 *m;
> --

Regards

--
Julian Anastasov <ja@ssi.bg>
