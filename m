From: <robert@herjulf.net>
Subject: Re: [PATCH 1/2] pktgen: increasing transmission granularity
Date: Thu, 10 Jun 2010 17:44:42 +0200
Message-ID: <19473.2154.53423.374255@gargle.gargle.HOWL>
References: <4C064533.6070709@gmail.com>
	<20100609.135040.193710199.davem@davemloft.net>
	<4C10A603.2080402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@herjulf.net, jens.laas@its.uu.se
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from velox.its.uu.se ([130.238.7.74]:47118 "EHLO velox.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580Ab0FJPvF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 11:51:05 -0400
In-Reply-To: <4C10A603.2080402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




Thanks,

So the scheduling of the next transmission is based on the previous
transmission rather rather than now() + delay.


Cheers
				--ro



Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


>Daniel Turull wrote: This patch correct a bug in the delay of pktgen.
>It makes sure the inter-packet interval is accurate.
>
>Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>
>---
>diff --git a/net/core/pktgen.c b/net/core/pktgen.c index
>2ad68da..1dacd7b 100644 --- a/net/core/pktgen.c +++
>b/net/core/pktgen.c @@ -2170,7 +2170,7 @@ static void spin(struct
>pktgen_dev *pkt_dev, ktime_t spin_until)
> 	end_time = ktime_now();
> 
> 	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(end_time,
> start_time));
>-	pkt_dev->next_tx = ktime_add_ns(end_time, pkt_dev->delay);
>+	pkt_dev->next_tx = ktime_add_ns(spin_until, pkt_dev->delay);
> }
> 
> static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
