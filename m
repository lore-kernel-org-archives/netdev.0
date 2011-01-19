From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Xen-devel] Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 19:48:19 +0000
Message-ID: <1295466499.11126.67.camel@bwh-desktop>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
	 <1295455216.11126.39.camel@bwh-desktop>
	 <1295459316.14981.3727.camel@zakaz.uk.xensource.com>
	 <1295460304.11126.53.camel@bwh-desktop> <4D3738AB.60701@goop.org>
	 <20110119192823.GN2754@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9283 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab1ASTsX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:48:23 -0500
In-Reply-To: <20110119192823.GN2754@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 21:28 +0200, Pasi K=C3=A4rkk=C3=A4inen wrote:
> On Wed, Jan 19, 2011 at 11:16:59AM -0800, Jeremy Fitzhardinge wrote:
> > On 01/19/2011 10:05 AM, Ben Hutchings wrote:
> > > Not in itself.  NAPI polling will run on the same CPU which sched=
uled it
> > > (so wherever the IRQ was initially handled).  If the protocol use=
d
> > > between netfront and netback doesn't support RSS then RPS
> > > <http://lwn.net/Articles/362339/> can be used to spread the RX wo=
rk
> > > across CPUs.
> >=20
> > There's only one irq per netback which is bound to one (V)CPU at a
> > time.  I guess we could extend it to have multiple irqs per netback=
 and
> > some way of distributing packet flows over them, but that would onl=
y
> > really make sense if there's a single interface with much more traf=
fic
> > than the others; otherwise the interrupts should be fairly well
> > distributed (assuming that the different netback irqs are routed to
> > different cpus).
> >=20
>=20
> Does "multiqueue" only work for NIC drivers (and frontend drivers),
> or could it be used also for netback?

Netfront and netback would have to agree on how many queues to use in
each direction.

> (afaik Linux multiqueue enables setting up multiple receive queues
> each having a separate irq.)

In the context of Linux networking, 'multiqueue' generally refers to us=
e
of multiple *transmit* queues.  The networking core handles scheduling
and locking of each transmit queue, so it had to be extended to support
multiple queues - initially done in 2.6.23, then made scalable in
2.6.27.

It was possible to use multiple receive queues per device long before
this since the networking core is not involved in locking them.  (Thoug=
h
it did require some hacks to create multiple NAPI contexts, before
2.6.24.)  This is mostly useful useful in conjunction with separate IRQ=
s
per RX queue, spread across multiple CPUs (sometimes referred to as
Receive Side Scaling or RSS).

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

