From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Sun, 16 Jan 2011 23:35:40 +0100
Message-ID: <20110116223540.GA1861@del.dom.local>
References: <1295021808.3937.110.camel@edumazet-laptop>
 <20110114095201.4fc58a45@nehalam>
 <1295028502.3937.116.camel@edumazet-laptop>
 <20110114110342.4d95ad5b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49986 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1APWfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 17:35:47 -0500
Received: by fxm20 with SMTP id 20so5241237fxm.19
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 14:35:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110114110342.4d95ad5b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 14, 2011 at 11:03:42AM -0800, Stephen Hemminger wrote:
> From Eric Dumazet <eric.dumazet@gmail.com>
> 
> In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we fixed
> a problem with pfifo_head drops that incorrectly decreased
> sch->bstats.bytes and sch->bstats.packets
> 
> Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
> previously enqueued packet, and bstats cannot be changed, so
> bstats/rates are not accurate (over estimated)
> 
> This patch changes the qdisc_bstats updates to be done at dequeue() time
> instead of enqueue() time. bstats counters no longer account for dropped
> frames, and rates are more correct, since enqueue() bursts dont have
> effect on dequeue() rate.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> CC: Patrick McHardy <kaber@trash.net>
> CC: Jarek Poplawski <jarkao2@gmail.com>
> CC: jamal <hadi@cyberus.ca>
...
> --- a/net/sched/sch_drr.c	2011-01-14 09:19:00.830857886 -0800
> +++ b/net/sched/sch_drr.c	2011-01-14 09:28:20.398631228 -0800
> @@ -376,7 +376,6 @@ static int drr_enqueue(struct sk_buff *s
>  	}
>  
>  	bstats_update(&cl->bstats, skb);

Why leave leaf classes with different stats?

Jarek P.

> -	qdisc_bstats_update(sch, skb);
>  
>  	sch->q.qlen++;
>  	return err;
...
