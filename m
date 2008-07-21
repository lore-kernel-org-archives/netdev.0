From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in	RCU.
Date: Mon, 21 Jul 2008 19:58:33 +0800
Message-ID: <E1KKu2D-0002kd-00@gondolin.me.apana.org.au>
References: <1216606839.4847.159.camel@localhost>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1216606839.4847.159.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:
>
>> Otherwise, there is zero point in all of these TX multiqueue features
>> in the hardware if we can't parallelize things fully.
> 
> parallelization is achieveable in the ideal case.

I think I get you now.  You're suggesting that we essentially
do what Dave has right now in the non-contending case, i.e.,
bypassing the qdisc so we get fully parallel processing until
one of the hardware queues seizes up.

At that point you'd stop all queues and make every packet go
through the software qdisc to ensure ordering.  This continues
until all queues have vacancies again.

If this is what you're suggesting, then I think that will offer
pretty much the same behaviour as what we've got, while still
offering at least some (perhaps even most, but that is debatable)
of the benefits of multi-queue.

At this point I don't think this is something that we need right
now, but it would be good to make sure that the architecture
allows such a thing to be implemented in future.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
