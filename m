From: Harald Welte <laforge@gnumonks.org>
Subject: Re: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Mon, 4 Apr 2005 07:26:42 +0200
Message-ID: <20050404052642.GE9155@sunbeam.de.gnumonks.org>
References: <20050402191132.GF1890@sunbeam.de.gnumonks.org> <16976.16774.728707.368646@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16976.16774.728707.368646@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Apr 03, 2005 at 09:18:30PM +0200, Robert Olsson wrote:

>  > I've tried to track the problem down, and I've confirmed that skb->use=
rs
>  > never goes down to 1 but instead stays at '2'.
>=20
>  > The same system with the same pktgen script works fine with 2.6.11.6.
>  >=20
>  > I'm reporting this since it seems like it sounds like we have a skb
>  > usage count leak somewhere :(
>=20
>  Sounds like a diff could give some clues. pktgen, e1000 and TX-path shou=
ld=20
>  be interesting as ev. changes in kernel config.

no changes in kernel config.  I've reviewed pktgen changes and couldn't
find something that would cause the problem.  It always only
atomic_inc'ed the ussage cound (and decrements only in error path) which
is perfectly fine.

As for e1000 and or generic TX path changes, I don't have the time to
review them now, sorry :(  That's why I posted it to netdev, to let
people who have an idea about the committed changes know that there is
an issue.

Cheers,
	Harald
--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCUNASXaXGVTD0i/8RAmJlAJ0am9/hoqAXladQcKHHELjDXiSCAwCgk6KQ
p4zfJVUew9dckCSBh1Fg84g=
=3nOl
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
