From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 21:34:53 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610043453.GC23009@netnation.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca> <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca> <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 11:18:45PM -0400, Ralph Doncaster wrote:

> What happened to Linux users being able to brag about how much they could
> do with CPUs that were useless for running Windows?  On a 1Ghz CPU you've
> got almost 7,000 cycles to route a packet in order to handle 148kpps.  I
> can't see why the slow path should be more than 2,000 cycles.

We're still here.  I want the code to be fast and efficient as much as
you do.  I'd be willing to bet that a lot of this will get fixed now,
though.  Broken parts of the code only get fixed if enough people whine
or especially if somebody decides to actually fix it.  My guess is that
the "using Linux as an Internet router with more than 10 Mbit/sec of
bandwidth" user base is relatively small.

> I know some people's attitude is don't talk if you're not going to write
> the code.  If I had the time I would; from my earliest days of programming
> I've been optimizing performance to the maximum.  I can still remember
> using page 0 on my c64 to store an 8-bit register in 3 cycles instead of
> four...

I wrote an entire game in TASM once. :)

> So to put a stake in the ground, I'd like to see a 1Ghz celeron with e1000
> cards handle 148kpps of DOS traffic at <50% CPU utilization (with full
> routing tables & no firewalling).

Sounds reasonable.  The routing table size issue has now been eliminated,
so that should make no difference to the equation.

> If that's not a reasonable expectation, someone please let me know. 
> Even if my time was only worth $500/day, in the past year and a half I
> spent enough time working on Linux routers to buy a Cisco NPE-G1. :-(

But in the end you'll end up with a system that you'll know the inner
workings of and that will be open source, maintainable, scalable, easy to
replicate, and easy to upgrade.  And it'll have tcpdump, damn it. :)

On Mon, Jun 09, 2003 at 10:45:29PM -0400, Ralph Doncaster wrote:

> A couple weeks ago I got one of my techs to test freeBSD/polling with full
> routing tables on a 1Ghz celeron and 2 e1000 cards.  His testing seems to
> suggest it will handle a 50kpps synflood DOS.  It would be nice if Linux
> could do the same.

I was going to ask before, and it's probably not even possible anymore,
but have you tried on a 2.0 kernel before?  2.0 kernels probably have a
lot of other problems and don't support the new hardware, but it would be
interesting to see how it scales to many srcs/dsts before the route cache
was integrated.  It probably scales a lot more like FreeBSD does.  You'd
probably have to use eepro100s or something, though.

> Despite the BSD bashing (to be expected on a Linux list, I guess), I will
> be using BSD as well as Linux for core routing.  The plan is 1 linux
> router and 1 bsd router each running zebra, connected to separate upstream
> transit providers, running ibgp between them, and both advertising a
> default route into OSPF.  Then if I get hit with a DOS that kills Linux,
> the BSD box will have a much better chance of staying up than if I just
> used a second Linux box for redundancy.

Good idea.  Others have also suggested using Zebra on one and another of
the BGP routing daemons on another to avoid routing-daemon-specific DoS
issues (or accidental remote crash bugs).

Anyway, the performance issues should be fixable.  It is going to take
some work, but there seem to be some interested people.  I'm going to try
to set up something that will allow for easy comparisons of patches so
that we can measure progress, and perhaps reach an eventual goal.

Simon-
