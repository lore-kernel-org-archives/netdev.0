From: Harald Welte <laforge@gnumonks.org>
Subject: pktgen problem (skb refcount) in 2.6.12-rc1
Date: Sat, 2 Apr 2005 21:11:32 +0200
Message-ID: <20050402191132.GF1890@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hK8Uo4Yp55NZU70L"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--hK8Uo4Yp55NZU70L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I've tried to get pktgen running on 2.6.12-rc1 (dual-opteron system, two
dual e1000 boards). =20

It transmits the requested amount of packets, but the kernel thread(s)
will continue to use 100% cpu even after that.

I've tried to track the problem down, and I've confirmed that skb->users
never goes down to 1 but instead stays at '2'.

Therefore the while loop at line 2706 loops forever.  Killing the kernel
thread or configuring the interface down helps (as a kludge).  However,
the e1000 module will refuse to unload since apparently it's still
referenced by that skb.

The system is otherwise idle, and no fancy modules such as
netfilter/iptables are loaded.

The same system with the same pktgen script works fine with 2.6.11.6.

I'm reporting this since it seems like it sounds like we have a skb
usage count leak somewhere :(

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--hK8Uo4Yp55NZU70L
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCTu5kXaXGVTD0i/8RAnFTAJ0Zx+raxRpD3NBQYYp0vIh8uxK7lgCdFuqS
cxrYExXXXuNnx4NAXVGfono=
=9ULo
-----END PGP SIGNATURE-----

--hK8Uo4Yp55NZU70L--
