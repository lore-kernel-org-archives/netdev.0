From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 10:35:53 -0700 (PDT)
Message-ID: <20080721.103553.121723118.davem@davemloft.net>
References: <1216606839.4847.159.camel@localhost>
	<E1KKu2D-0002kd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1KKu2D-0002kd-00-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Date: Mon, 21 Jul 2008 19:58:33 +0800

> I think I get you now.  You're suggesting that we essentially
> do what Dave has right now in the non-contending case, i.e.,
> bypassing the qdisc so we get fully parallel processing until
> one of the hardware queues seizes up.
> 
> At that point you'd stop all queues and make every packet go
> through the software qdisc to ensure ordering.  This continues
> until all queues have vacancies again.
> 
> If this is what you're suggesting, then I think that will offer
> pretty much the same behaviour as what we've got, while still
> offering at least some (perhaps even most, but that is debatable)
> of the benefits of multi-queue.
> 
> At this point I don't think this is something that we need right
> now, but it would be good to make sure that the architecture
> allows such a thing to be implemented in future.

Doing something like the noqueue_qdisc (bypassing the qdisc entirely)
is very attractive because it eliminates the qdisc lock.  We're only
left with the TX lock.

This whole idea of doing an optimized send to the device when the
TX queue has space is indeed tempting.

But we can't do it for qdiscs that measure rates, enforce limits, etc.

And if the device kicks back at us with an error, we have to
perform the normal ->enqueue() path.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
