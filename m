From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: return NET_XMIT_DROP when packet is
 dropped
Date: Fri, 16 May 2014 05:57:52 -0700
Message-ID: <1400245072.7973.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400231990-10404-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vtlam@google.com, nanditad@google.com,
	davem@davemloft.net
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56792 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbaEPM5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 08:57:55 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so2527917pad.32
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 05:57:55 -0700 (PDT)
In-Reply-To: <1400231990-10404-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 17:19 +0800, Yang Yingliang wrote:
> If packets are dropped in enqueue(), it should not return
> NET_XMIT_SUCCESS but NET_XMIT_DROP.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  net/sched/sch_fq_codel.c | 2 +-
>  net/sched/sch_hhf.c      | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 0bf432c782c1..303ab0ce23ab 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -207,7 +207,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  
>  	/* As we dropped a packet, better let upper stack know this */
>  	qdisc_tree_decrease_qlen(sch, 1);
> -	return NET_XMIT_SUCCESS;
> +	return NET_XMIT_DROP;
>  }
>  
>  /* This is the specific function called from codel_dequeue()
> diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
> index 6aab8619bbb0..a13d1d78ded1 100644
> --- a/net/sched/sch_hhf.c
> +++ b/net/sched/sch_hhf.c
> @@ -426,7 +426,7 @@ static int hhf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  
>  	/* As we dropped a packet, better let upper stack know this. */
>  	qdisc_tree_decrease_qlen(sch, 1);
> -	return NET_XMIT_SUCCESS;
> +	return NET_XMIT_DROP;
>  }
>  
>  static struct sk_buff *hhf_dequeue(struct Qdisc *sch)

NACK

I am very tired of these patches.
