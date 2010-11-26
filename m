From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100% reproductiblle,
 works under guest. no way to protect :(
Date: Fri, 26 Nov 2010 12:38:07 +0800
Message-ID: <4CEF39AF.6090605@cn.fujitsu.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>	 <1290666501.2798.84.camel@edumazet-laptop>	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>	 <1290668246.2798.93.camel@edumazet-laptop>	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>	 <1290672978.2798.151.camel@edumazet-laptop>	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com> <1290694299.2858.330.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52075 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab0KZEjy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 23:39:54 -0500
In-Reply-To: <1290694299.2858.330.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 11/25/2010 10:11 PM:
> Le jeudi 25 novembre 2010 =C3=A0 13:35 +0500, =D0=9C=D0=B0=D1=80=D0=BA=
 =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
>> quick and dirty fix will be not to allow to pass unix socket inside
>> unix socket. I think it would not break much applications.
>=20
> Really, if it was not needed, net/unix/garbage.c would not exist at
> all...
>=20
> It is needed by some apps.
>=20
>=20
> [PATCH] af_unix: limit recursion level
>=20
> Its easy to eat all kernel memory and trigger NMI watchdog, using an
> exploit program that queues unix sockets on top of others.
>=20
> lkml ref : http://lkml.org/lkml/2010/11/25/8
>=20
> This mechanism is used in applications, one choice we have is to have=
 a
> recursion limit.
>=20
> Other limits might be needed as well (if we queue other types of file=
s),
> since the passfd mechanism is currently limited by socket receive que=
ue
> sizes only.
>=20
> Add a recursion_level to unix socket, allowing up to 4 levels.
>=20
> Each time we send an unix socket through sendfd mechanism, we copy it=
s
> recursion level (plus one) to receiver. This recursion level is clear=
ed
> when socket receive queue is emptied.
>=20
> Reported-by: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=
=B1=D0=B5=D1=80=D0=B3 <socketpair@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This problem is same as that reported with title "Unix socket local DOS=
 (OOM)", right?
After applied this patch, this program can be killed now. but still eat=
 100% cpu.=20

--=20
Best Regards
-----
Shan Wei
