From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: increase drops and decrease backlog
 when packets are dropped
Date: Tue, 06 May 2014 06:58:21 -0700
Message-ID: <1399384701.15399.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399369056-1632-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtlam@google.com, nanditad@google.com,
	davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43722 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754931AbaEFN60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 09:58:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so541600pab.15
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 06:58:25 -0700 (PDT)
In-Reply-To: <1399369056-1632-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-06 at 17:37 +0800, Yang Yingliang wrote:
> When packets are dropped, backlog and drops statistic of qdisc
> need be changed. Replace kfree_skb() with qdisc_drop() for
> increasing drops.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---


> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 0bf432c782c1..83abd4cd10cd 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
>  	while (sch->q.qlen > sch->limit) {
>  		struct sk_buff *skb = fq_codel_dequeue(sch);
>  
> -		kfree_skb(skb);
> +		sch->qstats.backlog -= qdisc_pkt_len(skb);

Hmmm... please describe how you tested this change ?

> +		qdisc_drop(skb, sch);
>  		q->cstats.drop_count++;
>  	}
>  	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
