From: Bastian Blank <waldi@debian.org>
Subject: [RFC] device types for s390 network devices
Date: Tue, 1 Feb 2005 09:21:39 +0100
Message-ID: <20050201082139.GB31992@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H1spWtNR+x+ondvy"
Cc: netdev@oss.sgi.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org, pavlic@de.ibm.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--H1spWtNR+x+ondvy
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The s390 network devices specifies device types which does not match the
reality.

ctc
=3D=3D=3D

This device is currently specified as ARPHRD_SLIP. If I see it
correctly, SLIP is an IP-only transport. ctc is more, the link level
header contains the ethernet protocoll type, so it is some sort of
pointopoint ethernet (which is sometimes crippled to IPv4-only for
compatiblity reasons).

qeth
=3D=3D=3D=3D

This device is currently specified as the corresponding real device
type if it is a real adapter, or ARPHRD_ETHER if it is a virtual one.
The virtual device behaves different in different modi:
- "layer2": In this mode, the device behaves like a real layer 2 device.
- "fake_ll": The kernel prepends a faked link level header.
- default: The kernel processes the IP-packages.  This is the most used
  mode, in whom it is impossible to use a standard libpcap as it parses
  the IP-headers as Ethernet. (IBM suggests to patch libpcap, but I
  think that changing the device type to something more matching is the
  correct solution.)

At least the last part needs some fix, but I don't know how to fix if
properly.

Bastian

--=20
The more complex the mind, the greater the need for the simplicity of play.
		-- Kirk, "Shore Leave", stardate 3025.8

--H1spWtNR+x+ondvy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iEYEARECAAYFAkH/PBMACgkQnw66O/MvCNF2kACfZfwLIsQfwOQN1FttPlez0RP1
1b4Ani15xbP7UoHepA/yvwXBP2a1Kxjy
=38zD
-----END PGP SIGNATURE-----

--H1spWtNR+x+ondvy--
