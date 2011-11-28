From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v3 3/4] can: cc770: add platform bus driver for
 the CC770 and AN82527
Date: Mon, 28 Nov 2011 13:33:34 +0100
Message-ID: <4ED37F9E.1070403@pengutronix.de>
References: <1322479858-4874-1-git-send-email-wg@grandegger.com> <1322479858-4874-4-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE343FE883F2645F0158D261B"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>,
	Wolfgang Zarre <info@essax.com>,
	Devicetree-discuss@lists.ozlabs.org, linuxppc-dev@ozlabs.org,
	Kumar Gala <galak@kernel.crashing.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1322479858-4874-4-git-send-email-wg@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE343FE883F2645F0158D261B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/28/2011 12:30 PM, Wolfgang Grandegger wrote:
> This driver works with both, static platform data and device tree
> bindings. It has been tested on a TQM855L board with two AN82527
> CAN controllers on the local bus.
>=20
> CC: Devicetree-discuss@lists.ozlabs.org
> CC: linuxppc-dev@ozlabs.org
> CC: Kumar Gala <galak@kernel.crashing.org>
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

See comment in the _remove function. Otherwise good. Add my:
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

> ---
>  .../devicetree/bindings/net/can/cc770.txt          |   56 ++++
>  drivers/net/can/cc770/Kconfig                      |    7 +
>  drivers/net/can/cc770/Makefile                     |    1 +
>  drivers/net/can/cc770/cc770_platform.c             |  280 ++++++++++++=
++++++++
>  4 files changed, 344 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/can/cc770.txt=

>  create mode 100644 drivers/net/can/cc770/cc770_platform.c
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/cc770.txt b/Docu=
mentation/devicetree/bindings/net/can/cc770.txt
> new file mode 100644
> index 0000000..01e282d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/cc770.txt
> @@ -0,0 +1,56 @@
> +Memory mapped Bosch CC770 and Intel AN82527 CAN controller
> +
> +Note: The CC770 is a CAN controller from Bosch, which is 100%
> +compatible with the old AN82527 from Intel, but with "bugs" being fixe=
d.
> +
> +Required properties:
> +
> +- compatible : should be "bosch,cc770" for the CC770 and "intc,82527"
> +	for the AN82527.
> +
> +- reg : should specify the chip select, address offset and size requir=
ed
> +	to map the registers of the controller. The size is usually 0x80.
> +
> +- interrupts : property with a value describing the interrupt source
> +	(number and sensitivity) required for the controller.
> +
> +Optional properties:
> +
> +- bosch,external-clock-frequency : frequency of the external oscillato=
r
> +	clock in Hz. Note that the internal clock frequency used by the
> +	controller is half of that value. If not specified, a default
> +	value of 16000000 (16 MHz) is used.
> +
> +- bosch,clock-out-frequency : slock frequency in Hz on the CLKOUT pin.=

