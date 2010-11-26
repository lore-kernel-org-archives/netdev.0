From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Fri, 26 Nov 2010 07:23:31 +0100
Message-ID: <1290752611.2678.3.camel@edumazet-laptop>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	 <1290666501.2798.84.camel@edumazet-laptop>
	 <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	 <1290668246.2798.93.camel@edumazet-laptop>
	 <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
	 <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
	 <1290672978.2798.151.camel@edumazet-laptop>
	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
	 <1290694299.2858.330.camel@edumazet-laptop>
	 <4CEF39AF.6090605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?=D0=9C=D0=B0=D1=80=D0=BA_?=
	 =?UTF-8?Q?=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3?=
	<socketpair@gmail.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45301 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab0KZGXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 01:23:38 -0500
Received: by wwa36 with SMTP id 36so1713829wwa.1
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 22:23:36 -0800 (PST)
In-Reply-To: <4CEF39AF.6090605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 novembre 2010 =C3=A0 12:38 +0800, Shan Wei a =C3=A9crit =
:
> Eric Dumazet wrote, at 11/25/2010 10:11 PM:
> > Le jeudi 25 novembre 2010 =C3=A0 13:35 +0500, =D0=9C=D0=B0=D1=80=D0=
=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit=
 :
> >> quick and dirty fix will be not to allow to pass unix socket insid=
e
> >> unix socket. I think it would not break much applications.
> >=20
> > Really, if it was not needed, net/unix/garbage.c would not exist at
> > all...
> >=20
> > It is needed by some apps.
> >=20
> >=20
> > [PATCH] af_unix: limit recursion level
> >=20
> > Its easy to eat all kernel memory and trigger NMI watchdog, using a=
n
> > exploit program that queues unix sockets on top of others.
> >=20
> > lkml ref : http://lkml.org/lkml/2010/11/25/8
> >=20
> > This mechanism is used in applications, one choice we have is to ha=
ve a
> > recursion limit.
> >=20
> > Other limits might be needed as well (if we queue other types of fi=
les),
> > since the passfd mechanism is currently limited by socket receive q=
ueue
> > sizes only.
> >=20
> > Add a recursion_level to unix socket, allowing up to 4 levels.
> >=20
> > Each time we send an unix socket through sendfd mechanism, we copy =
its
> > recursion level (plus one) to receiver. This recursion level is cle=
ared
> > when socket receive queue is emptied.
> >=20
> > Reported-by: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=
=D0=B1=D0=B5=D1=80=D0=B3 <socketpair@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This problem is same as that reported with title "Unix socket local D=
OS (OOM)", right?
> After applied this patch, this program can be killed now. but still e=
at 100% cpu.=20
>=20

Not the same problem, but a different one.=20

In this case, we queue files on top of another and never give a chance
to free them, unless the program dies (and full memory eaten)

And yes, its eating 100% cpu, since it has no sleep inside, like

for (;;) ;



