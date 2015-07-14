From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] fq_codel: fix a use-after-free
Date: Tue, 14 Jul 2015 08:23:38 +0200
Message-ID: <1436855018.1374.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436815807-25359-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34415 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbGNGXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 02:23:42 -0400
Received: by wibud3 with SMTP id ud3so46870722wib.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 23:23:41 -0700 (PDT)
In-Reply-To: <1436815807-25359-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-07-13 at 12:30 -0700, Cong Wang wrote:
> Fixes: 25331d6ce42b ("net: sched: implement qstat helper routines")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> ---
>  net/sched/sch_fq_codel.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index d75993f..06e7c84 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -155,10 +155,10 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
>  	skb = dequeue_head(flow);
>  	len = qdisc_pkt_len(skb);
>  	q->backlogs[idx] -= len;
> -	kfree_skb(skb);
>  	sch->q.qlen--;
>  	qdisc_qstats_drop(sch);
>  	qdisc_qstats_backlog_dec(sch, skb);
> +	kfree_skb(skb);
>  	flow->dropped++;
>  	return idx;
>  }

Thanks Cong

Acked-by: Eric Dumazet <edumazet@google.com>
