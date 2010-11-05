From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 16:45:25 +0100
Message-ID: <OF6BE4274E.3D881649-ONC12577D2.00564B05-C12577D2.00568E52@transmode.se>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se> <1288964206.2882.402.camel@edumazet-laptop> <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se> <20101105142510.GA14986@canuck.infradead.org> <1288967665.2882.522.camel@edumazet-laptop> <20101105145321.GB14986@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Thomas Graf <tgr@infradead.org>
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:56693 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab0KEPpa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 11:45:30 -0400
In-Reply-To: <20101105145321.GB14986@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgr@infradead.org> wrote on 2010/11/05 15:53:21:
>
> On Fri, Nov 05, 2010 at 03:34:25PM +0100, Eric Dumazet wrote:
> > Le vendredi 05 novembre 2010 =E0 10:25 -0400, Thomas Graf a =E9crit=
 :
> > > On Fri, Nov 05, 2010 at 03:01:57PM +0100, Joakim Tjernlund wrote:
> > > > 1) I think you should include IFF_RUNNING too
> > >
> > > Probably even better to base it on the operational state of the l=
ink
> > >
> > > netif_running() && netif_oper_up() && netif_carrier_ok() && !neti=
f_dormant()
> >
> > At this point we setup a route.
> >
> > Is a change of any of this status going to flush/cancel a previousl=
y
> > setup route ?
>
> No it won't.
>
> > There must be a reason why in many places we only test (dev->flags =
&
> > IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to ex=
port
> > it at userspace)
>
> The reason is that while the device is not operational we queue all
> packets in the qdisc and hope for the link to become operational in t=
he
> near future. This does make sense, especially if the link was once
> operational.

Hmm, perhaps one needs to treat user space differently from
internal kernel calls?

User space should always get an error if the link isn't functional.

