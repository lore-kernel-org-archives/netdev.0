From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/4] Clean up intel driver page reuse Rx code
Date: Thu, 13 Nov 2014 08:49:34 -0800
Message-ID: <1415897374.2454.21.camel@jtkirshe-mobl>
References: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NQ9CYhlU+FilEybO7D7R"
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41040 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932245AbaKMQtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 11:49:49 -0500
In-Reply-To: <20141113161148.2790.22082.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NQ9CYhlU+FilEybO7D7R
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-11-13 at 08:18 -0800, Alexander Duyck wrote:
> This patch series cleans up the page reuse and Rx path so that all of the
> fixes that have been applied to any one driver are now in place for igb,
> fm10k, and ixgbe.  It occured to me that fm10k was missing the pfmemalloc
> bits, and ixgbe was missing some logic that reduced the number of writes
> needed as well as the pfmemalloc fix.
>=20
> In addition ixgbe was carrying around some mostly-dead code that was
> wrapping a call to writel.  I removed it since it masked the fact that
> ixgbe was missing the mmiowb it was supposed to have between the tail wri=
te
> and the Tx queue lock release to prevent the MMIO access from racing
> between CPUs.
>=20
> Also one change made to all 3 drivers is that we now only overwrite 3 of
> the 4 DWORDs in the Rx descriptor after allocation.  The last DWORD
> contains the upper 32 bits of the header address on fetch, and the length
> and vlan on writeback.  Since we are no longer using header split we don'=
t
> need to clear it prior to descriptor fetch as it is unused so we can save
> ourselves a cycle on 32b systems by just leaving it untouched.
>=20
> ---
>=20
> Alexander Duyck (4):
>       igb: Clean-up page reuse code
>       fm10k: Clean-up page reuse code
>       ixgbe: Clean-up page reuse code
>       ixgbe: Remove tail write abstraction and add missing barrier
>=20
>=20
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |   34 ++++---
>  drivers/net/ethernet/intel/igb/igb_main.c     |   35 +++----
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    5 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  118 ++++++++++++-------=
------
>  4 files changed, 89 insertions(+), 103 deletions(-)
>=20
> --

Thanks Alex, I will add your series to my queue.

--=-NQ9CYhlU+FilEybO7D7R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZOEeAAoJEOVv75VaS+3OkKAP/2X2M+unswtu93i6iw0Ek04W
QWlOKTubYEyixQdU4Er28j4nv+bLRgJeWPF8U0YtIZyJmPyOb4XcRvNRviVP4e3b
81K1hSoI6SoQpSdyG+Ku8RICrX0XCHGqRl46nABocoV1yRiE9DCE8EcUZK710Ay1
YLx8xq7WyvnUMEddMQdUttNmFp1x5dNkrRJrIK2NCp3Uc1Ui+ipc8XQQ1SnDfOjT
W9dqZ/Vzf5clTSvz/I66rSQ701zyDZN09mzROWa9bOqJ1MDodoewzvffjgfRb4Ns
Tetl7RN/K9w+eNdOsnoIpB6ePn4wsZCI59Pf8jDVWCpgv5SKKMFNcyCmXJtc9abe
mPWY9WV5yHZJU3SBYIOLjNwKfWqODo3kI+28c7Oq7hhjstqta0PlqVuFFS4NxcrB
S3Wp1qqF8X1ow80wi5/QGV3t74PvSpEyWeRKPQRpMYP0/ACrfbqODsLU4ql2Fol8
QOQhHB9StRgN8aRXpfF525ox9RGd8bBXyN3uthvB57EJZep3w4gWp4XPUpbR1M/C
iNLcw9chWCnZ2gdvlS/R4vVTFxfIq+vPNuqcDxcEwhNMRfBcZyAAaOJ2OSXNP09Y
On2Tf+MTRpWlZFqeyAszQsGQ//dB2LQBc1VsMU9KIjw0vZyMxsBY+LeIFXhbfyDE
ruelbjr5NCB9A5BwA55Q
=6EKA
-----END PGP SIGNATURE-----

--=-NQ9CYhlU+FilEybO7D7R--
