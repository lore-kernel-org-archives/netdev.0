From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH Round 4 2/3] Core network changes to support network event notification.
Date: Wed, 26 Jul 2006 13:39:51 +1000
Message-ID: <20060726033951.GB3203@gondor.apana.org.au>
References: <E1G5HW5-0005xn-00@gondolin.me.apana.org.au> <1153839940.14354.37.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rdreier@cisco.com, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:13065 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932513AbWGZDkF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 23:40:05 -0400
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1153839940.14354.37.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 10:05:40AM -0500, Steve Wise wrote:
> 
> But they really are seeing a delete followed by an add.  That's what the
> kernel is doing.

Actually that's the other thing I don't really like.  The user-space
monitor may perceive that a route was actually deleted and replaced
by a new one even though this isn't what's happening at all.

In fact the problem here is that you're sending route notifications
when it's really the dst_entry that's changing.  User-space as it
stands only get notifications about fib changes which is quite different
from changes to the transient dst_entry objects which only exist in the
route cache.

Is anyone actually going to use the user-space interface of this? If not
perhaps we should wait until someone really needs it before adding the
netlink part of the patch.

We can change the kernel interface at will so if we make a mistake with
netevent it can be easily corrected.  For user-space though the rules
are totally different.  I'd really hate to be stuck with an interface
which turns out to not be the one that people actually want to have.

> The rdma driver needs to update all established rdma connections that
> are using the next-hop information of the existing route and make them
> use the next-hop information of the new route.  In addition, the rdma
> driver might have a reference to the old dst entry.  So it can release
> that ref and add a ref to the new dst entry.

Do you really need the old route for the user-space part of your patch?

> I have to admit I'm a little fuzzy on the routing stuff.  The main
> netevents I've utilized in the the rdma driver I'm writing is the
> neighbour update event and the redirect event.  Route add/del was added
> for completeness of "routing" netevents.   

So you mean you aren't going to use the route notifications? In that case
we should probably just drop them and add them when someone actually needs
it.  At that point they can tell us what semantics they want from it :)

> Can you expand further or point me to code where the IP stack "flushes
> its tables" when routes are changed?

Grep for rt_cache_flush in net/ipv4/fib_hash.c.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
