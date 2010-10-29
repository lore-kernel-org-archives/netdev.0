From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 29 Oct 2010 19:58:23 +0200
Message-ID: <4CCB0B3F.5050400@pengutronix.de>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de> <4CCAFA68.2030903@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7332687701049865776=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CCAFA68.2030903-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7332687701049865776==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD922065302406494E355EB6E"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD922065302406494E355EB6E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/29/2010 06:46 PM, Oliver Hartkopp wrote:
> Indeed the access to the data registers does not seem to be endian awar=
e.
>=20
> See in pch_can_rx_normal():
>=20
> +			cf->can_dlc =3D get_can_dlc((ioread32(&priv->regs->
> +						   if1_mcont)) & 0xF);
> +			*(u16 *)(cf->data + 0) =3D ioread16(&priv->regs->
> +							  if1_dataa1);
> +			*(u16 *)(cf->data + 2) =3D ioread16(&priv->regs->
> +							  if1_dataa2);
> +			*(u16 *)(cf->data + 4) =3D ioread16(&priv->regs->
> +							  if1_datab1);
> +			*(u16 *)(cf->data + 6) =3D ioread16(&priv->regs->
> +							  if1_datab2);
>=20
> See in pch_xmit():
>=20
> +	/* Copy data to register */
> +	if (cf->can_dlc > 0) {
> +		u32 data1 =3D *((u16 *)&cf->data[0]);
> +		iowrite32(data1, &priv->regs->if2_dataa1);
> +	}
> +	if (cf->can_dlc > 2) {
> +		u32 data1 =3D *((u16 *)&cf->data[2]);
> +		iowrite32(data1, &priv->regs->if2_dataa2);
> +	}
> +	if (cf->can_dlc > 4) {
> +		u32 data1 =3D *((u16 *)&cf->data[4]);
> +		iowrite32(data1, &priv->regs->if2_datab1);
> +	}
> +	if (cf->can_dlc > 6) {
> +		u32 data1 =3D *((u16 *)&cf->data[6]);
> +		iowrite32(data1, &priv->regs->if2_datab2);
> +	}
> +
>=20
> It's just a question if the driver for an Intel Chipset should/could ig=
nore
> the endian problematic.
>=20
> If this is intended the driver should only appear in Kconfig depending =
on X86
> or little endian systems.
>=20
> Besides this remark, the struct pch_can_regs could also be defined in a=
 way
> that every single CAN payload data byte could be accessed directly to a=
llow

That _should_ work on x86. On the contrary on ARM some registers in SOCs
allow only full 32 bit access.

> e.g. this code in pch_can_rx_normal():
>=20
> cf->data[0] =3D ioread8(&priv->regs->if1_data0);
> cf->data[1] =3D ioread8(&priv->regs->if1_data1);
> cf->data[2] =3D ioread8(&priv->regs->if1_data2);
> (..)
> cf->data[6] =3D ioread8(&priv->regs->if1_data6);
> cf->data[7] =3D ioread8(&priv->regs->if1_data7);

> This is easy to understand and additionally endian aware.

or use this, (as proposed in a earlier mail)

	for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
		reg =3D ioread32(&priv->regs->if1_data[i >> 1]);
		*(__be16 *)cf->data[i] =3D cpu_to_be16(reg);
	}

> In opposite to this:
>=20
> +	if (cf->can_dlc > 2) {
> +		u32 data1 =3D *((u16 *)&cf->data[2]);
> +		iowrite32(data1, &priv->regs->if2_dataa2);
> +	}
>=20
> Which puts a little? endian u16 into the big endian register layout.
> Sorry i'm just getting curious on this register access implementation.

According to the datasheet the layout is LE.

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigD922065302406494E355EB6E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzLCz8ACgkQjTAFq1RaXHNrIwCfS+PVtWTtKoyqU8gk4IVOdn2d
p/YAn3uHRtqZgZBU3N/SUNAYrySGvYro
=ft6v
-----END PGP SIGNATURE-----

--------------enigD922065302406494E355EB6E--

--===============7332687701049865776==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7332687701049865776==--
