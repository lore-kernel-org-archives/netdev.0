From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Mon, 19 May 2003 18:37:43 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030519154852.I39024@shell.cyberus.ca>
References: <87d6iit4g7.fsf@deneb.enyo.de> <20030517.150933.74723581.davem@redhat.com>
 <87iss87gqd.fsf@deneb.enyo.de> <20030518.023151.77034834.davem@redhat.com>
 <20030519132819.S38814@shell.cyberus.ca> <Pine.LNX.4.51.0305191408490.1795@ns.istop.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0305191408490.1795@ns.istop.com>
List-Id: netdev.vger.kernel.org




Took Linux kernel off the cc list.

On Mon, 19 May 2003, Ralph Doncaster wrote:

> When I looked at the route-cache code, efficient wasn't the word the came
> to mind.  Whether the problem is in the route-cache or not, getting
> 100kpps out of a linux router with <= 1Ghz of CPU is not at all an easy
> task.  I've tried 2.2 and 2.4 (up to 2.4.20) with 3c905CX cards, with and
> without NAPI, on a 750Mhz AMD.  I've never reached 100kpps without
> userland (zebra) getting starved.  I've even tried the e1000 with 2.4.20,
> and it still doesn't cut it (about 50% better performance than the 3Com).
> This is always with a full routing table (~110K routes).
>

I just tested a small userland apps which does some pseudo routing in
userland. With NAPI i am able to do 148Kpps without it same hardware,
about 32Kpps.
I cant test beyond 148Kpps because thats the max pps a 100Mbps card can
do. The point i am making is i dont see the user space starvation.
Granted this is not the same thing you are testing.

> If I actually had the time to do the code, I'd try dumping the route-cache
> altogether and keep the forwarding table as an r-tree (probably 2 levels
> of 2048 entries since average prefix size is /22).  Frequently-used routes
> would lookup faster due to CPU cache hits.  I'd have all the crap for
> source-based routing ifdef'd out when firewalling is not compiled in.
>

I think theres definete benefit to flow/dst cache as is. Modern routing
really should not be just about destination address lookup. Thats whats
practical today (as opposed to the 80s). I agree that we should be
flexible enough to not enforce that everybody use the complexity of
looking up via 5 tuples and maintaining flows at that level - if the
cache lookup is the bottleneck. Theres a recent patch that made it into
2.5.69 which resolves (or so it seems - havent tried it myself) the
cache bucket distribution. This was a major problem before.
The second level issue is on cache misses how fast can you lookup.
So far we are saying "fast enough". Someone needs to prove it is not.


> My next try will be with FreeBSD, using device polling and the e1000 cards
> (since it seems there are no polling patches for the 3c905CX under
> FreeBSD).  From the description of how polling under FreeBSD works
> http://info.iet.unipi.it/~luigi/polling/
> vs NAPI under linux, polling sounds better due to the ability to configure
> the polling cycle and CPU load triggers.  From the testing and reading
> I've done so far, NAPI doesn't seem to kick in until after 75-80% CPU
> load.  With less than 25kpps coming into the box zebra seems to take
> almost 10x longer to bring up a session with full routes than it does with
> no packet load.  Since CPU load before zebra becomes active is 70-75%, it
> would seem a lot of cycles is being wasted on context switching when zebra
> gets busy.
>

Not interested in BSD. When they can beat Linuxs numbers i'll be
interested.

> If there is a way to get the routing performance I'm looking for in Linux,
> I'd really like to know.  I've been searching an asking for over a year
> now.  When I initially talked to Jamal about it, he told me NAPI was the
> answer.  It does help, but from my experience it's not the answer.  I get
> the impression nobody involved in the code has has tested under real-world
> conditions.  If that is, in fact, the problem then I can provide an ebgp
> multihop full feed and a synflood utility for stress testing.  If the
> linux routing and ethernet driver code is improved so I can handle 50kpps
> of inbound regular traffic, a 50kpps random-source DOS, and still have 50%
> CPU left for Zebra then Cisco might have something to worry about...
>

I think we could do 50Kpps in a DOS environment.
We live in the same city. I may be able to spare half a weekend day and
meet up with you for some testing.

cheers,
jamal
