From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Fri, 24 Sep 2004 10:52:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924085234.GE3236@sunbeam.de.gnumonks.org>
References: <20040923225158.23c2d502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DYCP9ZX4RRtQiwKl"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040923225158.23c2d502.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DYCP9ZX4RRtQiwKl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, I'm just reviewing your patches right now...

On Thu, Sep 23, 2004 at 10:51:58PM -0700, David S. Miller wrote:
>=20
> This makes all the neigh implementations use jenkins.

> --- a/net/core/neighbour.c	2004-09-23 22:27:14 -07:00
> +++ b/net/core/neighbour.c	2004-09-23 22:27:14 -07:00
> @@ -1316,6 +1317,8 @@
>  		panic("cannot allocate neighbour cache hashes");
> =20
>  	memset(tbl->phash_buckets, 0, phsize);
> +
> +	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
> =20
>  	tbl->lock	       =3D RW_LOCK_UNLOCKED;
>  	init_timer(&tbl->gc_timer);

So this means you put get_random_bytes into the __init function.  I
explicitly didn't want to do that (and added that _initted variable),
since at bootup time we might not have sufficient entropy yet.
This is before userspace has had time to reload the random seed saved
before shutdown, so especially on automatic-booting embedded devices
without any user interaction and never-changing flash layout (and thus
similar interrupt patterns) I think this is quite weak.

If we defer get_random_bytes() until the first neighbour is created,
this gives the system some more time to gather entropy... =20

That's the same reasoning we have for making the conntrack hash work
this way.

Also, wouldn't it make sense to use a new random value if we grow the
hash table?  I mean it's cheap, and we make it harder for someone trying
a hash-based attack. =20

Anyway, maybe I'm just being too paranoid.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--DYCP9ZX4RRtQiwKl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBU+BSXaXGVTD0i/8RAmdIAJ9zzU148nbYf84n/zIRMqcVa75VmwCgm/Dq
372FoysSSofPdz2TXOHH/co=
=vVbN
-----END PGP SIGNATURE-----

--DYCP9ZX4RRtQiwKl--