> +	If not specified or if the specified value is 0, the CLKOUT pin
> +	will be disabled.
> +
> +- bosch,slew-rate : slew rate of the CLKOUT signal. If not specified,
> +	a resonable value will be calculated.
> +
> +- bosch,disconnect-rx0-input : see data sheet.
> +
> +- bosch,disconnect-rx1-input : see data sheet.
> +
> +- bosch,disconnect-tx1-output : see data sheet.
> +
> +- bosch,polarity-dominant : see data sheet.
> +
> +- bosch,divide-memory-clock : see data sheet.
> +
> +- bosch,iso-low-speed-mux : see data sheet.
> +
> +For further information, please have a look to the CC770 or AN82527.
> +
> +Examples:
> +
> +can@3,100 {
> +	compatible =3D "bosch,cc770";
> +	reg =3D <3 0x100 0x80>;
> +	interrupts =3D <2 0>;
> +	interrupt-parent =3D <&mpic>;
> +	bosch,external-clock-frequency =3D <16000000>;
> +};
> +
> +
> +
> diff --git a/drivers/net/can/cc770/Kconfig b/drivers/net/can/cc770/Kcon=
fig
> index 28e4d48..22c07a8 100644
> --- a/drivers/net/can/cc770/Kconfig
> +++ b/drivers/net/can/cc770/Kconfig
> @@ -11,4 +11,11 @@ config CAN_CC770_ISA
>  	  connected to the ISA bus using I/O port, memory mapped or
>  	  indirect access.
> =20
> +config CAN_CC770_PLATFORM
> +	tristate "Generic Platform Bus based CC770 driver"
> +	---help---
> +	  This driver adds support for the CC770 and AN82527 chips
> +	  connected to the "platform bus" (Linux abstraction for directly
> +	  to the processor attached devices).
> +
>  endif
> diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Mak=
efile
> index 872ecff..9fb8321 100644
> --- a/drivers/net/can/cc770/Makefile
> +++ b/drivers/net/can/cc770/Makefile
> @@ -4,5 +4,6 @@
> =20
>  obj-$(CONFIG_CAN_CC770) +=3D cc770.o
>  obj-$(CONFIG_CAN_CC770_ISA) +=3D cc770_isa.o
> +obj-$(CONFIG_CAN_CC770_PLATFORM) +=3D cc770_platform.o
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/cc770/cc770_platform.c b/drivers/net/can/c=
c770/cc770_platform.c
> new file mode 100644
> index 0000000..65e177e
> --- /dev/null
> +++ b/drivers/net/can/cc770/cc770_platform.c
> @@ -0,0 +1,280 @@
> +/*
> + * Driver for CC770 and AN82527 CAN controllers on the platform bus
> + *
> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
> + *
> + * This program is free software; you can redistribute it and/or modif=
y
> + * it under the terms of the version 2 of the GNU General Public Licen=
se
> + * as published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software Foundat=
ion,
> + * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

please remove the address.

> + */
> +
> +/*
> + * If platform data are used you should have similar definitions
> + * in your board-specific code:
> + *
> + *   static struct cc770_platform_data myboard_cc770_pdata =3D {
> + *           .osc_freq =3D 16000000,
> + *           .cir =3D 0x41,
> + *           .cor =3D 0x20,
> + *           .bcr =3D 0x40,
> + *   };
> + *
> + * Please see include/linux/can/platform/cc770.h for description of
> + * above fields.
> + *
> + * If the device tree is used, you need a CAN node definition in your
> + * DTS file similar to:
> + *
> + *   can@3,100 {
> + *           compatible =3D "bosch,cc770";
> + *           reg =3D <3 0x100 0x80>;
> + *           interrupts =3D <2 0>;
> + *           interrupt-parent =3D <&mpic>;
> + *           bosch,external-clock-frequency =3D <16000000>;
> + *   };
> + *
> + * See "Documentation/devicetree/bindings/net/can/cc770.txt" for furth=
er
> + * information.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/delay.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/platform/cc770.h>
> +
> +#include <linux/of_platform.h>
> +
> +#include "cc770.h"
> +
> +#define DRV_NAME "cc770_platform"
> +
> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
> +MODULE_DESCRIPTION("Socket-CAN driver for CC770 on the platform bus");=

> +MODULE_LICENSE("GPL v2");
> +
> +#define CC770_PLATFORM_CAN_CLOCK  16000000
> +
> +static u8 cc770_platform_read_reg(const struct cc770_priv *priv, int r=
eg)
> +{
> +	return in_8(priv->reg_base + reg);
> +}
> +
> +static void cc770_platform_write_reg(const struct cc770_priv *priv, in=
t reg,
> +				     u8 val)
> +{
> +	out_8(priv->reg_base + reg, val);
> +}
> +
> +static int __devinit cc770_get_of_node_data(struct platform_device *pd=
ev,
> +					    struct cc770_priv *priv)
> +{
> +	struct device_node *np =3D pdev->dev.of_node;
> +	const u32 *prop;
> +	int prop_size;
> +	u32 clkext;
> +
> +	prop =3D of_get_property(np, "bosch,external-clock-frequency",
> +			       &prop_size);
> +	if (prop && (prop_size =3D=3D  sizeof(u32)))
> +		clkext =3D *prop;
> +	else
> +		clkext =3D CC770_PLATFORM_CAN_CLOCK; /* default */
> +	priv->can.clock.freq =3D clkext;
> +
> +	/* The system clock may not exceed 10 MHz */
> +	if (priv->can.clock.freq > 10000000) {
> +		priv->cpu_interface |=3D CPUIF_DSC;
> +		priv->can.clock.freq /=3D 2;
> +	}
> +
> +	/* The memory clock may not exceed 8 MHz */
> +	if (priv->can.clock.freq > 8000000)
> +		priv->cpu_interface |=3D CPUIF_DMC;
> +
> +	if (of_get_property(np, "bosch,divide-memory-clock", NULL))
> +		priv->cpu_interface |=3D CPUIF_DMC;
> +	if (of_get_property(np, "bosch,iso-low-speed-mux", NULL))
> +		priv->cpu_interface |=3D CPUIF_MUX;
> +
> +	if (!of_get_property(np, "bosch,no-comperator-bypass", NULL))
> +		priv->bus_config |=3D BUSCFG_CBY;
> +	if (of_get_property(np, "bosch,disconnect-rx0-input", NULL))
> +		priv->bus_config |=3D BUSCFG_DR0;
> +	if (of_get_property(np, "bosch,disconnect-rx1-input", NULL))
> +		priv->bus_config |=3D BUSCFG_DR1;
> +	if (of_get_property(np, "bosch,disconnect-tx1-output", NULL))
> +		priv->bus_config |=3D BUSCFG_DT1;
> +	if (of_get_property(np, "bosch,polarity-dominant", NULL))
> +		priv->bus_config |=3D BUSCFG_POL;
> +
> +	prop =3D of_get_property(np, "bosch,clock-out-frequency", &prop_size)=
;
> +	if (prop && (prop_size =3D=3D sizeof(u32)) && *prop > 0) {
> +		u32 cdv =3D clkext / *prop;
> +		int slew;
> +
> +		if (cdv > 0 && cdv < 16) {
> +			priv->cpu_interface |=3D CPUIF_CEN;
> +			priv->clkout |=3D (cdv - 1) & CLKOUT_CD_MASK;
> +
> +			prop =3D of_get_property(np, "bosch,slew-rate",
> +					       &prop_size);
> +			if (prop && (prop_size =3D=3D sizeof(u32))) {
> +				slew =3D *prop;
> +			} else {
> +				/* Determine default slew rate */
> +				slew =3D (CLKOUT_SL_MASK >>
> +					CLKOUT_SL_SHIFT) -
> +					((cdv * clkext - 1) / 8000000);
> +				if (slew < 0)
> +					slew =3D 0;
> +			}
> +			priv->clkout |=3D (slew << CLKOUT_SL_SHIFT) &
> +				CLKOUT_SL_MASK;
> +		} else {
> +			dev_dbg(&pdev->dev, "invalid clock-out-frequency\n");
> +		}
> +	}
> +
> +	return 0;
> +}
> +
> +static int __devinit cc770_get_platform_data(struct platform_device *p=
dev,
> +					     struct cc770_priv *priv)
> +{
> +
> +	struct cc770_platform_data *pdata =3D pdev->dev.platform_data;
> +
> +	priv->can.clock.freq =3D pdata->osc_freq;
> +	if (priv->cpu_interface | CPUIF_DSC)
> +		priv->can.clock.freq /=3D 2;
> +	priv->clkout =3D pdata->cor;
> +	priv->bus_config =3D pdata->bcr;
> +	priv->cpu_interface =3D pdata->cir;
> +
> +	return 0;
> +}
> +
> +static int __devinit cc770_platform_probe(struct platform_device *pdev=
)
> +{
> +	struct net_device *dev;
> +	struct cc770_priv *priv;
> +	struct resource *mem;
> +	resource_size_t mem_size;
> +	void __iomem *base;
> +	int err, irq;
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	irq =3D platform_get_irq(pdev, 0);
> +	if (!mem || irq <=3D 0)
> +		return -ENODEV;
> +
> +	mem_size =3D resource_size(mem);
> +	if (!request_mem_region(mem->start, mem_size, pdev->name))
> +		return -EBUSY;
> +
> +	base =3D ioremap(mem->start, mem_size);
> +	if (!base) {
> +		err =3D -ENOMEM;
> +		goto exit_release_mem;
> +	}
> +
> +	dev =3D alloc_cc770dev(0);
> +	if (!dev) {
> +		err =3D -ENOMEM;
> +		goto exit_unmap_mem;
> +	}
> +
> +	dev->irq =3D irq;
> +	priv =3D netdev_priv(dev);
> +	priv->read_reg =3D cc770_platform_read_reg;
> +	priv->write_reg =3D cc770_platform_write_reg;
> +	priv->irq_flags =3D IRQF_SHARED;
> +	priv->reg_base =3D base;
> +
> +	if (pdev->dev.of_node)
> +		err =3D cc770_get_of_node_data(pdev, priv);
> +	else if (pdev->dev.platform_data)
> +		err =3D cc770_get_platform_data(pdev, priv);
> +	else
> +		err =3D -ENODEV;
> +	if (err)
> +		goto exit_free_cc770;
> +
> +	dev_dbg(&pdev->dev,
> +		 "reg_base=3D0x%p irq=3D%d clock=3D%d cpu_interface=3D0x%02x "
> +		 "bus_config=3D0x%02x clkout=3D0x%02x\n",
> +		 priv->reg_base, dev->irq, priv->can.clock.freq,
> +		 priv->cpu_interface, priv->bus_config, priv->clkout);
> +
> +	dev_set_drvdata(&pdev->dev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	err =3D register_cc770dev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev,
> +			"couldn't register CC700 device (err=3D%d)\n", err);
> +		goto exit_free_cc770;
> +	}
> +
> +	return 0;
> +
> +exit_free_cc770:
> +	free_cc770dev(dev);
> +exit_unmap_mem:
> +	iounmap(base);
> +exit_release_mem:
> +	release_mem_region(mem->start, mem_size);
> +
> +	return err;
> +}
> +
> +static int __devexit cc770_platform_remove(struct platform_device *pde=
v)
> +{
> +	struct net_device *dev =3D dev_get_drvdata(&pdev->dev);
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct resource *mem;
> +
> +	unregister_cc770dev(dev);
> +	iounmap(priv->reg_base);
> +	free_cc770dev(dev);
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);

Can this fail?

> +	if (mem)
> +		release_mem_region(mem->start, resource_size(mem));
> +	else
> +		dev_err(&pdev->dev, "couldn't release mem region");
> +
> +	return 0;
> +}
> +
> +static struct of_device_id __devinitdata cc770_platform_table[] =3D {
> +	{.compatible =3D "bosch,cc770"}, /* CC770 from Bosch */
> +	{.compatible =3D "intc,82527"},  /* AN82527 from Intel CP */
> +	{},
> +};
> +
> +static struct platform_driver cc770_platform_driver =3D {
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +		.of_match_table =3D cc770_platform_table,
> +	},
> +	.probe =3D cc770_platform_probe,
> +	.remove =3D __devexit_p(cc770_platform_remove),
> +};
> +
> +module_platform_driver(cc770_platform_driver);

nice, I like the new module_platform_driver.

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigE343FE883F2645F0158D261B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7Tf6EACgkQjTAFq1RaXHN7SwCfTCzX9oIwF8DIwgO/F2LlppHh
MdMAnj9CqzyQ2GXFSSkMfHY4RSsAVot1
=T3XB
-----END PGP SIGNATURE-----

--------------enigE343FE883F2645F0158D261B--
