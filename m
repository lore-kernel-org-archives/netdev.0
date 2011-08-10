From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v10 4/5] [powerpc] Add flexcan device support for p1010rdb.
Date: Wed, 10 Aug 2011 11:56:01 +0200
Message-ID: <4E4255B1.6050001@pengutronix.de>
References: <1312945564-6626-1-git-send-email-holt@sgi.com>
	<1312945564-6626-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7033428838805027428=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312945564-6626-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
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
--===============7033428838805027428==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAED832CE19B40EE0DA2CD26F"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAED832CE19B40EE0DA2CD26F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/10/2011 05:06 AM, Robin Holt wrote:
> I added a simple clock source for the p1010rdb so the flexcan driver
> could determine a clock frequency.  The p1010 can device only has an
> oscillator of system bus frequency divided by 2.
>=20
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> Acked-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> Cc: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> ---
>  arch/powerpc/platforms/85xx/Kconfig    |    2 +
>  arch/powerpc/platforms/85xx/Makefile   |    2 +
>  arch/powerpc/platforms/85xx/clock.c    |   53 ++++++++++++++++++++++++=
++++++++
>  arch/powerpc/platforms/85xx/p1010rdb.c |    8 +++++
>  4 files changed, 65 insertions(+), 0 deletions(-)
>  create mode 100644 arch/powerpc/platforms/85xx/clock.c
>=20
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platfor=
ms/85xx/Kconfig
> index 498534c..c4304ae 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -70,6 +70,8 @@ config MPC85xx_RDB
>  config P1010_RDB
>  	bool "Freescale P1010RDB"
>  	select DEFAULT_UIMAGE
> +	select HAVE_CAN_FLEXCAN if NET && CAN
> +	select PPC_CLOCK if CAN_FLEXCAN
>  	help
>  	  This option enables support for the MPC85xx RDB (P1010 RDB) board
> =20
> diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platfo=
rms/85xx/Makefile
> index a971b32..cc7f381 100644
> --- a/arch/powerpc/platforms/85xx/Makefile
> +++ b/arch/powerpc/platforms/85xx/Makefile
> @@ -3,6 +3,8 @@
>  #
>  obj-$(CONFIG_SMP) +=3D smp.o
> =20
> +obj-$(CONFIG_PPC_CLOCK)   +=3D clock.o
> +
>  obj-$(CONFIG_MPC8540_ADS) +=3D mpc85xx_ads.o
>  obj-$(CONFIG_MPC8560_ADS) +=3D mpc85xx_ads.o
>  obj-$(CONFIG_MPC85xx_CDS) +=3D mpc85xx_cds.o
> diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platfor=
ms/85xx/clock.c
> new file mode 100644
> index 0000000..16fae04
> --- /dev/null
> +++ b/arch/powerpc/platforms/85xx/clock.c
> @@ -0,0 +1,53 @@
> +/*
> + * Copyright 2011 SGI, inc.
> + *
> + * This code is licensed for use under the GPL V2 as published by
> + * the Free Software Foundation.
> + */
> +
> +#include <linux/device.h>
> +#include <linux/err.h>
> +#include <linux/of.h>
> +
> +#include <asm/clk_interface.h>
> +
> +#include <sysdev/fsl_soc.h>
> +
> +/*
> + * p1010 needs to provide a clock source for the flexcan driver. The
> + * oscillator for the p1010 processor is only ever the system clock / =
2.
> + */
> +
> +static struct clk *mpc85xx_clk_get(struct device *dev, const char *id)=

> +{
> +	if (!dev)
> +		return ERR_PTR(-ENOENT);
> +
> +        if (!dev->of_node ||
> +            !of_device_is_compatible(dev->of_node, "fsl,flexcan"))
> +                return ERR_PTR(-ENOENT);
> +
> +	return NULL;
> +}
> +
> +static void mpc85xx_clk_put(struct clk *clk)
> +{
> +	return;
> +}
> +
> +static unsigned long mpc85xx_clk_get_rate(struct clk *clk)
> +{
> +	return fsl_get_sys_freq() / 2;
> +}
> +
> +static struct clk_interface mpc85xx_clk_functions =3D {
> +	.clk_get =3D mpc85xx_clk_get,
> +	.clk_get_rate =3D mpc85xx_clk_get_rate,
> +	.clk_put =3D mpc85xx_clk_put,
> +};
> +
> +void __init mpc85xx_clk_init(void)
> +{
> +	clk_functions =3D mpc85xx_clk_functions;
> +}
> +

git is even picker then me: "new blank line at EOF."
please fix

> diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/plat=
forms/85xx/p1010rdb.c
> index d7387fa..5e52122 100644
> --- a/arch/powerpc/platforms/85xx/p1010rdb.c
> +++ b/arch/powerpc/platforms/85xx/p1010rdb.c
> @@ -81,6 +81,13 @@ static void __init p1010_rdb_setup_arch(void)
>  	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
>  }
> =20
> +extern void mpc85xx_clk_init(void);
> +
> +static void __init p1010_rdb_init(void)
> +{
> +	mpc85xx_clk_init();
> +}
> +
>  static struct of_device_id __initdata p1010rdb_ids[] =3D {
>  	{ .type =3D "soc", },
>  	{ .compatible =3D "soc", },
> @@ -111,6 +118,7 @@ define_machine(p1010_rdb) {
>  	.name			=3D "P1010 RDB",
>  	.probe			=3D p1010_rdb_probe,
>  	.setup_arch		=3D p1010_rdb_setup_arch,
> +	.init			=3D p1010_rdb_init,
>  	.init_IRQ		=3D p1010_rdb_pic_init,
>  #ifdef CONFIG_PCI
>  	.pcibios_fixup_bus	=3D fsl_pcibios_fixup_bus,

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAED832CE19B40EE0DA2CD26F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk5CVbQACgkQjTAFq1RaXHNz9QCWJQEF1qRZp8IPiO2vEEoJAAVM
QACgkwLQw0Zekpg/HXa8aZZu/ULOVDQ=
=OpXH
-----END PGP SIGNATURE-----

--------------enigAED832CE19B40EE0DA2CD26F--

--===============7033428838805027428==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7033428838805027428==--
