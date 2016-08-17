From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 12/13] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Wed, 17 Aug 2016 12:49:34 -0700
Message-ID: <57B4BFCE.2040507@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193838.27032.29727.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33595 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbcHQTvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:51:16 -0400
Received: by mail-pa0-f66.google.com with SMTP id vy10so7905742pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:49:49 -0700 (PDT)
In-Reply-To: <20160817193838.27032.29727.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 12:38 PM, John Fastabend wrote:
> The sch_mq qdisc creates a sub-qdisc per tx queue which are then
> called independently for enqueue and dequeue operations. However
> statistics are aggregated and pushed up to the "master" qdisc.
> 
> This patch adds support for any of the sub-qdiscs to be per cpu
> statistic qdiscs. To handle this case add a check when calculating
> stats and aggregate the per cpu stats if needed.
> 
> Also exports __gnet_stats_copy_queue() to use as a helper function.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

[...]

> +		if (qdisc_is_percpu_stats(qdisc)) {
> +			cpu_bstats = qdisc->cpu_bstats;
> +			cpu_qstats = qdisc->cpu_qstats;
> +		}
> +
> +		qlen = qdisc_qlen_sum(qdisc);
> +
> +		__gnet_stats_copy_basic(NULL, &sch->bstats,
> +					cpu_bstats, &qdisc->bstats);
> +		__gnet_stats_copy_queue(&sch->qstats,
> +					cpu_qstats, &qdisc->qstats, qlen);


And also I forgot to bump this onto the atomic qlen and it is still
using the per cpu counters giving the incorrect qlen total.
