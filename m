From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bugs/regressions: report in LKML or in bugzilla?
Date: Tue, 07 Dec 2010 17:12:01 +0100
Message-ID: <1291738321.2695.338.camel@edumazet-laptop>
References: <201012071639.58884.Martin@lichtvoll.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Martin Steigerwald <Martin@lichtvoll.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201012071639.58884.Martin@lichtvoll.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 07 d=C3=A9cembre 2010 =C3=A0 16:39 +0100, Martin Steigerwald a=
 =C3=A9crit :

> A participant of a linux performance training I hold found a bug with=
=20
> window scaling which did not receive any reply as well:
>=20
> Bug 20312 -  System freeze with multiples of 32 in=20
> /proc/sys/net/ipv4/tcp_adv_win_scale
> https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
>=20

User bug ?

Documentation/networking/ip-sysctl.txt

tcp_adv_win_scale - INTEGER
	Count buffering overhead as bytes/2^tcp_adv_win_scale=20
	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
	if it is <=3D 0.
	Default: 2

Given we use 32bit numbers, using values outside of [-31 ... 31] makes =
litle sense.

We could add sysctl range limit, but user should not mess with=20
/proc/sys/net/ipv4/parameters unless he knows what he is doing ?

Almost all /proc/sys/net/ipv4/parameters dont have range limits and une=
xpected
results with insane values feeded.

An other way to freeze a machine being root is :

halt
