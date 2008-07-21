From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction
	in	RCU.
Date: Sun, 20 Jul 2008 22:33:57 -0400
Message-ID: <1216607637.4847.172.camel@localhost>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au>
	 <1216568119.4847.101.camel@localhost>
	 <20080721001119.GA6515@gondor.apana.org.au>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080721001119.GA6515-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-21-07 at 08:11 +0800, Herbert Xu wrote:

> This is exactly what I want to get rid of because otherwise even
> if no index was specified we'll still do a hash insertion which
> simply falls apart with a small hash table.  Using a large hash
> table on the other is bad for people who only have a few rules.

True. 
But note: this is only during rule creation - once you create the
rule (user space to kernel path), then no more hash table reference.
Fast path has already a filter with actions attached, and is a mere
pointer dereference.

> We could do a dynamic table but so far I'm not convinced that
> it's worth anybody's effort to implement :)

If user<->kernel performance insertion/deletion is important, it is
worth it.
For example:
Dave implemented dynamic hash tables on xfrm (voip setup time with ipsec
is a metric used in the industry in that case) . The only operational
problem i had with xfrm was lack of an upper bound of how large a table
can grow; i would rather user space be told ENOMEM than continuing to
grow in some cases (I actually implemented a patch which put a stop
after a certain number of sad/spd - but i dont expect hugs if i was to
post it;->).

cheers,
jamal

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
