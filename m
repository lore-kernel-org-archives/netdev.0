From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sat, 25 Sep 2004 11:09:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925090933.GU3236@sunbeam.de.gnumonks.org>
References: <20040923225158.23c2d502.davem@davemloft.net> <20040924085234.GE3236@sunbeam.de.gnumonks.org> <20040924142702.62a2b23d.davem@davemloft.net> <20040925064406.GL3236@sunbeam.de.gnumonks.org> <20040925005623.2faf8faf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EVx8OOgYiG4KXJJB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--EVx8OOgYiG4KXJJB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 25, 2004 at 12:56:23AM -0700, David S. Miller wrote:
> > I'll inclue it in my next round of kernel builds and give it
> > some testing.
>=20
> Thanks.

Please note that I guess I won't have any results until late Sunday/Monday.

> 4) The controversial/RFC patch, dorking with neigh_forced_gc()
>=20
> So let's discuss #4.  It is the first idea I had to combat the
> "problem", but honestly right now I am beginning to think that
> the real solution is to simply remove the INCOMPLETE checks
> altogether.
>=20
> Neighbours are a sub-cache of the routing cache.  Therefore when
> a neigh entry has a singular refcount, no routing cache entry
> points to it.  No routing cache entry, we're not sending packets
> to that neighbour any time soon, so there is no reason (especially
> during strong pressure) to hold onto such entries.

I am sure this is valid for IPv4 and IPv6.  How about other users of the
neighbour cache, do they share this assumption?  I have to admit that I
never looked throgh the ATM or=20

> Agree or disagree?  Regardless, I'd be interested how effective
> your stress case is with patch #4 and my new suggestion which
> is just to remove the:

I'll do tests with and without INCOMPLETE check. No results until late
Sunday/Monday, as indicated above.

[yes, I noticed your corrected version of diff4]

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--EVx8OOgYiG4KXJJB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBVTXNXaXGVTD0i/8RAksRAJoCT+544hPST+3j1NZaU9tq8D+DyACgsIx7
cdoBmQZWQoLgWSF8pVT8Z04=
=3kz5
-----END PGP SIGNATURE-----

--EVx8OOgYiG4KXJJB--
