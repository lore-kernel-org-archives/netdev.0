From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/3] drop_monitor: fix trace_napi_poll_hit()
Date: Thu, 27 Aug 2009 08:46:28 -0400
Message-ID: <20090827124628.GA4762@hmsreliant.think-freely.org>
References: <4A966288.8020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36814 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbZH0Mqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 08:46:40 -0400
Content-Disposition: inline
In-Reply-To: <4A966288.8020402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2009 at 06:40:08PM +0800, Xiao Guangrong wrote:
> The net_dev of backlog napi is NULL, like below:
> 
> __get_cpu_var(softnet_data).backlog.dev == NULL
> 
> So, we should check it in napi tracepoint's probe function
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
> ---
>  net/core/drop_monitor.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 9d66fa9..d311202 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -182,7 +182,8 @@ static void trace_napi_poll_hit(struct napi_struct *napi)
>  	/*
>  	 * Ratelimit our check time to dm_hw_check_delta jiffies
>  	 */
> -	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> +	if (!napi->dev ||
> +	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
>  		return;
>  
>  	rcu_read_lock();
> -- 
> 1.6.1.2
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

Thanks!
Neil

