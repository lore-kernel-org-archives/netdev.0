From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Tue, 28 Sep 2010 20:35:52 +0300
Message-ID: <201009282035.53148.opurdila@ixiacom.com>
References: <4CA208C9.1020800@6wind.com> <1285691629.3154.80.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:31297 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754237Ab0I1RvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 13:51:12 -0400
In-Reply-To: <1285691629.3154.80.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tuesday 28 September 2010, 19:33:49

> Le mardi 28 septembre 2010 =E0 17:24 +0200, Nicolas Dichtel a =E9crit=
 :
> > Hi,
> >=20
> > I face a problem when I try to remove an interface,
> > netdev_wait_allrefs() complains about refcount.
> >=20
> > Here is a trivial scenario to reproduce the problem:
> > # ip tunnel add mode ipip remote 10.16.0.164 local 10.16.0.72 dev e=
th0
> > # ./a.out tunl1
> > # ip tunnel del tunl1
> >=20
> > Note: a.out binary create an IPv4 raw socket, attach it to tunl1
> > (SO_BINDTODEVICE), set it as multicast (IP_MULTICAST_LOOP), set the
> > multicast interface to tunl1 (IP_MULTICAST_IF), build the IP header
> > (IP_HDRINCL) and then send a single packet (192.168.6.1 -> 224.0.0.=
18).
> >=20
> > Note2: when a.out is executed, tunl1 has no ip address and is down.
>=20
> CC Octavian Purdila, the patch author.
>=20
> I am just wondering why this route is created in the first place.
>=20
> Maybe a fix would be to forbid this ?
>=20
> Some machines have a giant route cache, so its very important to avoi=
d
> expensive scans.
>=20
> > Then, I got a serie of "kernel:[1206699.728010] unregister_netdevic=
e:
> > waiting for tunl1 to become free. Usage count =3D 3" and after some=
 time,
> > interface is removed.
> >=20
> > The problem is that route cache entries are only invalidate on
> > UNREGISTER event, and not removed (introduced by commit
> > e2ce146848c81af2f6d42e67990191c284bf0c33). We must wait that
> > rt_check_expire() remove the remaining route cache entries.
> >=20
> > To fix the problem, I propose to remove a part of the previous comm=
it.
> >=20


Hi Nicolas,

The purpose of my original patch was to speed up interfaces deregistrat=
ion=20
even more after Eric's batch work. Reverting it might slow things down =
again,=20
but since this is breaking things we should probably revert it and thin=
k a=20
proper optimization afterward. I know that Eric B has done some more wo=
rk in=20
this area, for batch namespace cleanup, maybe the issue is not even the=
re=20
anymore.=20

So, Ack from me.

We might even fully revert the patch, since the bit that is left doesn'=
t have=20
any value anymore.

Thanks,
tavi
