From: Harald Welte <laforge@gnumonks.org>
Subject: Re: primary and secondary ip addresses
Date: Thu, 16 Dec 2004 10:28:32 +0100
Message-ID: <20041216092831.GO2862@sunbeam.de.gnumonks.org>
References: <41912F7A.6000408@redhat.com> <Pine.LNX.4.61.0411100034320.10593@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4NNqsQ/a67jpuySk"
Cc: Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0411100034320.10593@filer.marasystems.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--4NNqsQ/a67jpuySk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[Cc'ing netdev, since nobody replied since november]

On Wed, Nov 10, 2004 at 12:38:19AM +0100, Henrik Nordstrom wrote:
> On Tue, 9 Nov 2004, Neil Horman wrote:
>=20
> >Can anyone tell me why when removing a primary ip address from an=20
> >interface, all of its associated secondary ip addresses (those addresses=
=20
> >on the same subnet), are also removed?  Theres a comment in the kernel=
=20
> >thats pretty clear on the subject indicating it needs to be done, but I=
=20
> >don't quite grasp the reasoning behind why.
>=20
> A more valid question is why one can not add more than one primary in the=
=20
> same subnet.
>=20
> ip addr add x.x.x.x/y dev eth0 primary
>=20
> would make sense to me, clearly indicating that these addresses are=20
> maintained separately.

agreed.

> or put in another way why the addresses automatically become secondary=20
> addresses to the first added address.

=2E.. and why does removing the primary address remove all secondary
addresses.  This makes it complicated if you have one interface with
multiple ip addresse, that change over time (failover, let's say.)  You
don't know yet, which address you need to remove, because you don't know
which of your peers fails.=20

So you have all this complicated userspace magic that checks whether the
address that is about to be deleted is the primary, and if yes, re-add
all the other addresses.  If if is a secondary, you're happy and only
need to delete that one.

Can anyone comment what the idea of all this was?

Thanks.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--4NNqsQ/a67jpuySk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBwVU/XaXGVTD0i/8RAj5VAJ9UZR9hFLrDdh8AUjlT6069T4kW3QCghhCz
vdaKFJ7GWshT8AAwO6rpJSM=
=+ao0
-----END PGP SIGNATURE-----

--4NNqsQ/a67jpuySk--
