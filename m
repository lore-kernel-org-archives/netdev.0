From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 10/13] net: sched: lockless support for
 netif_schedule
Date: Wed, 17 Aug 2016 16:01:17 -0700
Message-ID: <1471474877.29842.54.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
	 <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35094 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbcHQXB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:01:59 -0400
Received: by mail-pa0-f68.google.com with SMTP id cf3so202535pad.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:01:19 -0700 (PDT)
In-Reply-To: <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 12:37 -0700, John Fastabend wrote:

> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index d10b762..f5b7254 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -171,6 +171,7 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
>  			if (qdisc_is_percpu_stats(q)) {
>  				qdisc_qstats_cpu_backlog_inc(q, nskb);
>  				qdisc_qstats_cpu_qlen_inc(q);
> +				set_thread_flag(TIF_NEED_RESCHED);
>  			} else {
>  				qdisc_qstats_backlog_inc(q, nskb);
>  				q->q.qlen++;

Hmm... care to elaborate this bit ?
