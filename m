From: Tom Marshall <tmarshall@real.com>
Subject: Problem with dual IPv4/IPv6 connect
Date: Tue, 16 Nov 2004 15:24:09 -0800
Message-ID: <20041116232409.GB26264@real.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_flawless.real.com-2243-1100647466-0001-2"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_flawless.real.com-2243-1100647466-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm using kernel 2.6.9 from kernel.org and I think I found a small problem
in the dual IPv4/IPv6 connect code.  Here's what happens:

[Note both peer addresses are the same (Solaris 9) machine]

  s =3D socket(AF_INET6, SOCK_STREAM, 0)
  connect(s, [fec0::203:baff:fe88:5a15]:1554) =3D> EINPROGRESS
  Put socket in select's write set
  Kernel sends TCPv6 SYN
  Kernel receives ICMPv6 Time Exceeded (routing error)
  Socket becomes writable
  getsockopt(s, SO_ERROR) =3D> EHOSTUNREACH
  connect(s, 192.168.168.241:1554) =3D> ECONNABORTED

At this point, if I call connect again with the same arguments, it behaves
normally: EINPROGRESS followed by success.  This leads me to believe that
the IPv6 connect has not updated the socket state properly.

--=20
At Group L, Stoffel oversees six first-rate programmers, a managerial
challenge roughly comparable to herding cats.
        -- The Washington Post Magazine, 9 June, 1985

--=_flawless.real.com-2243-1100647466-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBmowZqznSmcYu2m8RAoyCAJ9MOc3p9NoYJJBYuKxxUlABADS7CACeMCKM
ieFyR4aMHo4ycGbMTEEWQDw=
=i9G2
-----END PGP SIGNATURE-----

--=_flawless.real.com-2243-1100647466-0001-2--
