From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V4 3/3] can: m_can: add missing message RAM initialization
Date: Fri, 07 Nov 2014 11:30:38 +0100
Message-ID: <545C9F4E.3040901@pengutronix.de>
References: <1415349914-9145-1-git-send-email-b29396@freescale.com> <1415349914-9145-3-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="eRlkSa9IgmB80fGgpvBPoDsWSMKslf5lA"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415349914-9145-3-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--eRlkSa9IgmB80fGgpvBPoDsWSMKslf5lA
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 09:45 AM, Dong Aisheng wrote:
> The M_CAN message RAM is usually equipped with a parity or ECC function=
ality.
> But RAM cells suffer a hardware reset and can therefore hold arbitrary
> content at startup - including parity and/or ECC bits.
>=20
> To prevent the M_CAN controller detecting checksum errors when reading
> potentially uninitialized TX message RAM content to transmit CAN
> frames the TX message RAM has to be written with (any kind of) initial
> data.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
> ChangeLog:
> v3-v4:
>  * initialize the entire Message RAM in use instead of only 8 bytes
>    since this is a valid and needed initialization process.
>    Patch title also changed.
> ---
>  drivers/net/can/m_can/m_can.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index eee1533..de742d0 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1114,7 +1114,7 @@ static int m_can_of_parse_mram(struct platform_de=
vice *pdev,
>  	struct resource *res;
>  	void __iomem *addr;
>  	u32 out_val[MRAM_CFG_LEN];
> -	int ret;
> +	int i, start, end, ret;
> =20
>  	/* message ram could be shared */
>  	res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "message_r=
am");
> @@ -1165,6 +1165,15 @@ static int m_can_of_parse_mram(struct platform_d=
evice *pdev,
>  		priv->mcfg[MRAM_TXE].off, priv->mcfg[MRAM_TXE].num,
>  		priv->mcfg[MRAM_TXB].off, priv->mcfg[MRAM_TXB].num);
> =20
> +	/* initialize the entire Message RAM in use to avoid possible
> +	 * ECC/parity checksum errors when reading an uninitialized buffer
> +	 */
> +	start =3D priv->mcfg[MRAM_SIDF].off;
> +	end =3D priv->mcfg[MRAM_TXB].off +
> +		priv->mcfg[MRAM_TXB].num * TXB_ELEMENT_SIZE;
> +	for (i =3D start; i < end; i +=3D 4)
> +		writel(0x0, priv->mram_base + i);

Can we access the mram without turning on the clock?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--eRlkSa9IgmB80fGgpvBPoDsWSMKslf5lA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUXJ9OAAoJECte4hHFiupUWXYQAKkOUTaLwg+nuzyk1W0DVdGZ
s7Dzcd4AZ3e0dIcqtWiu2Gs6YGg+HezxMb8p840CktwVRN9YH53/LWJbiwF7W5A0
JfWAJMaGCt7FCMBh8eTM4pEPIMEN7X8JelhQ+mB+7cqxOs3m4Sdn4IjZAZaBpwet
vJ8HHM2k+m5ftEpBwj0mCZhQrAl5y+aJa+BEWCD2zutT84nADuAG9QgFDyBrUjtn
8sDFFD3OcEKN2FKKZw+k1L7ltZLbHvEu4VD/yXIjdcGhNuRlGvbf57zs7uYx4giE
BhsEv/Ae2J5RRAtuIU37iK+Uh65s+VZwb+n3No6z/mBwktGkra66EHEEaL77/z1C
Q248yOAELkCSV9FTKXTy5EvooI0NOYCmVx8S2yVjJGeMgTGLu923yAfuvgCLLwnZ
AdDMj8OfdFRDCV3GFqIPPoSJIbEbHhaHjt7H0KPfM+OVjFACnaUUu03GDjyJckXs
Bizl4B7wybMBZpT+KywqR2f92NuUop0yE5j8yVK22NI8Jpe830t9WiUyeDd+0mTz
mbv+Je7Nx60ac3Iuz9RiluoYHvBHMal7ZwB/Me4l/DjJT+jWYczjKXjhePMYT85z
3eDXPz23bQf1zhGc4z+TXUsJ3H3QrvoTkU7O3AWlE1rXW/SadMrEeK3M7IcQz4KU
W4gl05P2/WqQAkLjjy7U
=tkvA
-----END PGP SIGNATURE-----

--eRlkSa9IgmB80fGgpvBPoDsWSMKslf5lA--
