From: Harald Welte <laforge@gnumonks.org>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Wed, 4 Feb 2004 10:22:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204092250.GX25175@obroa-skai.de.gnumonks.org>
References: <Pine.LNX.4.58.0402020937030.4127@sorbus2.navaho> <Pine.LNX.4.33.0402021121540.6508-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9a9Vq1BJdYBEXpLG"
Cc: Steve Hill <steve@navaho.co.uk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0402021121540.6508-100000@blackhole.kfki.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--9a9Vq1BJdYBEXpLG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 02, 2004 at 11:34:22AM +0100, Jozsef Kadlecsik wrote:
> On Mon, 2 Feb 2004, Steve Hill wrote:
>=20
> > > init_conntrack is called only when we have full, non-fragmented
> > > packets: ip_conntrack_in explicitly calls the proper function to gath=
er
> > > the fragments before calling init_conntrack. There is no memory leak
> > > there.
> >
> > >From my observations, init_conntrack() is being called for each packet
> > (not fragment, packet), which seems right.
>=20
> No, that's not true (and would be bad). Please check the code.

To be more precise:

It is called for every NEW packet, after defragmentation happens (i.e.
if ip_conntrack_find_get() returns NULL, meaning there is no entry in
the hash table.).

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--9a9Vq1BJdYBEXpLG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAILnqXaXGVTD0i/8RAgCeAJ4zIlZw8RfbIvpl1Y5KmeNeWh7KRACeNIuI
PxR5xYI/t4THVqUnFztjmCs=
=SCr9
-----END PGP SIGNATURE-----

--9a9Vq1BJdYBEXpLG--
