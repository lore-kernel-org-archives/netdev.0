From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] sctp: check the rto_min and rto_max
Date: Mon, 02 Dec 2013 09:45:39 -0500
Message-ID: <529C9D13.10107@gmail.com>
References: <529BE620.8090004@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	dingtianhong@huawei.com
To: Wang Weidong <wangweidong1@huawei.com>, nhorman@tuxdriver.com,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:60224 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab3LBOpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 09:45:42 -0500
In-Reply-To: <529BE620.8090004@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2013 08:45 PM, Wang Weidong wrote:
> rto_min should be smaller than rto_max while rto_max should be larger
> than rto_min. so just add the check.
> 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
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
> 

So, now if initial namespace change rto_min and rto_max, it limits the
values that another namespace can set?  I don't think so.

If you are looking to fix an issue where rto_max may be set below
rto_min, then do a separate proc_handler.

-vlad
