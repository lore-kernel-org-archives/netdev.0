From: Richard Laager <rlaager@wiktel.com>
Subject: Re: Fw: [Bug 82471] New: net/core/dev.c skb_war_bad_offload
Date: Wed, 31 Dec 2014 00:51:55 -0600
Message-ID: <1420008715.4687.79.camel@watermelon.coderich.net>
References: <1418805852.5277.25.camel@watermelon.coderich.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-uBdjkyzqGEfXZhlN61FH"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.wiktel.com ([69.89.207.152]:59085 "EHLO smtp2.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbaLaGv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 01:51:57 -0500
Received: from [10.10.10.44] (vpn.wiktel.com [69.89.205.192])
	(authenticated bits=0)
	by smtp2.wiktel.com (8.14.4/8.14.4/Debian-4.1ubuntu1) with ESMTP id sBV6ptJH023791
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 00:51:55 -0600
In-Reply-To: <1418805852.5277.25.camel@watermelon.coderich.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uBdjkyzqGEfXZhlN61FH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I was able to do some bisection using Ubuntu-packaged kernels.

The kernel from Precise (3.2.0-74.109) works (on a Trusty system).

On 3.5.0-51-generic (3.5.0-51.76) from Quantal, I get a different kind
of brokenness. I don't get a stack dump, but I get this kernel message
printed:
skbuff: bond0.7: received packets cannot be forwarded while LRO is enabled

The kernels from Raring (3.8.0-35.50) and Saucy (3.11.0-26.45) are
broken in the same way as Trusty.

Does that skbuff error message provide any clue? If not, it seems that
I'll have to bisect from working-on-3.2 to broken-on-3.5, then revert
that offending commit in each test as I bisect again from 3.5 to 3.8?

--=20
Richard

--=-uBdjkyzqGEfXZhlN61FH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABCAAGBQJUo50LAAoJEA/9MsdVF+JSueQH/i02rxvK3NIjVh2gPsQw7xiy
pUpn7XtuNZ0bqEbJdCjB+Vksa5RPNCnN8UTVAZzoZPn+nZcotisSsPpw18yLjl1X
kR6E4J/HAjEqxj2Ya2aGAZd5O2jsszyUCoEL1Cb3awwmz0uI2g/MINMspO8w8zm2
276h7i0vTF+DlhfVX6C6YXoeEK30yDcS9ji8Chr7EdpLIb5R4fRhxqa43atexZF/
fT9rYsVXwzRd+gpMT30JYd7S4h2nFWstJRLODD/Eqj/O4wuJZ23Zw5h00CIuukRW
tN289rsW5qLpdjDSbVjGrS+F/08YRfRNROkwI5SglKbVf/wnN0wtU68PzosY7hk=
=tUqV
-----END PGP SIGNATURE-----

--=-uBdjkyzqGEfXZhlN61FH--
