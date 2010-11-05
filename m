From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ping -I eth1 ....
Date: Fri, 05 Nov 2010 14:36:46 +0100
Message-ID: <1288964206.2882.402.camel@edumazet-laptop>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56339 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab0KENgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 09:36:50 -0400
Received: by wwb39 with SMTP id 39so1410274wwb.1
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 06:36:49 -0700 (PDT)
In-Reply-To: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 14:14 +0100, Joakim Tjernlund a =C3=
=A9crit :
> If I do busybox ping -I eth1 x.x.y.y i see
> socket(PF_INET, SOCK_RAW, IPPROTO_ICMP) =3D 3
> getuid()                                =3D 0
> setuid(0)                               =3D 0
> setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, "eth1\0\0\0\0\0\0\0\0\0\0\=
0\0\20\0[l\0\0\0\2\20\7\354(\0"..., 32) =3D 0
> setsockopt(3, SOL_SOCKET, SO_BROADCAST, [1], 4) =3D 0
> setsockopt(3, SOL_SOCKET, SO_RCVBUF, [7280], 4) =3D 0
>=20
> ......
> then this in a loop:
> --- SIGALRM (Alarm clock) @ 0 (0) ---
> clock_gettime(CLOCK_MONOTONIC, {1238, 116470107}) =3D 0
> sendto(3, "\10\0\203\345\1\326\0\2I\314(v\0\0\0\0\0\0\0\0\0\0\0\0"...=
, 64, 0, {sa_family=3DAF_INET, sin_port=3Dhtons(0), sin_addr=3Dinet_add=
r("1.1.1.1")}, 16) =3D 64
> rt_sigaction(SIGALRM, {0x10017034, [ALRM], SA_RESTART}, {0x10017034, =
[ALRM], SA_RESTART}, 8) =3D 0
> alarm(1)                                =3D 0
> sigreturn()                             =3D ? (mask now [ILL ABRT FPE=
 KILL ALRM STKFLT CONT STOP TTOU URG XCPU XFSZ VTALRM PROF WINCH IO PWR=
 RTMIN])
> recvfrom(3, 0xbfe6a620, 192, 0, 0xbfe6a6f0, 0xbfe6a70c) =3D ? ERESTAR=
TSYS (To be restarted)
>=20
> Then I do ifconfig eth1 down
> and I still see the same. Should not
> sendto and/or revcfrom return some error as
> the interface is down?

Hmm, this reminds me one patch, yes...

Search for " ipv4: remove all rt cache entries on UNREGISTER event"

http://permalink.gmane.org/gmane.linux.network/173391

I guess I should respin it for net-next-2.6



