From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] X25: Replace BKL in sockopts calls
Date: Mon, 10 May 2010 06:50:40 +0200
Message-ID: <1273467040.2325.78.camel@edumazet-laptop>
References: <1273409123.2727.387.camel@ibex>
	 <20100509.184658.170123822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew.hendry@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:35939 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621Ab0EJEuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 00:50:50 -0400
Received: by bwz19 with SMTP id 19so1523227bwz.21
        for <netdev@vger.kernel.org>; Sun, 09 May 2010 21:50:48 -0700 (PDT)
In-Reply-To: <20100509.184658.170123822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 mai 2010 =C3=A0 18:46 -0700, David Miller a =C3=A9crit :
> From: Andrew Hendry <andrew.hendry@gmail.com>
> Date: Sun, 09 May 2010 22:45:23 +1000
>=20
> > @@ -465,20 +464,20 @@ static int x25_setsockopt(struct socket *sock=
, int level, int optname,
> >  	if (get_user(opt, (int __user *)optval))
> >  		goto out;
> > =20
> > +	lock_sock(sk);
> >  	x25_sk(sk)->qbitincl =3D !!opt;
> > +	release_sock(sk);
>=20
> This is completely bogus.
>=20
> A store is always atomic on an SMP system, and "opt" is in a local va=
riable
> rather than being computed based upon some memory values.
>=20
> There is no reason to require locking for this operation.

Well, its probably better than lock_kernel() ;)

qbitincl is a char, I suspect some arches cant store a char in an atomi=
c
way ? Alpha comes to mind.


We now have lock_sock_bh()/unlock_sock_bh() for this kind of very short
sections, where we cant sleep.



