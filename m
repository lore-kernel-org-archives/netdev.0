From: Ralph Doncaster <ralph@istop.com>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 22:45:29 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030609204257.L35799@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003, Jamal Hadi wrote:

> Problem is people disappear real quick when asked to run tests that
> could validate certain concepts. I wish everyone would emulate S Kirby
> he actually gives good info.

The test results Rob posted today show that the testing can be done in a
lab environment.  Most of the people I know that would actually see 50kpps
in the real world don't have the time to apply various patches and run a
bunch of tests; pretending the problem doesn't exist when someone doesn't
run tests to prove is a poor excuse.

> > Here's my CPU graphs for the box; it's only doing routing and firewalling
> > isn't even built into the kernel (2.4.20 with 3c59x NAPI patches)
> > http://66.11.168.198/mrtg/tbgp/tbgp_usrsys.html
> >
> > eth1 and eth2 are both sending and receiving ~30mbps of traffic (at
> > 8-10kpps in and out on each interface).
>
> Is this still the duron 750Mhz? Are you running zebra? Did you
> check out some of the ideas i talked about earlier?

Yup, still a duron 750 on an Asus mobo (Via chipset).  Running Zebra
0.93b.  If the ideas you're referring to are changing the zebra source to
arp the next-nops, then no, I haven't tried it (and am not likely to any
time soon).

> Robert has a good collection for what is good hardware. I am so outdated
> i dont keep track anymore. My fastest machine is still an ASuse dual
> 450Mhz.

There's still more dead-end suggestions than good ones (i.e. the
O'Reilley high performance routing book).

> > Lastly from the software side Linux doesn't seem to have anything like
> > BSD's parameter to control user/system CPU sharing.  Once my CPU load
> > reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
> > 100% and end up with my BGP sessions drop.
> >
>
> Well, heres a good example: With NAPI, have your sessions been dropped?
Yup, twice in the last 2 weeks.

> Have you tried a different NIC? Not sure how well the 3com is maintained
> for example.
> Try a tulip or tg3 or e1000 or the dlink gige.

Initially I was looking for tulip cards but almost nobody is producing
them any more.  Almost a year ago I came across the following list, which
is why I went with the 3com (at the time it indicated rx/tx irqmit for the
3com, until I emailed the author that I found out it was tx only)
http://www.fefe.de/linuxeth/

I had joined the vortex list last fall looking for some tips and that
didn't help much (other than telling me that the 3com wasn't the best
choice).  I've since bought a couple tg3 and a bunch of e1000 cards that
I'm planning to put into production.

Rob's test results seem to show that even if I replace my 3c905cx cards
with e1000's I'll still get killed with a 50kpps synflood with my current
CPU.  Upgrading to dual 2Ghz CPUs is not a preferred solution since I
can't do that in a 1U rack-mount box.  Yeah, I could probably do it with
water cooling, but that's not an option in a telco hotel like 151 Front
St. (Toronto).

A couple weeks ago I got one of my techs to test freeBSD/polling with full
routing tables on a 1Ghz celeron and 2 e1000 cards.  His testing seems to
suggest it will handle a 50kpps synflood DOS.  It would be nice if Linux
could do the same.

Despite the BSD bashing (to be expected on a Linux list, I guess), I will
be using BSD as well as Linux for core routing.  The plan is 1 linux
router and 1 bsd router each running zebra, connected to separate upstream
transit providers, running ibgp between them, and both advertising a
default route into OSPF.  Then if I get hit with a DOS that kills Linux,
the BSD box will have a much better chance of staying up than if I just
used a second Linux box for redundancy.  If the BSD boxes turn out to have
twice the performance of the linux boxes, it may be better for me to dump
linux for routing altogether. :-(

-Ralph
