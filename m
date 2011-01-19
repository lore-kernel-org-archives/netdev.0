From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [Xen-devel] Re: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 21:58:39 +0200
Message-ID: <20110119195839.GO2754@reaktio.net>
References: <1295449318.14981.3484.camel@zakaz.uk.xensource.com> <1295455216.11126.39.camel@bwh-desktop> <1295459316.14981.3727.camel@zakaz.uk.xensource.com> <1295460304.11126.53.camel@bwh-desktop> <4D3738AB.60701@goop.org> <20110119192823.GN2754@reaktio.net> <1295466499.11126.67.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ian Campbell <Ian.Campbell@eu.citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.tele.fi ([192.89.123.25]:37150 "EHLO smtp.tele.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166Ab1AST6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 14:58:41 -0500
Content-Disposition: inline
In-Reply-To: <1295466499.11126.67.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 19, 2011 at 07:48:19PM +0000, Ben Hutchings wrote:
> On Wed, 2011-01-19 at 21:28 +0200, Pasi K=E4rkk=E4inen wrote:
> > On Wed, Jan 19, 2011 at 11:16:59AM -0800, Jeremy Fitzhardinge wrote=
:
> > > On 01/19/2011 10:05 AM, Ben Hutchings wrote:
> > > > Not in itself.  NAPI polling will run on the same CPU which sch=
eduled it
> > > > (so wherever the IRQ was initially handled).  If the protocol u=
sed
> > > > between netfront and netback doesn't support RSS then RPS
> > > > <http://lwn.net/Articles/362339/> can be used to spread the RX =
work
> > > > across CPUs.
> > >=20
> > > There's only one irq per netback which is bound to one (V)CPU at =
a
> > > time.  I guess we could extend it to have multiple irqs per netba=
ck and
> > > some way of distributing packet flows over them, but that would o=
nly
> > > really make sense if there's a single interface with much more tr=
affic
> > > than the others; otherwise the interrupts should be fairly well
> > > distributed (assuming that the different netback irqs are routed =
to
> > > different cpus).
> > >=20
> >=20
> > Does "multiqueue" only work for NIC drivers (and frontend drivers),
> > or could it be used also for netback?
>=20
> Netfront and netback would have to agree on how many queues to use in
> each direction.
>=20

Yep.

> > (afaik Linux multiqueue enables setting up multiple receive queues
> > each having a separate irq.)
>=20
> In the context of Linux networking, 'multiqueue' generally refers to =
use
> of multiple *transmit* queues.  The networking core handles schedulin=
g
> and locking of each transmit queue, so it had to be extended to suppo=
rt
> multiple queues - initially done in 2.6.23, then made scalable in
> 2.6.27.
>=20

Thanks for clearing that up.

> It was possible to use multiple receive queues per device long before
> this since the networking core is not involved in locking them.  (Tho=
ugh
> it did require some hacks to create multiple NAPI contexts, before
> 2.6.24.)  This is mostly useful useful in conjunction with separate I=
RQs
> per RX queue, spread across multiple CPUs (sometimes referred to as
> Receive Side Scaling or RSS).
>=20

Ok. I should read changelogs more closely.. I thought both the receive/=
transmit=20
multiqueue features appeared 'recently', but it seems I was wrong.

I think Linux 2.6.32 added multiqueue VLAN support..

-- Pasi

