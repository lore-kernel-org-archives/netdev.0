From: Harald Welte <laforge@netfilter.org>
Subject: Re: port-based filtering of ESP packets with in-kernel IPsec?
Date: Wed, 30 Jul 2003 17:16:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730151653.GB5161__28707.8524161645$1059581024@sunbeam.de.gnumonks.org>
References: <1059540296.16545.305.camel@k7.localnet> <20030730142411.GD4553@sunbeam.de.gnumonks.org> <1059576701.4586.20.camel@simulacron>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WYTEVAkct0FjGQmd"
Cc: netfilter-devel@lists.netfilter.org, netfilter@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Jellinghaus <aj@dungeon.inka.de>
Content-Disposition: inline
In-Reply-To: <1059576701.4586.20.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--WYTEVAkct0FjGQmd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 30, 2003 at 04:51:41PM +0200, Andreas Jellinghaus wrote:
=20
> [netfilter]
> incoming encrypted packets are seen as ESP/AH in INPUT
> and then as decrypted packet in INPUT or FORWARD.

ok, great.

> outgoing packets are only seen as ESP in OUTPUT.

this could be a problem.  I think there is quite a number of users who
want to impose packet filtering on outgoing locally-originated
packets... and obviously you want to do that at some time _before_ you
hide everything behind crypto..

> you can already filter incoming packets. The problem is you
> don't know if they came in that way they look now, or if they
> came in via ESP packets and got decrypted.
>=20
> maybe decryption/unencapsulating could leave a mark on the
> packet, so we know packets without that mark came in without
> ipsec and are bad / attempts to access resources without ipsec?
> (maybe fwmark works on that. or an explicit ipip tunnel, so you
> have "ipip0" or something as incoming interface).

This sounds a bit like the existing problem with bridgewalling.  They
also have no idea of where the packet originally came from (at least
before the physdev stuff was introduced as solution to this).

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--WYTEVAkct0FjGQmd
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/J+FlXaXGVTD0i/8RArRjAJ9fqF6G+ARS6eXqnPYBIDyuFftoXQCdH2vT
2xabS84rlPcSCPbOyNMpYNI=
=rQbl
-----END PGP SIGNATURE-----

--WYTEVAkct0FjGQmd--
