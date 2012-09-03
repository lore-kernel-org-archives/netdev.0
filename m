From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH] fq_codel: dont reinit flow state
Date: Sun, 2 Sep 2012 17:08:02 -0700
Message-ID: <CAA93jw5vrQ_yFA_+4zx6qk1PtdGeBfghvR1wY2qEr1cigoFW1g@mail.gmail.com>
References: <1346505597.7996.76.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64384 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab2ICAIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Sep 2012 20:08:04 -0400
Received: by weyx8 with SMTP id x8so2656161wey.19
        for <netdev@vger.kernel.org>; Sun, 02 Sep 2012 17:08:02 -0700 (PDT)
In-Reply-To: <1346505597.7996.76.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 1, 2012 at 6:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> When fq_codel builds a new flow, it should not reset codel state.
>
> Codel algo needs to get previous values (lastcount, drop_next) to get
> proper behavior.
>
> Signed-off-by: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_fq_codel.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 9fc1c62..4e606fc 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -191,7 +191,6 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>
>         if (list_empty(&flow->flowchain)) {
>                 list_add_tail(&flow->flowchain, &q->new_flows);
> -               codel_vars_init(&flow->cvars);
>                 q->new_flow_count++;
>                 flow->deficit = q->quantum;
>                 flow->dropped = 0;
> @@ -418,6 +417,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
>                         struct fq_codel_flow *flow = q->flows + i;
>
>                         INIT_LIST_HEAD(&flow->flowchain);
> +                       codel_vars_init(&flow->cvars);
>                 }
>         }
>         if (sch->limit >= 1)
>
>

I can live with this as is. flow->dropped will probably go away in the
long term anyway.

Acked-by: Dave Taht <dave.taht@bufferbloat.net>
