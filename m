From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 10:31:24 +0100
Message-ID: <4F0D56EC.5080704@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com> <4F0C31F1.20908@essax.com> <4F0C4EA8.7060002@grandegger.com> <4F0C63C6.5080305@essax.com> <4F0C661F.6030508@grandegger.com> <4F0C8B4B.8070104@essax.com> <4F0D50EA.6080900@essax.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig73358637B3A12DE820248150"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0D50EA.6080900@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig73358637B3A12DE820248150
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2012 10:05 AM, Wolfgang Zarre wrote:
[...]

The patch looks good, it has some style issues though, see comments
inline. Please fix them, add a description to the patch, don't forget
your S-o-b, same applies to the other patch which removes the extra IRQ
ack. Please create a series of two patches, first this (the spinlock
patch), the second the rermoval of the extra IRQ ack. Send this patches
to this list. See [1] for more information about patch submitting.

Marc

[1] http://lxr.linux.no/linux+v3.2/Documentation/SubmittingPatches#L86

> Test was successful, 2.000.000 telegrams again without problems.
> Here so far the patch as You suggested:
>=20
> -------------------------------------------------------------------
>  diff --git a/drivers/net/can/cc770/cc770_isa.c
> b/drivers/net/can/cc770/cc770_isa.c
> index 4be5fe2..adf3e45 100644
> --- a/drivers/net/can/cc770/cc770_isa.c
> +++ b/drivers/net/can/cc770/cc770_isa.c
> @@ -110,6 +110,10 @@ MODULE_PARM_DESC(bcr, "Bus configuration register
> (default=3D0x40 [CBY])");
>  #define CC770_IOSIZE          0x20
>  #define CC770_IOSIZE_INDIRECT 0x02
>=20
> +/* Spinlock for cc770_isa_port_write_reg_indirect */

The spinlock is used in read_reg_indirect, too

> +static DEFINE_SPINLOCK(cc770_isa_port_lock);
> +
> +

Just one new blank line please.

>  static struct platform_device *cc770_isa_devs[MAXDEV];
>=20
>  static u8 cc770_isa_mem_read_reg(const struct cc770_priv *priv, int re=
g)
> @@ -138,18 +142,26 @@ static u8 cc770_isa_port_read_reg_indirect(const
> struct cc770_priv *priv,
>                           int reg)
>  {
>      unsigned long base =3D (unsigned long)priv->reg_base;
> +    unsigned long flags;
> +    u8 val;
>=20
> +    spin_lock_irqsave(&cc770_isa_port_lock, flags);
>      outb(reg, base);
> -    return inb(base + 1);
> +    val =3D inb(base + 1);
> +    spin_unlock_irqrestore(&cc770_isa_port_lock, flags);

Please insert a newline before return.

> +    return val;
>  }
>=20
>  static void cc770_isa_port_write_reg_indirect(const struct cc770_priv
> *priv,
>                          int reg, u8 val)
>  {
>      unsigned long base =3D (unsigned long)priv->reg_base;
> +    unsigned long flags;
>=20
> +    spin_lock_irqsave(&cc770_isa_port_lock, flags);
>      outb(reg, base);
>      outb(val, base + 1);
> +    spin_unlock_irqrestore(&cc770_isa_port_lock, flags);   =20
>  }
>=20
>  static int __devinit cc770_isa_probe(struct platform_device *pdev)
> -------------------------------------------------------


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig73358637B3A12DE820248150
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8NVvEACgkQjTAFq1RaXHNODgCfREUFoeGRi4Azim0AB8LSzLD/
UKgAnReMzXWnOhQI6AjyyAfb9OnBXxoA
=x4mJ
-----END PGP SIGNATURE-----

--------------enig73358637B3A12DE820248150--
