From: Brent Cook <bcook@breakingpoint.com>
Subject: Re: Possible DoS with 6RD border relay
Date: Wed, 4 Jan 2012 13:26:04 -0600
Message-ID: <201201041326.04403.bcook@breakingpoint.com>
References: <201201041048.44509.bcook@breakingpoint.com> <201201041135.54071.bcook@breakingpoint.com> <1325699600.2428.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:46040 "EHLO
	mail.breakingpoint.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab2ADT0L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:26:11 -0500
In-Reply-To: <1325699600.2428.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, January 04, 2012 11:53:20 AM Eric Dumazet wrote:
> Le mercredi 04 janvier 2012 =C3=A0 11:35 -0600, Brent Cook a =C3=A9cr=
it :
> > On Wednesday, January 04, 2012 11:25:31 AM Eric Dumazet wrote:
> > > Le mercredi 04 janvier 2012 =C3=A0 11:02 -0600, Brent Cook a =C3=A9=
crit :
> > > > I forgot to mention, I'm testing 3.2 rc7:
> > > >=20
> > > > Linux target1 3.2.0-7-generic #13-Ubuntu SMP Sat Dec 24 18:06:5=
7 UTC
> > > > 2011 x86_64 x86_64 x86_64 GNU/Linux
> > > >=20
> > > > but the same behavior occurs with 2.6.35
> > >=20
> > > Please check :
> > >=20
> > > grep . /proc/sys/net/ipv6/route/*
> >=20
> > /proc/sys/net/ipv6/route/gc_elasticity:9
> > /proc/sys/net/ipv6/route/gc_interval:30
> > /proc/sys/net/ipv6/route/gc_min_interval:0
> > /proc/sys/net/ipv6/route/gc_min_interval_ms:500
> > /proc/sys/net/ipv6/route/gc_thresh:1024
> > /proc/sys/net/ipv6/route/gc_timeout:60
> > /proc/sys/net/ipv6/route/max_size:4096
> > /proc/sys/net/ipv6/route/min_adv_mss:1220
> > /proc/sys/net/ipv6/route/mtu_expires:600
> >=20
> > This is a system with 8GB of ram.
> >=20
> > If I modify gc_thresh to be >=3D the number of bits the client vari=
es, the
> > system works OK:
> >=20
> > /proc/sys/net/ipv6/neigh/default/gc_thresh1:128
> > /proc/sys/net/ipv6/neigh/default/gc_thresh2:512
> > /proc/sys/net/ipv6/neigh/default/gc_thresh3:1024
> >=20
> > root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_t=
hresh1
> > root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_t=
hresh2
> > root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_t=
hresh3
> >=20
> > But it seems to be a losing battle since the client has a delegated
> > prefix of /64.
>=20
> I am not sure of this.
>=20
> Try to change /proc/sys/net/ipv6/route/max_size
>=20
> and /proc/sys/net/ipv6/route/gc_thresh
>=20
> [To something larger than number of in flight packets on your gateway=
 ]

Thanks for the suggestion, I tried 200k:

root@target1:~# echo 200000 > /proc/sys/net/ipv6/route/max_size=20
root@target1:~# echo 200000 > /proc/sys/net/ipv6/route/gc_thresh=20

It did not seem to improve the behavior - once neighbor table overflow =
hits,=20
things go downhill.  So far, only modifying the neighbor cache threshol=
d seems=20
to improve things.
