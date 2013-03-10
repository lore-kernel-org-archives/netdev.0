From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Rate should be u64 to avoid integer overflow at high
 speeds (>= ~35Gbit)
Date: Sat, 09 Mar 2013 20:03:49 -0800
Message-ID: <1362888229.4051.2.camel@edumazet-glaptop>
References: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:44188 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab3CJEDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:03:53 -0500
Received: by mail-ea0-f178.google.com with SMTP id g14so707102eak.23
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:03:51 -0800 (PST)
In-Reply-To: <1362885604-14006-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-09 at 19:20 -0800, Vimalkumar wrote:
> Since rate values are passed around between kernel and tc
> in bytes/sec, 2**32 bytes/sec is around 34Gb/s.  Beyond that
> rate, htb, tbf, hfsc, etc. can never be configured correctly.
> 
> Signed-off-by: Vimalkumar <j.vimal@gmail.com>
> ---
>  include/linux/gen_stats.h |    2 +-
>  include/linux/pkt_sched.h |   10 +++++-----
>  misc/ifstat.c             |    4 ++--
>  tc/m_police.c             |    2 +-
>  tc/q_cbq.c                |    2 +-
>  tc/q_choke.c              |    2 +-
>  tc/q_gred.c               |    2 +-
>  tc/q_hfsc.c               |    6 ++++--
>  tc/q_red.c                |    2 +-
>  tc/tc_cbq.c               |    4 ++--
>  tc/tc_cbq.h               |    4 ++--
>  tc/tc_core.c              |    4 ++--
>  tc/tc_core.h              |    4 ++--
>  tc/tc_util.c              |    6 +++---
>  tc/tc_util.h              |    6 +++---
>  15 files changed, 31 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
> index 552c8a0..5ca6015 100644
> --- a/include/linux/gen_stats.h
> +++ b/include/linux/gen_stats.h
> @@ -33,7 +33,7 @@ struct gnet_stats_basic_packed {
>   * @pps: current packet rate
>   */
>  struct gnet_stats_rate_est {
> -	__u32	bps;
> +	__u64	bps;
>  	__u32	pps;
>  };
>  
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 32aef0a..d6bc658 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
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

You cannot do that without breaking user land tools.

Not only tc, but all user applications as well.

We need to support compatibility, before considering adding such
changes.
