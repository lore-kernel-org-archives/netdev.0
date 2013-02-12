From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 06/11] sch_api: introduce
 qdisc_watchdog_schedule_ns()
Date: Tue, 12 Feb 2013 08:32:16 -0800
Message-ID: <1360686736.6884.0.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34388 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932330Ab3BLQcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:32:23 -0500
Received: by mail-pa0-f46.google.com with SMTP id kp14so168665pab.19
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:32:23 -0800 (PST)
In-Reply-To: <1360663929-1023-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
> tbf will need to schedule watchdog in ns. No need to convert it twice.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/net/pkt_sched.h | 10 ++++++++--
>  net/sched/sch_api.c     |  6 +++---
>  2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index 66f5ac3..388bf8b 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -65,8 +65,14 @@ struct qdisc_watchdog {
>  };
>  
>  extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
> -extern void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
> -				    psched_time_t expires);
> +extern void qdisc_watchdog_schedule_ns(struct qdisc_watchdog *wd, u64 expires);
> +
> +static inline void qdisc_watchdog_schedule(struct qdisc_watchdog *wd,
> +					   psched_time_t expires)
> +{
> +	qdisc_watchdog_schedule_ns(wd, PSCHED_TICKS2NS(expires));
> +}

Acked-by: Eric Dumazet <edumazet@google.com>
