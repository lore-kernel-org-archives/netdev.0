From: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of entries.
Date: Thu, 8 Apr 2004 14:10:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <012201c41d94$cee1b400$0348858e@D4SF2B21>
References: <1IJuR-8qH-39@gated-at.bofh.it> <m3ptaiwfpq.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Andi Kleen" <ak@muc.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Why we need a routing cache?  A patricia tree or radix tree is not fast
enough with the kind of memory speed we have in PC technologies now???

The main goal to remove the routing cache is to avoid to have 4096 routes
limitation + all problem of the cache is not flush correclty when default
route/next-hop for a particular route are change in the middle of a TCP
connection and are not consider at all.  Also, when the routing cache is
finally flush, all the information about the PMTU of the other entries are
lost and must be rebuild.  So it's a lot of rebuilding of information for
nothing when you have a lot of peer to talk with.

It's may look like overkill for a home user, but for commercial server, 4k
routes can be really fast exhauted.  For us, we talking more about million
of routes in the system.  Also, the patch I provide exploit already the
plug/and/pray of the fib.  But doesn't give at all the flexibility to remove
the _unclean_ hack: the routing cache.

What is dirty form the current implementation, quick example spagetti code
with goto going back at the beginning of the function in route.c in IPV6.
All the mtu/pmtu put in the cache entries instead in the fib himself.  Just
to name few examples.

/mathieu

----- Original Message ----- 
From: "Andi Kleen" <ak@muc.de>
To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
Cc: <netdev@oss.sgi.com>; <linux-kernel@vger.kernel.org>
Sent: Thursday, April 08, 2004 1:18 PM
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of
entries.


> "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca> writes:
>
> [you should probably discuss that on netdev@oss.sgi.com instead, cc'ed]
>
> >     We currently looking for a multi-FIB, scalable routing table in the
> > million of entries, no routing cache for IPv4 and IPv6.  We want a IP
stack
>
> No routing cache? Doesn't sound like a good idea.
>
> > that can have a log(n) (or better) insertion/deletion and lookup
> > performance.  Predictable performance, even in the million of entries.
>
> And even more vast overkill for most linux users than the existing
> routing code already is.  Linux has at least the beginnings of a pluggable
> FIB interface (fib_table), which has slightly bit rotted, but probably
> not too bad. I would suggest you clean that up, make the existing
> hash table really optional and then you can just plug in anything you
want.
>
> >     I join a patch with the fib_hash in IPv4 replace with a patricia
tree
> > ready for multi-FIB base on a 2.4.22 kernel.  This is the beginning of a
> > long cleanup.
>
> What do you consider dirty in the current stack?
>
> -Andi
>
