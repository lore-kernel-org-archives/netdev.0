From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 20:41:10 +0200
Message-ID: <1275504070.2519.12.camel@edumazet-laptop>
References: <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
	 <20100602.103102.121237521.davem@davemloft.net>
	 <1275500802.2519.7.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021255001.32431@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48376 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191Ab0FBSlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:41:15 -0400
Received: by wyi11 with SMTP id 11so2125441wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 11:41:14 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021255001.32431@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 13:01 -0500, Christoph Lameter a =C3=A9=
crit :
> On Wed, 2 Jun 2010, Eric Dumazet wrote:
>=20
> > Here is the patch I cooked to account for RP_FILTER errors in multi=
cast
> > path.
> >
> > I will complete it to also do the unicast part before official
> > submission.
> >
> > Christoph, the official counter would be IPSTATS_MIB_INNOROUTES
>=20
> Great. Thanks.
>=20
> > ipSystemStatsInNoRoutes OBJECT-TYPE
> >     SYNTAX     Counter32
> >     MAX-ACCESS read-only
> >     STATUS     current
> >     DESCRIPTION
> >            "The number of input IP datagrams discarded because no r=
oute
> >             could be found to transmit them to their destination.
>=20
> add "or because the rp_filter rejected the packet"? In the case of MC
> traffic you dont really need a route.
>=20

Unicast trafic dont need a reverse route, if you only receive packets.

rp_filter is an optional check, not covered by standard MIBS, so its
borderline.


> In my particular case it is a weird corner case for the rp_filter.
>=20
> Two NICs are on the same subnet. Different multicast groups are joine=
d
> on each (Using two NICs to balance the MC load since the drivers have
> some multicast limitations and having different interrupt lines for e=
ach
> NIC is also beneficial).
>=20

yeah, I know about this problem, and am working on it too...

> The rp_filter rejects all multicast traffic to the subscriptions on t=
he
> second NIC. I guess this is because the source address of the MC traf=
fic
> (on the same subnet) is also reachable via the first NIC.
>=20

Its clearly a case were rp_filter should be set to 2, dont you think ?

> So you could add also "because of breakage in the rp_filter (rp_filte=
r
> ignores the multicast subscription tables when determining the correc=
t
> reverse path of the packet)"
>=20

In standard RFC ? I wont change it :)


