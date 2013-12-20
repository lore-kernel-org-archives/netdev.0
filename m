From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Fri, 20 Dec 2013 15:49:04 -0800
Message-ID: <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:56190 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab3LTXtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 18:49:09 -0500
Received: by mail-yh0-f48.google.com with SMTP id f73so756497yha.21
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 15:49:07 -0800 (PST)
In-Reply-To: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 15:28 -0800, Cong Wang wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index c482fe8..7cc0d6a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3382,10 +3382,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
>  
>  	q = rxq->qdisc;
>  	if (q != &noop_qdisc) {
> -		spin_lock(qdisc_lock(q));
>  		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
>  			result = qdisc_enqueue_root(skb, q);
> -		spin_unlock(qdisc_lock(q));
>  	}
>  

Well... That would be too easy.

Really, a lot more work would be needed.

Qdisc ->enqueue()/dequeue()/reset()/... all assume the qdisc lock is
held.

John Fastabend did some work on this area.
