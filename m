From: Thomas Graf <tgraf@infradead.org>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 10:53:21 -0400
Message-ID: <20101105145321.GB14986@canuck.infradead.org>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
 <1288964206.2882.402.camel@edumazet-laptop>
 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
 <20101105142510.GA14986@canuck.infradead.org>
 <1288967665.2882.522.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:52066 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355Ab0KEOxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 10:53:22 -0400
Content-Disposition: inline
In-Reply-To: <1288967665.2882.522.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 05, 2010 at 03:34:25PM +0100, Eric Dumazet wrote:
> Le vendredi 05 novembre 2010 =E0 10:25 -0400, Thomas Graf a =E9crit :
> > On Fri, Nov 05, 2010 at 03:01:57PM +0100, Joakim Tjernlund wrote:
> > > 1) I think you should include IFF_RUNNING too
> >=20
> > Probably even better to base it on the operational state of the lin=
k
> >=20
> > netif_running() && netif_oper_up() && netif_carrier_ok() && !netif_=
dormant()
>=20
> At this point we setup a route.
>=20
> Is a change of any of this status going to flush/cancel a previously
> setup route ?

No it won't.=20

> There must be a reason why in many places we only test (dev->flags &
> IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to expo=
rt
> it at userspace)=20

The reason is that while the device is not operational we queue all
packets in the qdisc and hope for the link to become operational in the
near future. This does make sense, especially if the link was once
operational.

This case is special however, the interface is specified explicitely
and expectes to be notified immediately if that is not possible.
