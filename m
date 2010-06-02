From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 18:28:08 +0200
Message-ID: <1275496088.2725.202.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>
	 <1275430054.2638.115.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021025200.30182@router.home>
	 <1275492754.2725.192.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021103410.30182@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64924 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729Ab0FBQ2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:28:13 -0400
Received: by wyi11 with SMTP id 11so2017800wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 09:28:12 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021103410.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 11:12 -0500, Christoph Lameter a =C3=A9=
crit :
> On Wed, 2 Jun 2010, Eric Dumazet wrote:
>=20
> > Le mercredi 02 juin 2010 =C3=A0 10:27 -0500, Christoph Lameter a =C3=
=A9crit :
> >
> > > Yes but they are not increment any counter. If packets are droppe=
d because
> > > of the rp_filter setting interfering f.e. then the packets vanish=
 without
> > > any accounting.
> > >
> >
> > But packets are vanishing either way.
>=20
> Its important to know why drops occur (any drops for that matter, dro=
ps
> mean retransmit which means latency). The symptom here was that
> multicast traffic on secondary interfaces was not being forwarded to =
the application.
> The rp_filter just dropped them and there was no way to easily track =
down
> the issue for the people experiencing the problem.
>=20

I just dont follow you.

Your patch has nothing to do with dropped packets because of rp_filter.=
=20

You inserted a counter increment in a path that is not taken at all by
packet delivery.

Maybe I missed something really obvious with your patch ?

It should only matters for the admin doing following command :

ip route get 1.2.3.4 from 192.168.0.1 iif eth0

That is a probe, not a 'packet delivery', this is why I said
incrementing an official MIB counter was probably wrong.

> In 2.6.31 the rp_filter was fixed to work properly with multicast and=
 now
> it considers multicast traffic to secondary interfaces to have the wr=
ong
> reverse path even though the multicast subscription occurred on the
> secondary interface. So it drops multicast traffic. The rp_filter has=
 to
> be switched off when using multiple NICs for multicast load balancing=
=2E
>=20

Have you considered CONFIG_NET_DROP_MONITOR ?
This one catches all possible cases, a developper doesnt have to patch
his kernel to add SNMP counters everywhere...

config NET_DROP_MONITOR
        boolean "Network packet drop alerting service"
        depends on INET && EXPERIMENTAL && TRACEPOINTS
        ---help---
        This feature provides an alerting service to userspace in the
        event that packets are discarded in the network stack.  Alerts
        are broadcast via netlink socket to any listening user space
        process.  If you don't need network drop alerts, or if you are =
ok
        just checking the various proc files and other utilities for
        drop statistics, say N here.


> > > LINUX_MIB_INROUTEERRORS? Does it mean I can create a series of ne=
w
> > > counters that allow us to diagnose and distinguish all the differ=
ent
> > > causes of packet loss? We would love to have that.
> > >
> >
> > For an example, you could take a look at commit 907cdda5205b
> > (tcp: Add SNMP counter for DEFER_ACCEPT)
>=20
> Well these are all TCP counters. I would add IP and UDP counters?

Why not ?

But as David said, it should be motivated by real use case ;)



