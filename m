From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ping -I eth1 ....
Date: Fri, 05 Nov 2010 15:34:25 +0100
Message-ID: <1288967665.2882.522.camel@edumazet-laptop>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63895 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab0KEOe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 10:34:29 -0400
Received: by eye27 with SMTP id 27so1714531eye.19
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 07:34:28 -0700 (PDT)
In-Reply-To: <20101105142510.GA14986@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 10:25 -0400, Thomas Graf a =C3=A9cr=
it :
> On Fri, Nov 05, 2010 at 03:01:57PM +0100, Joakim Tjernlund wrote:
> > > > Then I do ifconfig eth1 down
> > > > and I still see the same. Should not
> > > > sendto and/or revcfrom return some error as
> > > > the interface is down?
> > >
> > > Hmm, this reminds me one patch, yes...
> > >
> > > Search for " ipv4: remove all rt cache entries on UNREGISTER even=
t"
> > >
> > > http://permalink.gmane.org/gmane.linux.network/173391
> >=20
> > Ah, that does the trick. A few comments though:
> >=20
> > 1) I think you should include IFF_RUNNING too
>=20
> Probably even better to base it on the operational state of the link
>=20
> netif_running() && netif_oper_up() && netif_carrier_ok() && !netif_do=
rmant()

At this point we setup a route.

Is a change of any of this status going to flush/cancel a previously
setup route ?

There must be a reason why in many places we only test (dev->flags &
IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to export
it at userspace)=20




