From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 07:38:44 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609072227.R34462@shell.cyberus.ca>
References: <000401c32e5e$a707b6d0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: CIT/Paul <xerox@foonet.net>
In-Reply-To: <000401c32e5e$a707b6d0$4a00000a@badass>
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, CIT/Paul wrote:

> I've got juno-z.101f.c to send 500,000 pps at 300+mbit on our dual p3
> 1.26 ghz routers.. I can't even send 50mbit of this though one of my
> routers
> Without it using 100% of both cpus because of the route cache.. It goes
> up to 500,000 entries if I let it and it adds 80,000 new entries per
> second and they are all cache misses.. I'd be glad to show you the setup
> sometime :) I showed it to jamal and we tested some stuff.
>

Yes, you have a nice setup and thats why you should test all the patches
DaveM is posting. Dave, Paul is running in a real ISP environment i think
he is very valuable in helping to test these patches and collect
any says that might be needed. Now watch him disapear ;->

BTW, re: BGP, someone should fix zebra to do batching if it doesnt do it
already (i saw that in one emails). In addition arp all
the nexthops right before installing the entries in the FIB. Repeat the
arp every X timeout. nexthops failinjg ARPs should be removed.
That should give you something close to what i think CEF was designed for
i.e when the packets get to us, part of the route is resolved already.

Additional thought Dave: i think prefetching the rth would help in 2.5
at least when you have lotsa collisions.
call prefetch(nextrth) right after smp_read_barrier_depends() everywhere
in route.c

cheers,
jamal

PS:- this is one of those fun times i wish i had a setup and time ;->

