From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in	RCU.
Date: Mon, 21 Jul 2008 11:17:16 +0800
Message-ID: <20080721031716.GA7535@gondor.apana.org.au>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au> <1216568119.4847.101.camel@localhost> <20080721001119.GA6515@gondor.apana.org.au> <1216607637.4847.172.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1216607637.4847.172.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 20, 2008 at 10:33:57PM -0400, jamal wrote:
> 
> True. 
> But note: this is only during rule creation - once you create the
> rule (user space to kernel path), then no more hash table reference.
> Fast path has already a filter with actions attached, and is a mere
> pointer dereference.

Unfortunately the scenario that I wrote this for requires frequent
addition/removal.

> > We could do a dynamic table but so far I'm not convinced that
> > it's worth anybody's effort to implement :)
> 
> If user<->kernel performance insertion/deletion is important, it is
> worth it.

Only if you also want to share it :) In the end I patched it to
not share it which is much easier.

> For example:
> Dave implemented dynamic hash tables on xfrm (voip setup time with ipsec
> is a metric used in the industry in that case) . The only operational
> problem i had with xfrm was lack of an upper bound of how large a table
> can grow; i would rather user space be told ENOMEM than continuing to
> grow in some cases (I actually implemented a patch which put a stop
> after a certain number of sad/spd - but i dont expect hugs if i was to
> post it;->).

Of course if you're volunteering to write the dynamic hash table
for actions then I'd happily switch back to sharing :)

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
