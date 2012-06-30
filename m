From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next] e1000e: remove use of IP payload checksum
Date: Sat, 30 Jun 2012 22:36:36 +0100
Message-ID: <1341092196.4852.43.camel@deadeye.wl.decadent.org.uk>
References: <1341052528-2444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2sFW0jI20iWRwa0N4ZkX"
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38814 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751800Ab2F3Vgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 17:36:53 -0400
In-Reply-To: <1341052528-2444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2sFW0jI20iWRwa0N4ZkX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-06-30 at 03:35 -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
>=20
> Currently only used when packet split mode is enabled with jumbo frames,
> IP payload checksum (for fragmented UDP packets) is mutually exclusive wi=
th
> receive hashing offload since the hardware uses the same space in the
> receive descriptor for the hardware-provided packet checksum and the RSS
> hash, respectively.  Users currently must disable jumbos when receive
> hashing offload is enabled, or vice versa, because of this incompatibilit=
y.
> Since testing has shown that IP payload checksum does not provide any rea=
l
> benefit, just remove it so that there is no longer a choice between jumbo=
s
> or receive hashing offload but not both as done in other Intel GbE driver=
s
> (e.g. e1000, igb).
>=20
> Also, add a missing check for IP checksum error reported by the hardware;
> let the stack verify the checksum when this happens.
[...]

The change to enable RX hashing in 3.4, with this odd restriction seems
to have broken most existing systems using jumbo MTU on e1000e.  None of
the distro scripts or network management daemons will automatically
change offload configuration before MTU; how could they know?

Therefore this needs to be fixed in 3.5 and 3.4.y, not net-next.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-2sFW0jI20iWRwa0N4ZkX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT+9xZOe/yOyVhhEJAQozBQ//at3W8wGV5BlpWmWWhBOsHP1TvdtdPBNJ
V5mx/ORRd8hMjsmdEOwqA6QCzXEV9eRxVXRB6BRblpWPhbEFhIvBjO2UgcxYlPG+
u/OR/UYZlhS4OyYZhCGYSjYIGbjIlQ5KTA83LNro0AYWCf8GSJOswStSvq9IW1UU
oblKk1b/NwZ6CPV12A696kxGte7hNa6dgxhWytr6u4Oqgw6Snr84dVIpqkVgv+2e
o4vhPkCb4rUplmpF6ui5z4TJpP1har/xMk0NnCkQMBfNji1i45RBUL2GVZUCgpfL
Wl9BhB/3lf2q2L695VX5JkN2pdrN0LSK6R9aQEJ57k/bAz7D+GRqPik6XJihmm8Y
9WArnigXumv5v7xDNQlJgDCMQUzN66M1W58kGcD1taKIDB+rchhP/IrFQU5WD+i8
+Xhwyu75t/8poW7TXnX6/ek8Of8wLI2kOSRx1ZaDOb41lfaSrVdZAde/HpcifcNI
rhuOcu/iYVwS1dDlROfE0wzBPfvvZlqy/+QxueD51hS4fQ/IKkWlul4toubiXpTC
eM4okkAMp76H1x3kWdd60lkljbuAJWW/pQSbvLd4eCtubcCez/6tv4TzqqogB9A7
nK/vb+S+5iKokiAU+KbYVC/Uf3Tzsd2IC/VISZ9v41AS0O9/ceik0QpFsJKK3LoQ
L3r75YIQbbA=
=dRbr
-----END PGP SIGNATURE-----

--=-2sFW0jI20iWRwa0N4ZkX--
