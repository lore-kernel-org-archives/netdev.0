From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Wed, 08 Sep 2010 07:52:51 +0200
Message-ID: <1283925171.2634.838.camel@edumazet-laptop>
References: <1283895316.2634.248.camel@edumazet-laptop>
	 <4C86F653.6070707@hp.com> <1283921857.2634.747.camel@edumazet-laptop>
	 <20100907.223654.70187707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35987 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab0IHFw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 01:52:57 -0400
Received: by fxm16 with SMTP id 16so517372fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 22:52:56 -0700 (PDT)
In-Reply-To: <20100907.223654.70187707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 22:36 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 08 Sep 2010 06:57:37 +0200
>=20
> >    Document that connect() also sets local address, and that before
> > doing a second connect() to change remote address, its mandatory to
> > first issue a connect(AF_UNSPEC) to clear local address (if not loc=
ked
> > by a prior bind() call)
>=20
> For connectionless sockets, the application may connect() as many
> times as it wishes to change the remote address.  The local address
> remains set if it were set before such a re-associating connect().
>=20
> It need only issue a connect(AF_UNSPEC) to make the socket have no
> remote association, and as you state this operation will also wipe ou=
t
> any local address settings not created by a bind() call.
>=20
> And nicely our man pages are very clear about this :-) as is BSD and
> Steven's volume 2.
>=20
> This has been legal for decades, so we have to keep working this way.

Yes, its also buggy, if 2nd remote address is not reachable on same int=
erface.
Even if we try a connect(AF_UNSPEC), the local address stay as is :

after bind(port 5555) local addr=3D0x0:5555=20
after connect(123) local addr=3D0x7f000001:5555 remote addr=3D0x7f00000=
1:123=20
Could not connect, errno=3D22
after connect(AF_UNSPEC) local addr=3D0x7f000001:5555=20
connect: Invalid argument

I'll work on UDP fix anyway.


