From: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Subject: Re: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 18:23:26 +0200
Message-ID: <20100413162326.GD16595@myhost.felk.cvut.cz>
References: <20100413093408.GA16595@myhost.felk.cvut.cz>
 <1271155163.16881.244.camel@edumazet-laptop>
 <20100413112726.GB16595@myhost.felk.cvut.cz>
 <1271161297.16881.293.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n/aVsWSeQ4JHkrmm"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.felk.cvut.cz ([147.32.80.7]:49423 "EHLO
	relay.felk.cvut.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab0DMQXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 12:23:39 -0400
Received: from labe.felk.cvut.cz (labe.felk.cvut.cz [147.32.85.34])
	by relay.felk.cvut.cz (8.14.3/8.14.3) with ESMTP id o3DGNQ0j092977
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 18:23:26 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Received: from [147.32.84.251] (mas16.felk.cvut.cz [147.32.84.166])
	by labe.felk.cvut.cz (8.13.8/8.13.8) with ESMTP id o3DGMmTx083184
	for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 18:22:48 +0200 (CEST)
	(envelope-from michal.svoboda@agents.felk.cvut.cz)
Content-Disposition: inline
In-Reply-To: <1271161297.16881.293.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--n/aVsWSeQ4JHkrmm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Eric Dumazet wrote:
> sock1 =3D socket(AF_INET, SOCK_DGRAM, 0);
> setsockopt(sock1, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
> addr.sin_addr.s_addr =3D htonl(0x7f000001);
> if (bind(sock1, (struct sockaddr *)&addr, sizeof(addr)))
> 	perror("bind1");
>=20
> sock2 =3D socket(AF_INET, SOCK_DGRAM, 0);
> setsockopt(sock2, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
> addr.sin_addr.s_addr =3D INADDR_ANY; /* or htonl(0x7f000001); */
> if (bind(sock2, (struct sockaddr *)&addr, sizeof(addr)))
> 	perror("bind2");
> }

Well, now if I send to 127.0.0.1, who gets the datagram? I guess sock2,
so it steals from sock1. What practical use does this have?

> Therefore, applications should not use REUSEADDR on unicast UDP, unless
> it is a non security issue (for example, if it is able to react to any
> new IP addresses added by the administrator on the machine, and complain
> loudly if another application could bind() before itself)

I don't think that in that case REUSEADDR would be useful because you
can already claim new addresses without it, either by binding a separate
socket to each IP or by binding to 0.0.0.0. Moreover the detection of
the "complain" case would be very tricky, at least on first sight.

> REUSADDR has a meaning for multicast, but for unicast... this is hardly
> useful ?

So would it be somehow possible to deliver the datagram to both sockets
(for example if they would be SO_BROADCAST as well)?


Michal Svoboda


--n/aVsWSeQ4JHkrmm
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvEmn4ACgkQg/fU9pp1uX4ouACgkQf96ZMr2T6XGeex5AT+v1Cr
gLEAnRR9grak+rVDmJ8c8WbBWmWu1dbd
=B+4c
-----END PGP SIGNATURE-----

--n/aVsWSeQ4JHkrmm--
