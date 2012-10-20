From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Sat, 20 Oct 2012 12:29:36 +0200
Message-ID: <1350728976.13333.544.camel@edumazet-glaptop>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41999 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab2JTK3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 06:29:41 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so455317eek.19
        for <netdev@vger.kernel.org>; Sat, 20 Oct 2012 03:29:39 -0700 (PDT)
In-Reply-To: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-19 at 15:26 -0700, Vimalkumar wrote:

> +	if (likely(next_event > q->now)) {
> +		if (!test_bit(__QDISC_STATE_DEACTIVATED,
> +			      &qdisc_root_sleeping(q->watchdog.qdisc)->state)) {
> +			ktime_t time = ktime_set(0, 0);
> +			qdisc_throttled(q->watchdog.qdisc);
> +			time = ktime_add_ns(time, next_event);
> +			hrtimer_start(&q->watchdog.timer, time,
> +				      HRTIMER_MODE_ABS);
> +		}
> +	} else 


could use ns_to_ktime() helper

+	if (likely(next_event > q->now)) {
> +		if (!test_bit(__QDISC_STATE_DEACTIVATED,
> +			      &qdisc_root_sleeping(q->watchdog.qdisc)->state)) {
> +			qdisc_throttled(q->watchdog.qdisc);
> +			hrtimer_start(&q->watchdog.timer, ns_to_ktime(next_event),
> +				      HRTIMER_MODE_ABS);
> +		}
> +	} else 

I'll post a patch to cleanup net/sched/sch_api.c & net/sched/sch_cbq.c
