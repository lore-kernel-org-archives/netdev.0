From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Wed, 1 Dec 2004 16:24:33 +0100
Message-ID: <20041201152433.GA12558@xi.wantstofly.org>
References: <16807.20052.569125.686158@robur.slu.se> <1101484740.24742.213.camel@mellia.lipar.polito.it> <41A76085.7000105@draigBrady.com> <1101499285.1079.45.camel@jzny.localdomain> <16811.8052.678955.795327@robur.slu.se> <1101821501.1043.43.camel@jzny.localdomain> <20041130134600.GA31515@xi.wantstofly.org> <1101824754.1044.126.camel@jzny.localdomain> <20041201001107.GE4203@xi.wantstofly.org> <1101902900.1041.9.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1101902900.1041.9.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2004 at 07:08:20AM -0500, jamal wrote:

[ per-CPU TX/RX rings ]
> > You mean the management of qdiscs would be non-trivial?
> 
> I mean it is useful in only the most ideal cases and if you want to
> actually do something useful in most cases with it you will have to
> muck around.
> Take the case of forwarding (maybe with a little or almost no localhost
> generated traffic) - then you end allocating in CPUA, processing and
> queueing on egress. Tx softirq, which is what stashes the packet on tx
> DMA eventually, is not guaranteed to run on the same CPU. Now add a
> little latency between ingress and egress ..
> The ideal case is where you end up processing to completion from ingress
> to egress (which is known to happen in Linux when theres no congestion).

We disagreed on this topic at SUCON and I'm afraid we'll be disagreeing
on it forever :)  IMHO, on 10GbE any kind of qdisc is a waste of cycles.

I don't think it's very likely that you'll be using that single 10GbE NIC
for forwarding packets, doing that with a PC at this point in the history
of PCs is just silly.  If you do use it for forwarding, how likely is it
that you'll be able to process an incoming burst of packets fast enough
to require queueing on the egress interface?  You have to be able to send
a burst of packets bigger than the NIC's TX FIFO at >10GbE in the first
place for queueing to be effective/useful at all.

(Leaving the question of whether or not there'll be some room in the TX
FIFO at TX time unanswered, what you're doing with per-CPU TX rings is
basically just simulating the "N individual NICs each bound to its own
CPU" case with a single NIC.)


> > Probably the idea of these kinds of tricks is to skip the qdisc step
> > altogether.
> 
> Which is preached by the BSD folks - bogus in my opinion. If you want to
> do something as bland/boring as that you can probably afford a $500
> DLINK router which can do it at wire rate with (with cost you being
> locked in whatever features they have).

That's an unfair comparison.  Just because I don't need CBQ doesn't mean
my $500 DLINK router does everything I'd want it to -- advanced firewalling
is one thing that comes to mind.  Last time I looked I couldn't load my
own kernel modules on my DLINK router either.


--L
