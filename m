From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 18:53:12 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610015311.GB23009@netnation.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca> <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, CIT/Paul <xerox@foonet.net>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 08:32:48PM -0400, Ralph Doncaster wrote:

> Here's my CPU graphs for the box; it's only doing routing and firewalling
> isn't even built into the kernel (2.4.20 with 3c59x NAPI patches)
> http://66.11.168.198/mrtg/tbgp/tbgp_usrsys.html
> 
> eth1 and eth2 are both sending and receiving ~30mbps of traffic (at
> 8-10kpps in and out on each interface).

Interesting!  Your CPU use is quite a bit higher than ours.  It looks
like we have fairly similar network configurations.  We're advertising a
/24 and a /20 of which about 60% of the IPs are in use.  Each router
forwards about 60 Mbit/second (16 kpps) during the day, and the CPU load
is usually around 18-25%.  This is with a single CPU, though I
accidentally compiled the kernel SMP.

I had forgotten to add CPU utilization to the cricket graphs, so I'll
have a better idea from now on, but I've never seen it above 30% (from
"vmstat 1") except in attack cases.  The difference is probably just the
fact that this is running on slightly faster hardware (single Athlon
1800MP, Tyan Tiger MPX board).

> Lastly from the software side Linux doesn't seem to have anything like
> BSD's parameter to control user/system CPU sharing.  Once my CPU load
> reaches 70-80%, I'd rather have some dropped packets than let the CPU hit
> 100% and end up with my BGP sessions drop.

Hmm.  I found that once NAPI was happening, userspace seemed to get a
fairly decent amount of time.  I'm not exactly sure what the settings
are, but I was able to run things through SSH quite easily (not without
noticeable slowness, though).  Actually, the slowness appeared to be
mostly the result of incoming packet drops ("vmstat 1" output where it
was _sending_ data and getting the ACKs some time later was perfectly
smooth).

We just set up a dual Opertron box today with dual onboard Tigon3s, so
I'll see if I can do some profiling.  I hooked it via crossover to
a Xeon 2.4 GHz box with onboard e1000, so I should be able to do some
remote profiling tonight.

Simon-
