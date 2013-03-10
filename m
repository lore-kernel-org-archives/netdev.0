From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sch: Rate (in bits/sec) should be u64 so it doesn't
 overflow at 40Gbit.
Date: Sat, 09 Mar 2013 20:06:34 -0800
Message-ID: <1362888394.4051.4.camel@edumazet-glaptop>
References: <1362885896-14123-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, davem@davemloft.net,
	jiri@resnulli.us, jhs@mojatatu.com
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:33961 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab3CJEGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:06:38 -0500
Received: by mail-ea0-f177.google.com with SMTP id r16so678489ead.8
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:06:37 -0800 (PST)
In-Reply-To: <1362885896-14123-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-09 at 19:24 -0800, Vimalkumar wrote:
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  include/net/sch_generic.h      |    4 ++--
>  include/uapi/linux/gen_stats.h |    2 +-
>  include/uapi/linux/pkt_sched.h |   10 +++++-----
>  net/sched/sch_generic.c        |    2 +-
>  net/sched/sch_hfsc.c           |    8 ++++----
>  5 files changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index f10818f..c9098c8 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -690,9 +690,9 @@ static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
>  	return ((u64)len * r->mult) >> r->shift;
>  }
>  
> -extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u32 rate);
> +extern void psched_ratecfg_precompute(struct psched_ratecfg *r, u64 rate);
>  
> -static inline u32 psched_ratecfg_getrate(const struct psched_ratecfg *r)
> +static inline u64 psched_ratecfg_getrate(const struct psched_ratecfg *r)
>  {
>  	return r->rate_bps >> 3;
>  }
> diff --git a/include/uapi/linux/gen_stats.h b/include/uapi/linux/gen_stats.h
> index 552c8a0..5ca6015 100644
> --- a/include/uapi/linux/gen_stats.h
> +++ b/include/uapi/linux/gen_stats.h
> @@ -33,7 +33,7 @@ struct gnet_stats_basic_packed {
>   * @pps: current packet rate
>   */
>  struct gnet_stats_rate_est {
> -	__u32	bps;
> +	__u64	bps;
>  	__u32	pps;
>  };
>  
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index 32aef0a..d6bc658 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -35,7 +35,7 @@ struct tc_stats {
>  	__u32	drops;			/* Packets dropped because of lack of resources */
>  	__u32	overlimits;		/* Number of throttle events when this
>  					 * flow goes out of allocated bandwidth */
> -	__u32	bps;			/* Current flow byte rate */
> +	__u64	bps;			/* Current flow byte rate */
>  	__u32	pps;			/* Current flow packet rate */
>  	__u32	qlen;
>  	__u32	backlog;
> @@ -79,7 +79,7 @@ struct tc_ratespec {
>  	unsigned short	overhead;
>  	short		cell_align;
>  	unsigned short	mpu;
> -	__u32		rate;
> +	__u64		rate;
>  };
>  

If this was so easy, we would have done that 10 years ago.

This change breaks userland, and thats absolutely not doable.
