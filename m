From: jamal <hadi@cyberus.ca>
Subject: Re: [E1000-devel] Transmission limit
Date: 01 Dec 2004 07:08:20 -0500
Message-ID: <1101902900.1041.9.camel@jzny.localdomain>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
	 <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, P@draigBrady.com,
        mellia@prezzemolo.polito.it, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041201001107.GE4203@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-11-30 at 19:11, Lennert Buytenhek wrote:
> On Tue, Nov 30, 2004 at 09:25:54AM -0500, jamal wrote:
> 
> > > > >  Also from what I understand new HW and MSI can help in the case where
> > > > >  pass objects between CPU. Did I dream or did someone tell me that S2IO 
> > > > >  could have several TX ring that could via MSI be routed to proper cpu?
> > > > 
> > > > I am wondering if the per CPU tx/rx irqs are valuable at all. They sound
> > > > like more hell to maintain.
> > > 
> > > On the TX path you'd have qdiscs to deal with as well, no?
> > 
> > I think management of it would be non-trivial in SMP. Youd have to start
> > playing stupid loadbalancing tricks which would reduce the value of
> > existence of tx irqs to begin with. 
> 
> You mean the management of qdiscs would be non-trivial?

I mean it is useful in only the most ideal cases and if you want to
actually do something useful in most cases with it you will have to
muck around.
Take the case of forwarding (maybe with a little or almost no localhost
generated traffic) - then you end allocating in CPUA, processing and
queueing on egress. Tx softirq, which is what stashes the packet on tx
DMA eventually, is not guaranteed to run on the same CPU. Now add a
little latency between ingress and egress ..
The ideal case is where you end up processing to completion from ingress
to egress (which is known to happen in Linux when theres no congestion).
> Probably the idea of these kinds of tricks is to skip the qdisc step
> altogether.
> 

Which is preached by the BSD folks - bogus in my opinion. If you want to
do something as bland/boring as that you can probably afford a $500
DLINK router which can do it at wire rate with (with cost you being
locked in whatever features they have).

cheers,
jamal
