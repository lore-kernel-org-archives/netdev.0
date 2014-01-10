From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu, 09 Jan 2014 16:21:53 -0800
Message-ID: <1389313313.31367.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:34157 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbaAJAV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 19:21:58 -0500
Received: by mail-yh0-f49.google.com with SMTP id z20so1141381yhz.36
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 16:21:55 -0800 (PST)
In-Reply-To: <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-09 at 10:19 -0800, Cong Wang wrote:
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/core/dev.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ce01847..e357d05 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3376,10 +3376,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
>  
>  	q = rxq->qdisc;
>  	if (q != &noop_qdisc) {
> -		spin_lock(qdisc_lock(q));
>  		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
>  			result = qdisc_enqueue_root(skb, q);
> -		spin_unlock(qdisc_lock(q));
>  	}
>  
>  	return result;


Really, you'll have to explain in the changelog why you think this is
safe, because I really do not see how this can be valid.

I think I already said it was not safe at all...

You could try a multiqueue NIC for some interesting effects.
