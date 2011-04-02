From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 02 Apr 2011 20:10:48 +0200
Message-ID: <1301767848.2837.14.camel@edumazet-laptop>
References: <201104022001.48144.cyril.bonte@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>, Willy Tarreau <w@1wt.eu>
To: Cyril =?ISO-8859-1?Q?Bont=E9?= <cyril.bonte@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51794 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756217Ab1DBSKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 14:10:54 -0400
Received: by wya21 with SMTP id 21so3738344wya.19
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 11:10:53 -0700 (PDT)
In-Reply-To: <201104022001.48144.cyril.bonte@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 avril 2011 =C3=A0 20:01 +0200, Cyril Bont=C3=A9 a =C3=A9cr=
it :
> Hi All,
>=20
> (2nd try to fix the mailing list address)
>=20
> It has been reported that kernel 2.6.38 prevented the load balancer h=
aproxy to=20
> reload. After reading the kernel Changelog, it looks like the followi=
ng commit=20
> has a negative side effect on the the way haproxy "pauses" its listen=
ing=20
> sockets to start a new process :
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dc191a836a908d1dd6b40c503741f91b914de3348
>=20
> Disabling the TCPF_CLOSE flag condition reallows to work as before. I=
 guess=20
> this was done for good reasons (Sorry, I haven't found the thread abo=
ut that=20
> commit in the archives yet) but other applications may also be impact=
ed by=20
> this change.
>=20
> I add Willy Tarreau to the CC to open the discussion.
>=20

> 		if (shutdown(listenfd, SHUT_WR) =3D=3D 0 &&
> 		    listen(listenfd, 1024) =3D=3D 0 &&
> 		    shutdown(listenfd, SHUT_RD) =3D=3D 0) {
> 			printf("shutdown OK\n");
> 		}
> 	}
> 	exit(0);
> }
>=20

Wow, not clear what this is doing....=20

for sure the listen() call is not needed ?

And the shutdown(listenfd, SHUT_WR) is clearly useless too.

I feel you only needed the shutdown(listenfd, SHUT_RD) call.

Why haproxy needs to setup a second listening socket on same port ?


