From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,
 PERCPU:  allocation failed
Date: Thu, 19 May 2011 08:55:13 +0200
Message-ID: <1305788113.3019.19.camel@edumazet-laptop>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
	 <1305787158.3019.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57804 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586Ab1ESGzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:55:18 -0400
Received: by wwa36 with SMTP id 36so2530519wwa.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 23:55:17 -0700 (PDT)
In-Reply-To: <1305787158.3019.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 08:39 +0200, Eric Dumazet a =C3=A9crit :

> Its a known problem : When ipv6 is enabled, we allocate percpu memory=
 to
> hold per device snmp counters.
>=20
> make sure kernel idea of max possible cpus matches real number of cpu=
s.
>=20
> And yes, switching to 64bit kernel helps a lot.
>=20
>=20

Looking at snmp6_alloc_dev(), we allocate three mib per device :

ipstats_mib  (30 * sizeof(u64) * number_of_possible_cpus)
icmpv6_mib    (4 * sizeof(long) * number_of_possible_cpus)
icmpv6msg_mib  (26 * sizeof(long))

=46or sure icmp ones dont need percpu counter. Plain atomic_long_t
(shared) would be enough, since ICMP messages are rare enough.



