From: Simon Holm =?ISO-8859-1?Q?Th=F8gersen?= <odie@cs.aau.dk>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Sat, 29 Aug 2009 09:05:59 +0200
Message-ID: <1251529559.30216.141.camel@odie>
References: <20090819145057.GA25400@sig21.net>
	 <20090819153534.GC30013@shareable.org> <20090820125649.GA29029@sig21.net>
	 <20090828144138.GB7375@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamie Lokier <jamie@shareable.org>, linux-embedded@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20090828144138.GB7375@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fre, 28 08 2009 kl. 16:41 +0200, skrev Johannes Stezenbach:
> On Thu, Aug 20, 2009 at 02:56:49PM +0200, Johannes Stezenbach wrote:
> > On Wed, Aug 19, 2009 at 04:35:34PM +0100, Jamie Lokier wrote:
> > > Johannes Stezenbach wrote:
> > > >=20
> > > >   TCP RX ~70Mbit/sec  (iperf -s on SoC, iperf -c on destop PC)
> > > >   TCP TX ~56Mbit/sec  (iperf -s on destop PC, iperf -c o SoC)
> > > >=20
> > > > The CPU load during the iperf test is around
> > > > 1% user, 44% system, 4% irq, 48% softirq, with 7500 irqs/sec.
> > > >=20
> > > > The kernel used in these measurements does not have iptables
> > > > support, I think packet filtering will slow it down noticably,
> > > > but I didn't actually try.  The ethernet driver uses NAPI,
> > > > but it doesn't seem to be a win judging from the irq/sec number=
=2E
> > >=20
> > > You should see far fewer interrupts if NAPI was working properly.
> > > Rather than NAPI not being a win, it looks like it's not active a=
t
> > > all.
> > >=20
> > > 7500/sec is close to the packet rate, for sending TCP with
> > > full-size ethernet packages over a 100Mbit ethernet link.
> >=20
> > From debug output I can see that NAPI works in principle, however
> > the timing seems to be such that ->poll() almost always completes
> > before the next packet is received.  I followed the NAPI_HOWTO.txt
> > which came with the 2.6.20 kernel.  The delay between irq ->
> > netif_rx_schedule() -> NET_RX_SOFTIRQ ->  ->poll()  doesn't seem
> > to be long enough.  But of course my understanding of NAPI is
> > very limited, probably I missed something...
>=20
> It would've been nice to get a comment on this.  Yeah I know,
> old kernel, non-mainline driver...

Tried porting the driver to mainline? That way you will get more than
two years of improvements to the networking stack including NAPI.

There was a rework of NAPI [1] around 2.6.24, you'd probably like to se=
e
commit bea3348eef27e6044b6161fd04c3152215f96411. You could also ask the
linux driver project to help you make the driver suitable for mainline
inclusion.

[1] http://lwn.net/Articles/244640/


Simon Holm Th=C3=B8gersen
