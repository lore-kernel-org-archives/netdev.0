From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] IPv6:  Warn users when route/max_entries is reached.
Date: Mon, 08 Nov 2010 13:09:29 -0800
Message-ID: <4CD86709.5090906@candelatech.com>
References: <1289243629-20789-1-git-send-email-greearb@candelatech.com> <1289243629-20789-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45601 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754730Ab0KHVJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 16:09:36 -0500
In-Reply-To: <1289243629-20789-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/08/2010 11:13 AM, Ben Greear wrote:
> Signed-off-by: Ben Greear<greearb@candelatech.com>
> ---
> :100644 100644 a275c6e... 348b34c... M	net/ipv6/route.c
>   net/ipv6/route.c |    6 +++++-
>   1 files changed, 5 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index a275c6e..348b34c 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1060,8 +1060,12 @@ static int ip6_dst_gc(struct dst_ops *ops)
>   	unsigned long rt_last_gc = net->ipv6.ip6_rt_last_gc;
>
>   	if (time_after(rt_last_gc + rt_min_interval, now)&&
> -	    atomic_read(&ops->entries)<= rt_max_size)
> +	    atomic_read(&ops->entries)<= rt_max_size) {
> +		if (net_ratelimit())
> +			pr_warning("IPv6:  Maximum number of routes reached,"
> +				   " consider increasing route/max_size.\n");
>   		goto out;
> +	}
>
>   	net->ipv6.ip6_rt_gc_expire++;
>   	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);

Please don't apply this.  I mis-read this code and that warning
is useless at best in this place.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

