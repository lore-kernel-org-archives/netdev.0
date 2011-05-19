From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,
 PERCPU:  allocation failed
Date: Thu, 19 May 2011 09:44:31 +0200
Message-ID: <1305791071.3028.1.camel@edumazet-laptop>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
	 <1305787158.3019.12.camel@edumazet-laptop>
	 <1305788113.3019.19.camel@edumazet-laptop>
	 <10f61af229a48d77d06d154b4647cdde@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39944 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299Ab1ESHof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:44:35 -0400
Received: by wwa36 with SMTP id 36so2570870wwa.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 00:44:34 -0700 (PDT)
In-Reply-To: <10f61af229a48d77d06d154b4647cdde@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 10:28 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :
> On Thu, 19 May 2011 08:55:13 +0200, Eric Dumazet wrote:
> > Le jeudi 19 mai 2011 =C3=A0 08:39 +0200, Eric Dumazet a =C3=A9crit =
:
> >
> >> Its a known problem : When ipv6 is enabled, we allocate percpu=20
> >> memory to
> >> hold per device snmp counters.
> >>
> >> make sure kernel idea of max possible cpus matches real number of=20
> >> cpus.
> >>
> >> And yes, switching to 64bit kernel helps a lot.
> >>
> >>
> >
> > Looking at snmp6_alloc_dev(), we allocate three mib per device :
> >
> > ipstats_mib  (30 * sizeof(u64) * number_of_possible_cpus)
> > icmpv6_mib    (4 * sizeof(long) * number_of_possible_cpus)
> > icmpv6msg_mib  (26 * sizeof(long))
>  1920 +
>  256 +
>  208 =3D 2386 * 3000ppp's =3D 7152000, i think it is not that much at=
 any=20
>  case, if i am not wrong.
>=20
>  But at any case i will try 64bit.

If you really want to stay 32bit, you might try to enlarge vmalloc area=
d
(128 Mbytes default) to get room for pcpu data :

grep pcpu /proc/vmallocinfo=20


boot param : vmalloc=3D256M



