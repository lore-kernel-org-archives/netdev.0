From: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for
	Bosch C_CAN controller
Date: Wed, 12 Jan 2011 00:05:39 +0100
Message-ID: <20110111230539.GC18762@pengutronix.de>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>
	<4D2829C5.5020206@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
	<4D2C14FE.7080903@grandegger.com> <4D2CA0AA.6080505@grandegger.com>
	<4D2CD34B.8000609@pengutronix.de>
	<20110111223843.GB18762@pengutronix.de>
	<4D2CDE49.3030302@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1794872639507732135=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2CDE49.3030302-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============1794872639507732135==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WfZ7S8PLGjBY9Voh"
Content-Disposition: inline


--WfZ7S8PLGjBY9Voh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> platform bus bindings. The question might be do we need the platform bus
> bindings or is it better to have AMBA bindings? The platform driver
> supports 16 and 32 bit attached devices, via IORESOURCE_MEM_{16,32}BIT.

platform_bus might be more generic. Depends on how many possibilities there
exist to connect the core to $something.

> Where do we have to look for the AMBA id registers?

I'll let the code speak (drivers/amba/bus.c):

	/*
	 * Read pid and cid based on size of resource
	 * they are located at end of region
	 */
	for (pid =3D 0, i =3D 0; i < 4; i++)
		pid |=3D (readl(tmp + size - 0x20 + 4 * i) & 255) <<
			(i * 8);
	for (cid =3D 0, i =3D 0; i < 4; i++)
		cid |=3D (readl(tmp + size - 0x10 + 4 * i) & 255) <<
			(i * 8);

	amba_put_disable_pclk(dev);

	if (cid =3D=3D AMBA_CID)
		dev->periphid =3D pid;

	if (!dev->periphid)
		ret =3D -ENODEV;

with AMBA_CID being (include/linux/amba/bus.h):

	#define AMBA_CID        0xb105f00d

periphid is used to match the driver to the device then. If done correctly,=
 it
should have been registered with ARM Ltd. before (AFAIK).

Good night,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--WfZ7S8PLGjBY9Voh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAk0s4kMACgkQD27XaX1/VRuU2ACeI/+dYYvezHfjWIFtPZBEMMtT
9tYAn0pSHDYVzQaeFiQSKsthvZ5kdnlo
=QlwG
-----END PGP SIGNATURE-----

--WfZ7S8PLGjBY9Voh--

--===============1794872639507732135==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============1794872639507732135==--
