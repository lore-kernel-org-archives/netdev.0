From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Sun, 27 Apr 2008 20:29:44 +0200
Message-ID: <4814C618.3050506@trash.net>
References: <20080427142216.GB7480@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64585 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758064AbYD0Sdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 14:33:49 -0400
In-Reply-To: <20080427142216.GB7480@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
>
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index a20e2ef..b4fd592 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -283,6 +283,9 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	sfq_index x;
>  	int ret;
>  
> +	if (unlikely(sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, 1)))
> +		return qdisc_drop(skb, sch);
> +
>   

I don't think we should do this. The tx_queue_len is only used for
initialization in case no parameter is specified by other qdiscs.

Besides this *will* break for example my configuration, I use SFQ
as inner qdisc on virtual devices with either tx_queue_len == 0
or 3 in case of ppp.

