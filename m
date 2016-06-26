From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v7 2/2] ethtool: use netlink socket when AF_INET
 not available
Date: Sun, 26 Jun 2016 10:57:50 +0200
Message-ID: <1466931470.2504.27.camel@decadent.org.uk>
References: <1458922862-98024-1-git-send-email-ddecotig@gmail.com>
	 <1458922862-98024-3-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-20VECmLr+eM4PSsmDxGp"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55121 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751753AbcFZI6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 04:58:03 -0400
In-Reply-To: <1458922862-98024-3-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-20VECmLr+eM4PSsmDxGp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-25 at 09:21 -0700, David Decotigny wrote:

> From: David Decotigny <decot@googlers.com>
>=20
> To benefit from this, kernel commit 025c68186e07 ("netlink: add support
> for NIC driver ioctls") is needed.
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0configure.ac | 2 +-
> =C2=A0ethtool.c=C2=A0=C2=A0=C2=A0=C2=A0| 7 +++++++
> =C2=A02 files changed, 8 insertions(+), 1 deletion(-)
>=20
> diff --git a/configure.ac b/configure.ac
> index 3105415..47d2a0f 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -15,7 +15,7 @@ AM_PROG_CC_C_O
> =C2=A0dnl Checks for libraries.
> =C2=A0
> =C2=A0dnl Checks for header files.
> -AC_CHECK_HEADERS(sys/ioctl.h)
> +AC_CHECK_HEADERS(sys/ioctl.h linux/netlink.h)

This doesn't make a lot of sense. =C2=A0That header has been around since
Linux 2.1. =C2=A0But it didn't define NETLINK_GENERIC then.

(The test for <sys/ioctl.h> doesn't make sense either, as we include it
unconditionally!)

> =C2=A0dnl Checks for typedefs, structures, and compiler characteristics.
> =C2=A0AC_MSG_CHECKING([whether  defines big-endian types])
> diff --git a/ethtool.c b/ethtool.c
> index cb3d971..314b1b8 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -42,6 +42,9 @@
> =C2=A0#include=20
> =C2=A0
> =C2=A0#include=20
> +#ifdef HAVE_LINUX_NETLINK_H
> +# include=20
> +#endif
>=20

So what I've committed instead makes this unconditional, but adds a
conditional definition of NETLINK_GENERIC.

Ben.

> =C2=A0
> =C2=A0#ifndef MAX_ADDR_LEN
> =C2=A0#define MAX_ADDR_LEN	32
> @@ -4645,6 +4648,10 @@ opt_found:
> =C2=A0
> =C2=A0		/* Open control socket. */
> =C2=A0		ctx.fd =3D socket(AF_INET, SOCK_DGRAM, 0);
> +#ifdef HAVE_LINUX_NETLINK_H
> +		if (ctx.fd < 0)
> +			ctx.fd =3D socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
> +#endif
> =C2=A0		if (ctx.fd < 0) {
> =C2=A0			perror("Cannot get control socket");
> =C2=A0			return 70;
--=20

Ben Hutchings
compatible: Gracefully accepts erroneous data from any source

--=-20VECmLr+eM4PSsmDxGp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXb5kOAAoJEOe/yOyVhhEJ2SkQAI8yaMGlieUrc+2GYdX9cWR6
nxyO2libSx3MOVFCBOz8vvNXUEwb3US59iqUgkmu8/t9kxgOdCxpDu+c35oMNwxl
NnRvUt1VDsT8L9eNw0JHBSrab5RxtR5U0+kK8+V1dXSU+qpsXMBy+Q9eFDg0JuJF
lgG5qzApHa3CpjDEVoWnTgtMhBOD/p9UWKif7mM0gJ3sT/O+PJHlYgQaiiFkyemt
S9wQKmzg1fBMSc+vtATa8rlroQ8ElTXJFhjg4FdR2pFxaF0y0k0e3MQwFsj9tcEX
er0PYmE9jI2RMzBSUH9zw+6vudVG3pXO7wKiELQeIBXkF+y8dwBs1ow22UGiqb7T
RMbhKrkG5T3K7tCq3ggDAw6afhPU3KF5iYxpvStd8BNDptI9Xag1nbXx0virjyvn
B8jCIbZKMFvhAvvb89pxTlrA1Vzesr1e5u/Bgq82d5BDkNuGSu25zw7darnXqWgP
G/ZYUuUEs7V0HZuJzCXvrOghI6/VV6w6ApiQ8PCi/by6lITRAE0TEWcmXPyEko/D
iv1+RwTJXnmY0ko/b7C9EB5JLVui1GPL8fpviFXQfeN0BPAYfwx/OEvXAfT71mhT
mx/6vEgY5EWE0JjMJkPr5iEKsI7BSvqXeMlbGlyf0pAiDOlXfvNADEn/AE9MQNYa
QAH5bqvIQrXt01y8IBjN
=tFOT
-----END PGP SIGNATURE-----

--=-20VECmLr+eM4PSsmDxGp--
