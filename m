From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 1/4] bpf: add helper bpf_perf_read_counter_time
 for perf event array map
Date: Fri, 1 Sep 2017 22:41:09 +0200
Message-ID: <20170901204109.GT6524@worktop.programming.kicks-ass.net>
References: <20170901165357.465121-1-yhs@fb.com>
 <20170901165357.465121-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:56847 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdIAUlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 16:41:18 -0400
Content-Disposition: inline
In-Reply-To: <20170901165357.465121-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 01, 2017 at 09:53:54AM -0700, Yonghong Song wrote:
> diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
> index b14095b..7fd5e94 100644
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -901,6 +901,8 @@ extern void perf_pmu_migrate_context(struct pmu *pmu,
>  int perf_event_read_local(struct perf_event *event, u64 *value);
>  extern u64 perf_event_read_value(struct perf_event *event,
>  				 u64 *enabled, u64 *running);
> +extern void calc_timer_values(struct perf_event *event, u64 *now,
> +         u64 *enabled, u64 *running);
>  
>  

> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 8c01572..ef5c7fb 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -4883,7 +4883,7 @@ static int perf_event_index(struct perf_event *event)
>  	return event->pmu->event_idx(event);
>  }
>  
> -static void calc_timer_values(struct perf_event *event,
> +void calc_timer_values(struct perf_event *event,
>  				u64 *now,
>  				u64 *enabled,
>  				u64 *running)

Yeah, not going to happen...

Why not do the obvious thing and extend perf_event_read_local() to
optionally return the enabled/running times?
