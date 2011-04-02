From: Cyril =?utf-8?q?Bont=C3=A9?= <cyril.bonte@free.fr>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 2 Apr 2011 20:46:11 +0200
Message-ID: <201104022046.11701.cyril.bonte@free.fr>
References: <201104022001.48144.cyril.bonte@free.fr> <1301767848.2837.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>, Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:45097 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab1DBSqU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 14:46:20 -0400
In-Reply-To: <1301767848.2837.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 2 avril 2011 20:10:48, Eric Dumazet a =C3=A9crit :
> Le samedi 02 avril 2011 =C3=A0 20:01 +0200, Cyril Bont=C3=A9 a =C3=A9=
crit :
> (...)
> > > 		if (shutdown(listenfd, SHUT_WR) =3D=3D 0 &&
> > 	=09
> > 		    listen(listenfd, 1024) =3D=3D 0 &&
> > 		    shutdown(listenfd, SHUT_RD) =3D=3D 0) {
> > 		=09
> > 			printf("shutdown OK\n");
> > 	=09
> > 		}
> > =09
> > 	}
> > 	exit(0);
> >=20
> > }
>=20
> Wow, not clear what this is doing....
>=20
> for sure the listen() call is not needed ?
>=20
> And the shutdown(listenfd, SHUT_WR) is clearly useless too.

Well, I'm not the best one to explain that part but from what i read in=
 the=20
comments of this part of code, both listen and SHUT_WR are used to dete=
ct=20
errors on various OS (OpenBSD, Solaris, ...).

> I feel you only needed the shutdown(listenfd, SHUT_RD) call.
>=20
> Why haproxy needs to setup a second listening socket on same port ?

I simplified the test case, which is far from what haproxy do (just for=
got to=20
explain the real behaviour).
To reload the configuration, a new haproxy process is launched, sending=
 a=20
signal to the previous one and asking it to free the ports for a while =
(the=20
shutdown part in the test). The new process then tries to bind the port=
s,=20
which worked until 2.6.38 (if an error occurs, a new signal is sent to =
the=20
previous process to listen to its sockets again).

--=20
Cyril Bont=C3=A9
