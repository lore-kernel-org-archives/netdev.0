From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Wed, 2 Mar 2016 14:01:36 -0800
Message-ID: <CAM_iQpWb7iriz32qYeEeJhYUtstMbDoKqDFb=s4GNDego7nhCw@mail.gmail.com>
References: <1456891804.3297.51.camel@kyeongy-dl>
	<CAM_iQpWGtRfbbGKD6i+XY0epgNkn=mNGnWG31dLhq7XLykdvFQ@mail.gmail.com>
	<1456953590.3297.58.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "jhs@mojatatu.com" <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35488 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932468AbcCBWBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:01:38 -0500
Received: by mail-yk0-f170.google.com with SMTP id v186so1337540yke.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:01:37 -0800 (PST)
In-Reply-To: <1456953590.3297.58.camel@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 1:19 PM, Kyeong Yoo
<Kyeong.Yoo@alliedtelesis.co.nz> wrote:
> Author: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
>
> net_sched: dsmark: use qdisc_dequeue_peeked()
>
> This fix is for dsmark similar to commit 3557619f0f6f7496ed453d4825e249
> ("net_sched: prio: use qdisc_dequeue_peeked")
> and makes use of qdisc_dequeue_peeked() instead of direct dequeue() call.
>
> First time, wrr peeks dsmark, which will then peek into sfq.
> sfq dequeues an skb and it's stored in sch->gso_skb.
> Next time, wrr tries to dequeue from dsmark, which will call sfq dequeue
> directly. This results skipping the previously peeked skb.
>
> So changed dsmark dequeue to call qdisc_dequeue_peeked() instead to use
> peeked skb if exists.
>
> Signed-off-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>


Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!

>
> diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
> index f357f34..b204472 100644
> --- a/net/sched/sch_dsmark.c
> +++ b/net/sched/sch_dsmark.c
> @@ -281,7 +281,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
>
>         pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
>
> -       skb = p->q->ops->dequeue(p->q);
> +       skb = qdisc_dequeue_peeked(p->q);
>         if (skb == NULL)
>                 return NULL;
>
