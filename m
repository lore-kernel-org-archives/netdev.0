From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command
 as non-root
Date: Mon, 17 Mar 2008 14:35:59 +0100
Message-ID: <47DE73BF.3050202@imap.cc>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>	 <47D98510.60801@imap.cc> <47D9A8DF.30809@fr.ibm.com>	 <47D9C1F0.6050803@imap.cc> <47DE4B7B.9040504@fr.ibm.com> <939d53060803170550r46a7e93ex31c166fff86bcf50@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBD4E4C6C302C4DD9D99DF62B"
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org
To: Benjamin Thery <ben.thery@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.phnxsoft.com ([195.227.45.4]:2810 "EHLO
	posthamster.phnxsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbYCQNgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 09:36:35 -0400
In-Reply-To: <939d53060803170550r46a7e93ex31c166fff86bcf50@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBD4E4C6C302C4DD9D99DF62B
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Benjamin Thery schrieb:
> While googling for the error string, I found this link which report
> the same kind of
> error when Postfix is used with grsecurity (in 2006):
>=20
> http://blog.jensthebrain.de/archives/2006/12/11/IPv6-Probleme-mit-Postf=
ix-und-grsecurity
>=20
> I barely understand German so I'm not sure it is related to your proble=
m.

The userspace failure described there is indeed the same as mine:
Postfix' sendmail command tries to open "/proc/net/if_inet6"
which fails with EACCES.

But I have never installed grsecurity on this machine, and the
problem appeared for me only with kernel 2.6.25-rc5-mm1, not when
running kernel 2.6.25-rc5 on the same machine, so I guess the
cause must be something different.

What's also strange is that I can "cat /proc/net/if_inet6" from
the command line as the same non-root user with no problem at all.
strace of "cat /proc/net/if_inet6" has:

open("/proc/net/if_inet6", O_RDONLY|O_LARGEFILE) =3D 3

strace of "/usr/sbin/sendmail", however:

open("/proc/net/if_inet6", O_RDONLY) =3D -1 EACCES (Permission denied)

Both run as

ts@xenon:~> id
uid=3D1000(ts) gid=3D100(users) groups=3D0(root),14(uucp),16(dialout),33(=
video),100(users),112(bacula)

HTH
T.

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enigBD4E4C6C302C4DD9D99DF62B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH3nO/Q3+did9BuFsRAhOsAJ9G/wD4GDJU+WiER81NXm0+9d8l2ACgigZ5
Nz+H3NZKTfD7Oize4qAnJBc=
=OZyI
-----END PGP SIGNATURE-----

--------------enigBD4E4C6C302C4DD9D99DF62B--
