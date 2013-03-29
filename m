From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: fq_codel: Fix off-by-one error
Date: Fri, 29 Mar 2013 08:01:20 -0700
Message-ID: <1364569280.5113.21.camel@edumazet-glaptop>
References: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:57026 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117Ab3C2PBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 11:01:23 -0400
Received: by mail-da0-f48.google.com with SMTP id p8so246800dan.21
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 08:01:23 -0700 (PDT)
In-Reply-To: <1364514720-20780-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 16:52 -0700, Vijay Subramanian wrote:
> Currently, we hold a max of sch->limit -1 number of packets instead of
> sch->limit packets. Fix this off-by-one error.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  net/sched/sch_fq_codel.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 4e606fc..5578628 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -195,7 +195,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		flow->deficit = q->quantum;
>  		flow->dropped = 0;
>  	}
> -	if (++sch->q.qlen < sch->limit)
> +	if (++sch->q.qlen <= sch->limit)
>  		return NET_XMIT_SUCCESS;
>  
>  	q->drop_overlimit++;

Just curious, did you play changing the default limit (10240 packets) ?

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
