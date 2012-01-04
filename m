From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible DoS with 6RD border relay
Date: Wed, 04 Jan 2012 18:53:20 +0100
Message-ID: <1325699600.2428.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <201201041048.44509.bcook@breakingpoint.com>
	 <201201041102.31205.bcook@breakingpoint.com>
	 <1325697931.2428.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <201201041135.54071.bcook@breakingpoint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Brent Cook <bcook@breakingpoint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40733 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab2ADRxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 12:53:24 -0500
Received: by wibhm6 with SMTP id hm6so10093156wib.19
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2012 09:53:23 -0800 (PST)
In-Reply-To: <201201041135.54071.bcook@breakingpoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 janvier 2012 =C3=A0 11:35 -0600, Brent Cook a =C3=A9crit=
 :
> On Wednesday, January 04, 2012 11:25:31 AM Eric Dumazet wrote:
> > Le mercredi 04 janvier 2012 =C3=A0 11:02 -0600, Brent Cook a =C3=A9=
crit :
> > > I forgot to mention, I'm testing 3.2 rc7:
> > >=20
> > > Linux target1 3.2.0-7-generic #13-Ubuntu SMP Sat Dec 24 18:06:57 =
UTC 2011
> > > x86_64 x86_64 x86_64 GNU/Linux
> > >=20
> > > but the same behavior occurs with 2.6.35
> >=20
> > Please check :
> >=20
> > grep . /proc/sys/net/ipv6/route/*
>=20
> /proc/sys/net/ipv6/route/gc_elasticity:9
> /proc/sys/net/ipv6/route/gc_interval:30
> /proc/sys/net/ipv6/route/gc_min_interval:0
> /proc/sys/net/ipv6/route/gc_min_interval_ms:500
> /proc/sys/net/ipv6/route/gc_thresh:1024
> /proc/sys/net/ipv6/route/gc_timeout:60
> /proc/sys/net/ipv6/route/max_size:4096
> /proc/sys/net/ipv6/route/min_adv_mss:1220
> /proc/sys/net/ipv6/route/mtu_expires:600
>=20
> This is a system with 8GB of ram.
>=20
> If I modify gc_thresh to be >=3D the number of bits the client varies=
, the=20
> system works OK:
>=20
> /proc/sys/net/ipv6/neigh/default/gc_thresh1:128
> /proc/sys/net/ipv6/neigh/default/gc_thresh2:512
> /proc/sys/net/ipv6/neigh/default/gc_thresh3:1024
>=20
> root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_thr=
esh1
> root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_thr=
esh2
> root@target1:~# echo 200000 > /proc/sys/net/ipv6/neigh/default/gc_thr=
esh3
>=20
> But it seems to be a losing battle since the client has a delegated p=
refix of=20
> /64.

I am not sure of this.

Try to change /proc/sys/net/ipv6/route/max_size

and /proc/sys/net/ipv6/route/gc_thresh

[To something larger than number of in flight packets on your gateway ]
