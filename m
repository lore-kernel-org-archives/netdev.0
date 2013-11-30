From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: check the rto_min and rto_max
Date: Sat, 30 Nov 2013 09:17:42 -0500
Message-ID: <20131130141741.GA12344@neilslaptop.think-freely.org>
References: <5299BCB8.6070409@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dingtianhong@huawei.com
To: wangweidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40090 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab3K3OSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 09:18:00 -0500
Content-Disposition: inline
In-Reply-To: <5299BCB8.6070409@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 30, 2013 at 06:23:52PM +0800, wangweidong wrote:
> rto_min should be smaller than rto_max while rto_max should be larger
> than rto_min. so just add the check.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sctp/sysctl.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
> index 6b36561..7637e8e 100644
> --- a/net/sctp/sysctl.c
> +++ b/net/sctp/sysctl.c
> @@ -104,7 +104,7 @@ static struct ctl_table sctp_net_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
>  		.extra1         = &one,
> -		.extra2         = &timer_max
> +		.extra2         = &init_net.sctp.rto_max
>  	},
>  	{
>  		.procname	= "rto_max",
> @@ -112,7 +112,7 @@ static struct ctl_table sctp_net_table[] = {
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> -		.extra1         = &one,
> +		.extra1         = &init_net.sctp.rto_min,
>  		.extra2         = &timer_max
>  	},
>  	{
> -- 
> 1.7.12
> 
> 
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>
