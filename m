From: Ralph Doncaster <ralph@istop.com>
Subject: RE: Route cache performance under stress
Date: Mon, 9 Jun 2003 20:32:48 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
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
In-Reply-To: <20030609195652.E35696@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003, Jamal Hadi wrote:

> On Mon, 9 Jun 2003, CIT/Paul wrote:
>
> > NAPI despises SMP.. Any SMP box we run NAPI on has major packet loss
> > under high load.. So I find that the e1000 ITR works just as well
> > And there is no reason for NAPI at this point.
> >
>
> Foo, you on cheap crack again?
> Please just try the tests as described if you want to help. It doesnt help
> anyone when you wildly wave your hands like that.

>From personal experience, after trying numerous things for over a year one
can get very frustrated.  Although your contribution has been useful, you
are also guilty of wildly waving your hands around too.  Many moons ago
when I lamented that my 2.2.19 kernel, 750Mhz duron, 3c59x core router
performance sucked you told me NAPI would solve the performance problems.
It didn't.  And Rob's latest numbers seem to show that even with the
latest and greatest patches 148kpps is still a dream.  It's good to see
that people are finally doing tests to simulate real-world routing
(instead of just pretending the problem doesn't exist because they were
able to get 148kpps in some contrived test).

Here's my CPU graphs for the box; it's only doing routing and firewalling
isn't even built into the kernel (2.4.20 with 3c59x NAPI patches)
http://66.11.168.198/mrtg/tbgp/tbgp_usrsys.html

eth1 and eth2 are both sending and receiving ~30mbps of traffic (at
8-10kpps in and out on each interface).

The other variable that I haven't seen people discuss but have anecdotal
evidence will measurably impact performance is the motherboard used
(chipset and chipset configuration/timing).

Lastly from the software side Linux doesn't seem to have anything like
BSD's parameter to control user/system CPU sharing.  Once my CPU load
reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
100% and end up with my BGP sessions drop.

-Ralph
