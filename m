From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 14:46:52 +0200
Message-ID: <1285850812.2615.432.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
	 <1285796721.5211.156.camel@edumazet-laptop>
	 <20100930123048.GA4094@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930123048.GA4094@beaver.vrungel.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 septembre 2010 =C3=A0 16:30 +0400, Alexey Vlasov a =C3=A9cr=
it :
> On Wed, Sep 29, 2010 at 11:45:21PM +0200, Eric Dumazet wrote:
> > But if you send SYN packets in the same time, (logged), this might
> > slow
> > down the reception (and answers) of ICMP frames. LOG target can be
> > quite
> > expensive...
>=20
> Yes, it's clear that  some slow down can appear, but 100 ms is too mu=
ch,
> and this happens at 200 SYN packets in 2 minutes just as in my exampl=
e.
> On old servers where some tx/rx are missing in NIC card I don't see
> such a situation even at more then 1000 SYN-packets per sec.

Because all cpus were servicing interrupts, which was good for your
needs. Things apparently changed with 2.6.32.=20

You have a multiqueue NIC, but using a single CPU to handle the
workload.

>=20
> > Is using other rules gives same problem ?
> >
> > iptables -A OUTPUT -p tcp -m tcp --dport 80 --tcp-flags
>=20
> No, only LOG gives such a scheme.
>=20
