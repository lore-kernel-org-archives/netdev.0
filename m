From: Harald Welte <laforge@gnumonks.org>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Wed, 4 Feb 2004 10:20:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040204092037.GW25175@obroa-skai.de.gnumonks.org>
References: <Pine.LNX.4.33.0402021121540.6508-100000@blackhole.kfki.hu> <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NgG1H2o5aFKkgPy/"
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0402021039540.5347@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NgG1H2o5aFKkgPy/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 02, 2004 at 10:48:08AM +0000, Steve Hill wrote:

> If fragmented packets do not lead to conntrack entries, how are their=20
> connections tracked?  I was under the impression that fragmented packets=
=20
> were received by one NIC, defragged, pushed through all the netfilter cod=
e=20
> and then transmitted by another NIC (after being fragmented again if they=
=20
> are > MTU size)?

Yes, this is indeed the case.  Whihc is not a contradiction to what
Jozsef said.  They are defragmented before getting passed to conntrack,
and thus look exactly the same like unfragmented packets throughout the
network stack (until NF_IP_POST_ROUTING).

> Machines 1 and 3 are running the 2.4 kernel for me, but that shouldn't be=
=20
> important.
> Machine 2 is running 2.6.2rc2.
> I am making > MTU sized pings from machine 1 to machine 3 and machine 2 i=
s=20
> showing the leak.

Are you running any netfilter / networking related patches?  Anything
else special about the setup?

> - Steve Hill
> Senior Software Developer                        Email: steve@navaho.co.uk

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--NgG1H2o5aFKkgPy/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAILllXaXGVTD0i/8RAn6DAJ48WL3Ieh9oU/HEtUppQT8SmDA0iQCgli9R
NRjxIGqWbQ4icAqaOqCtR7c=
=Pbe+
-----END PGP SIGNATURE-----

--NgG1H2o5aFKkgPy/--
