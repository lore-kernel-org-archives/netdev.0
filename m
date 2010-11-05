From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: ping -I eth1 ....
Date: Fri, 5 Nov 2010 15:57:28 +0100
Message-ID: <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org> <1288967665.2882.522.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:35092 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362Ab0KEO5c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 10:57:32 -0400
In-Reply-To: <1288967665.2882.522.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 15:34:25:
>
> Le vendredi 05 novembre 2010 =E0 10:25 -0400, Thomas Graf a =E9crit :
> > On Fri, Nov 05, 2010 at 03:01:57PM +0100, Joakim Tjernlund wrote:
> > > > > Then I do ifconfig eth1 down
> > > > > and I still see the same. Should not
> > > > > sendto and/or revcfrom return some error as
> > > > > the interface is down?
> > > >
> > > > Hmm, this reminds me one patch, yes...
> > > >
> > > > Search for " ipv4: remove all rt cache entries on UNREGISTER ev=
ent"
> > > >
> > > > http://permalink.gmane.org/gmane.linux.network/173391
> > >
> > > Ah, that does the trick. A few comments though:
> > >
> > > 1) I think you should include IFF_RUNNING too
> >
> > Probably even better to base it on the operational state of the lin=
k
> >
> > netif_running() && netif_oper_up() && netif_carrier_ok() && !netif_=
dormant()
>
> At this point we setup a route.

It fixes my problem too so it is not only about setting up routes.
The ping -I eth1 I did didn't even have an IP address on eth1

Perhaps there is a better place to test the interface status?
Especially as the RX path should be considered too.

>
> Is a change of any of this status going to flush/cancel a previously
> setup route ?
>
> There must be a reason why in many places we only test (dev->flags &
> IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to expo=
rt
> it at userspace)

Hopefully most of that is legacy or just plain wrong? Unless
someone can say why only test IFF_UP one should consider changing them.

