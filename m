From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Mon, 29 Nov 2010 19:01:58 +0100
Message-ID: <1291053718.3435.1275.camel@edumazet-laptop>
References: <1290672978.2798.151.camel@edumazet-laptop>
	 <AANLkTi=NTFXXY42nh+j3xM4n-NTPaz=fWKmAY=MpsHze@mail.gmail.com>
	 <1290694299.2858.330.camel@edumazet-laptop>
	 <20101129.094628.39176431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: socketpair@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37859 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275Ab0K2SCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 13:02:03 -0500
Received: by wwa36 with SMTP id 36so4996719wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 10:02:01 -0800 (PST)
In-Reply-To: <20101129.094628.39176431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 09:46 -0800, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 25 Nov 2010 15:11:39 +0100
>=20
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
> Ok, since such deep recursive AF_UNIX fd sends is pretty
> rediculious, it seems this is not likely to hit legitimate
> use cases and thus I've applied this.
>=20
> Also queued up for -stable.
>=20
> Thanks!

I tested FreeBSD (latest) and got a kernel freeze as well with exploit
program.

I dont know yet how to fully fix this problem.



