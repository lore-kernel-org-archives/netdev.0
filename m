From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 09:53:30 -0700 (PDT)
Message-ID: <20080721.095330.213354230.davem@davemloft.net>
References: <20080720.194856.92564555.davem@davemloft.net>
	<20080720.221106.201055562.davem@davemloft.net>
	<alpine.LFD.1.10.0807210942310.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51804
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750784AbYGUQxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:53:30 -0400
In-Reply-To: <alpine.LFD.1.10.0807210942310.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 21 Jul 2008 09:49:49 -0700 (PDT)

> Why is it so unnecessarily fragile to begin with? Especially for stuff 
> that happens at bootup or suspend, doing a BUG_ON() is _particularly_ 
> painful, because a dead machine means that you cannot get any logs or 
> anything else.

I agree, the BUG_ON() was the wrong way to go.

> So wouldn't it be *much* better to do something like the appended, and at 
> least try to limp on, and maybe have a system that people can get logs 
> out of?

Agreed, I'll apply this.  Thanks.

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2eed17b..43ab4f5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1325,7 +1325,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  
>  void __netif_schedule(struct Qdisc *q)
>  {
> -	BUG_ON(q == &noop_qdisc);
> +	if (WARN_ON_ONCE(q == &noop_qdisc))
> +		return;
>  
>  	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
>  		struct softnet_data *sd;
> ---
