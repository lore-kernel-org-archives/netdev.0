From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 09 Aug 2011 14:33:31 +0200
Message-ID: <4E41291B.3020001@pengutronix.de>
References: <1312869313-22434-1-git-send-email-holt@sgi.com>
	<1312869313-22434-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7493927804923053369=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312869313-22434-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
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
--===============7493927804923053369==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB368C5F84E51A87E4583B1A9"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB368C5F84E51A87E4583B1A9
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/09/2011 07:55 AM, Robin Holt wrote:
> I added a clock source for the p1010rdb so the flexcan driver
> could find its clock frequency.
>=20
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>

After fixing Wolfgangs remarks add by Acked-by, for what it's worth in
the ppc-world :)

Some nitpicking from me :) - Darn you send another patch. This comments
still apply.

>=20
> ---
>=20
> Could I also get a ruling on the Kconfig language.  I could do it eithe=
r
> with the 85xx_HAVE_CAN_FLEXCAN in or out of the Kconfig file.  It felt
> like the right thing to do was without, but the arm Kconfig files do
> it this way and a patch from freescale had something similar so I went
> this route.
>=20
>  arch/powerpc/platforms/85xx/Kconfig    |    6 +++
>  arch/powerpc/platforms/85xx/Makefile   |    1 +
>  arch/powerpc/platforms/85xx/clock.c    |   59 ++++++++++++++++++++++++=
++++++++
>  arch/powerpc/platforms/85xx/p1010rdb.c |    8 ++++
>  4 files changed, 74 insertions(+), 0 deletions(-)
>  create mode 100644 arch/powerpc/platforms/85xx/clock.c
>=20
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platfor=
ms/85xx/Kconfig
> index 498534c..ed4cf92 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -26,6 +26,10 @@ config MPC8560_ADS
>  	help
>  	  This option enables support for the MPC 8560 ADS board
> =20
> +config 85xx_HAVE_CAN_FLEXCAN
> +	bool
> +	select HAVE_CAN_FLEXCAN if NET && CAN
> +
>  config MPC85xx_CDS
>  	bool "Freescale MPC85xx CDS"
>  	select DEFAULT_UIMAGE
> @@ -70,6 +74,8 @@ config MPC85xx_RDB
>  config P1010_RDB
>  	bool "Freescale P1010RDB"
>  	select DEFAULT_UIMAGE
> +	select 85xx_HAVE_CAN_FLEXCAN
> +	select PPC_CLOCK if CAN_FLEXCAN
>  	help
>  	  This option enables support for the MPC85xx RDB (P1010 RDB) board
> =20
> diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platfo=
rms/85xx/Makefile
> index a971b32..64ad7a4 100644
> --- a/arch/powerpc/platforms/85xx/Makefile
> +++ b/arch/powerpc/platforms/85xx/Makefile
> @@ -11,6 +11,7 @@ obj-$(CONFIG_MPC85xx_DS)  +=3D mpc85xx_ds.o
>  obj-$(CONFIG_MPC85xx_MDS) +=3D mpc85xx_mds.o
>  obj-$(CONFIG_MPC85xx_RDB) +=3D mpc85xx_rdb.o
>  obj-$(CONFIG_P1010_RDB)   +=3D p1010rdb.o
> +obj-$(CONFIG_PPC_CLOCK)   +=3D clock.o
>  obj-$(CONFIG_P1022_DS)    +=3D p1022_ds.o
>  obj-$(CONFIG_P1023_RDS)   +=3D p1023_rds.o
>  obj-$(CONFIG_P2040_RDB)   +=3D p2040_rdb.o corenet_ds.o
> diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platfor=
ms/85xx/clock.c
> new file mode 100644
> index 0000000..a25cbf3
> --- /dev/null
> +++ b/arch/powerpc/platforms/85xx/clock.c
> @@ -0,0 +1,59 @@

Please add your copyright notice and add a license, e.g. "This file is
released under GPLv2"

> +
> +#include <linux/device.h>
> +#include <linux/err.h>
> +
> +#include <asm/clk_interface.h>
> +
> +#include <sysdev/fsl_soc.h>
> +
> +/*
> + * p1010rdb needs to provide a clock source for the flexcan driver.
> + */
> +struct clk {
> +	unsigned long rate;
> +} p1010_rdb_system_clock;
> +
> +static struct clk *p1010_rdb_clk_get(struct device *dev, const char *i=
d)
> +{
> +	const char *dev_init_name;
> +
> +	if (!dev)
> +		return ERR_PTR(-ENOENT);
> +
> +	/*
> +	 * The can devices are named ffe1c000.can0 and ffe1d000.can1 on
> +	 * the p1010rdb.  Check for the "can" portion of that name before
> +	 * returning a clock source.
> +	 */
> +	dev_init_name =3D dev_name(dev);
> +	if (strlen(dev_init_name) !=3D 13)
> +		return ERR_PTR(-ENOENT);
> +	dev_init_name +=3D 9;
> +	if (strncmp(dev_init_name, "can", 3))
> +		return ERR_PTR(-ENOENT);
> +
> +	return &p1010_rdb_system_clock;
> +}
> +
> +static void p1010_rdb_clk_put(struct clk *clk)
> +{
> +	return;
> +}
> +
> +static unsigned long p1010_rdb_clk_get_rate(struct clk *clk)
> +{
> +	return clk->rate;
> +}
> +
> +static struct clk_interface p1010_rdb_clk_functions =3D {
> +	.clk_get		=3D p1010_rdb_clk_get,
> +	.clk_get_rate		=3D p1010_rdb_clk_get_rate,
> +	.clk_put		=3D p1010_rdb_clk_put,

no indention here please, just one space before the "=3D". YMMV

> +};
> +
> +void __init p1010_rdb_clk_init(void)
> +{
> +	p1010_rdb_system_clock.rate =3D fsl_get_sys_freq();
> +	clk_functions =3D p1010_rdb_clk_functions;
> +}
> +
> diff --git a/arch/powerpc/platforms/85xx/p1010rdb.c b/arch/powerpc/plat=
forms/85xx/p1010rdb.c
> index d7387fa..29e04d6 100644
> --- a/arch/powerpc/platforms/85xx/p1010rdb.c
> +++ b/arch/powerpc/platforms/85xx/p1010rdb.c
> @@ -81,6 +81,13 @@ static void __init p1010_rdb_setup_arch(void)
>  	printk(KERN_INFO "P1010 RDB board from Freescale Semiconductor\n");
>  }
> =20
> +static void __init p1010_rdb_init(void)
> +{
> +#ifdef PPC_CLOCK
> +	p1010_rdb_clk_init();
> +#endif
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

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB368C5F84E51A87E4583B1A9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5BKR4ACgkQjTAFq1RaXHOljACaA5uy1SzXGE+PW4U9QA0mL2aW
iU0AoJnBuCTqtc6xnKB2BOjz15z1yz5B
=o0uB
-----END PGP SIGNATURE-----

--------------enigB368C5F84E51A87E4583B1A9--

--===============7493927804923053369==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7493927804923053369==--
