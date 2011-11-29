From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next v4 0/4] can: cc770: add
 support for the Bosch CC770 and Intel AN82527
Date: Tue, 29 Nov 2011 11:47:20 +0100
Message-ID: <4ED4B838.2060307@pengutronix.de>
References: <1322557890-6363-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5122404338191456307=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Wolfgang Zarre <info-PyqsHJVlJN8AvxtiuMwx3w@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1322557890-6363-1-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-users>
List-Post: <mailto:socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-users>,
	<mailto:socketcan-users-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-users-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============5122404338191456307==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5A7E8CBB0F59D5C3C3EC6116"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5A7E8CBB0F59D5C3C3EC6116
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/29/2011 10:11 AM, Wolfgang Grandegger wrote:
> Already since a while we have support for the Bosch CC770 and Intel
> AN82527 CAN controllers in our out-of-tree Socket-CAN repository.
>=20
> In the meantime I found a TQM855L board with two AN82527 on it,
> which allowed me to provide and test a generic platform driver
> as well.
>=20
> Changes since v1:
>=20
> - remove version.h includes
> - some minor corrections in the ISA bus driver
> - add platform header file to the driver core
> - add generic platform driver
> - add and update device tree nodes for tqm8xx and tqm8548
>=20
> Changes since v2:
>=20
> - correct license text as suggest by Oliver Hartkopp
> - use the new module_platform_driver function
> - provide get_berr_counter callback for cc770
> - improve CAN error state change handling
> - more comprehensive cc770_isa driver description
>=20
> Changes since v3:
>=20
> - pre-define pr_fmt()
> - use KBUILD_MODNAME instead of DRV_NAME
> - use ARRAY_SIZE() whenever appropriate
> - use variable name "o" for message objects consistantly
> - use proper error code for cc770_probe_chip
> - remove unneeded member priv->open_time
> - remove unnecessary masking of u8 variables (with 0xff)
> - use "!skb" instead of "skb =3D=3D NULL"
> - CC770_MSG_MAX now limits the number of messages read in the ISR
> - use "|" instead of "+" to combine bit masks
> - remove return code check of platform_get_resource() in remove functio=
n
> - remove postal address from GPL copyright text
> - fix WARNING: __packed is preferred over __attribute__((packed))
> - some more minor fixes (casts, white space, etc.)

Feel free to add by Acked-by to patches 1 and 2.

Marc
>=20
> It would be nice if somebody else could test the driver, especially
> the ISA driver (I don't have hardware at hand).
>=20
> Wolfgang.
>=20
> Wolfgang Grandegger (4):
>   can: cc770: add driver core for the Bosch CC770 and Intel AN82527
>   can: cc770: add legacy ISA bus driver for the CC770 and AN82527
>   can: cc770: add platform bus driver for the CC770 and AN82527
>   powerpc: tqm8548/tqm8xx: add and update CAN device nodes
>=20
>  .../devicetree/bindings/net/can/cc770.txt          |   56 ++
>  arch/powerpc/boot/dts/tqm8548-bigflash.dts         |   19 +-
>  arch/powerpc/boot/dts/tqm8548.dts                  |   19 +-
>  arch/powerpc/boot/dts/tqm8xx.dts                   |   25 +
>  drivers/net/can/Kconfig                            |    2 +
>  drivers/net/can/Makefile                           |    1 +
>  drivers/net/can/cc770/Kconfig                      |   21 +
>  drivers/net/can/cc770/Makefile                     |    9 +
>  drivers/net/can/cc770/cc770.c                      |  881 ++++++++++++=
++++++++
>  drivers/net/can/cc770/cc770.h                      |  203 +++++
>  drivers/net/can/cc770/cc770_isa.c                  |  366 ++++++++
>  drivers/net/can/cc770/cc770_platform.c             |  273 ++++++
>  include/linux/can/platform/cc770.h                 |   33 +
>  13 files changed, 1898 insertions(+), 10 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/can/cc770.txt=

>  create mode 100644 drivers/net/can/cc770/Kconfig
>  create mode 100644 drivers/net/can/cc770/Makefile
>  create mode 100644 drivers/net/can/cc770/cc770.c
>  create mode 100644 drivers/net/can/cc770/cc770.h
>  create mode 100644 drivers/net/can/cc770/cc770_isa.c
>  create mode 100644 drivers/net/can/cc770/cc770_platform.c
>  create mode 100644 include/linux/can/platform/cc770.h
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig5A7E8CBB0F59D5C3C3EC6116
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7UuDgACgkQjTAFq1RaXHOGhQCbBWd+vXT22WwT/GT16P072cY6
3x0An0jnt5qPe+4uZha2RrT2JFdNB6KQ
=IXEz
-----END PGP SIGNATURE-----

--------------enig5A7E8CBB0F59D5C3C3EC6116--

--===============5122404338191456307==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-users mailing list
Socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-users

--===============5122404338191456307==--
