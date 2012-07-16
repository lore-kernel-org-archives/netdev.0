From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: fixed sparse warning
Date: Mon, 16 Jul 2012 10:39:46 +0900
Message-ID: <20120716013946.GG16151@verge.net.au>
References: <1342198642-22741-1-git-send-email-claudiu.ghioc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	wensong@linux-vs.org, ja@ssi.bg, pablo@netfilter.org,
	kaber@trash.net, Claudiu Ghioc <claudiu.ghioc@gmail.com>
To: Claudiu Ghioc <claudiughioc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37952 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab2GPBj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 21:39:56 -0400
Content-Disposition: inline
In-Reply-To: <1342198642-22741-1-git-send-email-claudiu.ghioc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 13, 2012 at 07:57:22PM +0300, Claudiu Ghioc wrote:
> Removed the following sparse warnings:
> *	warning: symbol 'ip_vs_control_net_init_sysctl' was not declared. Should
> 	it be static?
> *	warning: symbol 'ip_vs_control_net_cleanup_sysctl' was not
> 	declared. Should it be static?

Thanks.

I wonder if you could post a version of this patch which also fixes the
alternate implementation of ip_vs_control_net_init_sysctl around line 3757 and
the alternate implementation of ip_vs_control_net_cleanup_sysctl that
appears around line 3758.

I believe that you will see sparse warnings for these if
you disable CONFIG_SYSCTL by disabling CONFIG_PROC_SYSCTL.

> 
> Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index d43e3c1..3542c6b1 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -3674,7 +3674,7 @@ static void ip_vs_genl_unregister(void)
>   * per netns intit/exit func.
>   */
>  #ifdef CONFIG_SYSCTL
> -int __net_init ip_vs_control_net_init_sysctl(struct net *net)
> +static int __net_init ip_vs_control_net_init_sysctl(struct net *net)
>  {
>  	int idx;
>  	struct netns_ipvs *ipvs = net_ipvs(net);
> @@ -3742,7 +3742,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
>  	return 0;
>  }
>  
> -void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
> +static void __net_exit ip_vs_control_net_cleanup_sysctl(struct net *net)
>  {
>  	struct netns_ipvs *ipvs = net_ipvs(net);
>  
> -- 
> 1.7.10.4
> 
