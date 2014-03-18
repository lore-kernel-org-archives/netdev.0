From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Tue, 18 Mar 2014 10:28:36 -0700
Message-ID: <CAGVrzcY4SBKFfTvjB0TTvgpAOwCt30C6LjYf9e9E4ciMDVmp-w@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org> <1395132017-15928-3-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395132017-15928-3-git-send-email-zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-03-18 1:40 GMT-07:00 Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>:
> Hisilicon hip04 platform mdio driver
> Reuse Marvell phy drivers/net/phy/marvell.c
>
> Signed-off-by: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/hisilicon/Kconfig      |   31 +++++
>  drivers/net/ethernet/hisilicon/Makefile     |    5 +
>  drivers/net/ethernet/hisilicon/hip04_mdio.c |  190 +++++++++++++++++++++++++++
>  5 files changed, 228 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/Kconfig
>  create mode 100644 drivers/net/ethernet/hisilicon/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hip04_mdio.c
>
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 39484b5..cef103d 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -55,6 +55,7 @@ source "drivers/net/ethernet/neterion/Kconfig"
>  source "drivers/net/ethernet/faraday/Kconfig"
>  source "drivers/net/ethernet/freescale/Kconfig"
>  source "drivers/net/ethernet/fujitsu/Kconfig"
> +source "drivers/net/ethernet/hisilicon/Kconfig"
>  source "drivers/net/ethernet/hp/Kconfig"
>  source "drivers/net/ethernet/ibm/Kconfig"
>  source "drivers/net/ethernet/intel/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index adf61af..f70b166 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -30,6 +30,7 @@ obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
>  obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
>  obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
>  obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
> +obj-$(CONFIG_NET_VENDOR_HISILICON) += hisilicon/
>  obj-$(CONFIG_NET_VENDOR_HP) += hp/
>  obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
>  obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
> new file mode 100644
> index 0000000..4b1c065
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/Kconfig
> @@ -0,0 +1,31 @@
> +#
> +# HISILICON device configuration
> +#
> +
> +config NET_VENDOR_HISILICON
> +       bool "Hisilicon devices"
> +       default y
> +       depends on ARM
> +       ---help---
> +         If you have a network (Ethernet) card belonging to this class, say Y
> +         and read the Ethernet-HOWTO, available from
> +         <http://www.tldp.org/docs.html#howto>.
> +
> +         Note that the answer to this question doesn't directly affect the
> +         kernel: saying N will just cause the configurator to skip all
> +         the questions about MOXA ART devices. If you say Y, you will be asked
> +         for your specific card in the following questions.
> +
> +if NET_VENDOR_HISILICON
> +
> +config HIP04_ETH
> +       tristate "HISILICON P04 Ethernet support"
> +       select NET_CORE
> +       select PHYLIB
> +       select MARVELL_PHY
> +       ---help---
> +         If you wish to compile a kernel for a hardware with hisilicon p04 SoC and
> +         want to use the internal ethernet then you should answer Y to this.
> +
> +
> +endif # NET_VENDOR_HISILICON
> diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
> new file mode 100644
> index 0000000..1d6eb6e
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the HISILICON network device drivers.
> +#
> +
> +obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o
> diff --git a/drivers/net/ethernet/hisilicon/hip04_mdio.c b/drivers/net/ethernet/hisilicon/hip04_mdio.c
> new file mode 100644
> index 0000000..960adc2
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hip04_mdio.c
> @@ -0,0 +1,190 @@
> +
> +/* Copyright (c) 2014 Linaro Ltd.
> + * Copyright (c) 2014 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/platform_device.h>
> +#include <linux/io.h>
> +#include <linux/of_mdio.h>
> +#include <linux/delay.h>
> +
> +#define MDIO_CMD_REG           0x0
> +#define MDIO_ADDR_REG          0x4
> +#define MDIO_WDATA_REG         0x8
> +#define MDIO_RDATA_REG         0xc
> +#define MDIO_STA_REG           0x10
> +
> +#define MDIO_START             BIT(14)
> +#define MDIO_R_VALID           BIT(1)
> +#define MDIO_READ              (BIT(12) | BIT(11) | MDIO_START)
> +#define MDIO_WRITE             (BIT(12) | BIT(10) | MDIO_START)
> +
> +struct hip04_mdio_priv {
> +       void __iomem *base;
> +};
> +
> +#define WAIT_TIMEOUT 10
> +static int hip04_mdio_wait_ready(struct mii_bus *bus)
> +{
> +       struct hip04_mdio_priv *priv = bus->priv;
> +       int i;
> +
> +       for (i = 0; readl_relaxed(priv->base + MDIO_CMD_REG) & MDIO_START; i++) {
> +               if (i == WAIT_TIMEOUT)
> +                       return -ETIMEDOUT;
> +               msleep(20);
> +       }
> +
> +       return 0;
> +}
> +
> +static int hip04_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
> +{
> +       struct hip04_mdio_priv *priv = bus->priv;
> +       u32 val;
> +       int ret;
> +
> +       ret = hip04_mdio_wait_ready(bus);
> +       if (ret < 0)
> +               goto out;
> +
> +       val = regnum | (mii_id << 5) | MDIO_READ;
> +       writel_relaxed(val, priv->base + MDIO_CMD_REG);
> +
> +       ret = hip04_mdio_wait_ready(bus);
> +       if (ret < 0)
> +               goto out;
> +       val = readl_relaxed(priv->base + MDIO_STA_REG);
> +       if (val & MDIO_R_VALID) {
> +               dev_err(bus->parent, "SMI bus read not valid\n");
> +               ret = -ENODEV;
> +               goto out;
> +       }
> +       val = readl_relaxed(priv->base + MDIO_RDATA_REG);
> +       ret = val & 0xFFFF;
> +out:
> +       return ret;
> +}
> +
> +static int hip04_mdio_write(struct mii_bus *bus, int mii_id,
> +                           int regnum, u16 value)
> +{
> +       struct hip04_mdio_priv *priv = bus->priv;
> +       u32 val;
> +       int ret;
> +
> +       ret = hip04_mdio_wait_ready(bus);
> +       if (ret < 0)
> +               goto out;
> +
> +       writel_relaxed(value, priv->base + MDIO_WDATA_REG);
> +       val = regnum | (mii_id << 5) | MDIO_WRITE;
> +       writel_relaxed(val, priv->base + MDIO_CMD_REG);
> +out:
> +       return ret;
> +}
> +
> +
> +static int hip04_mdio_reset(struct mii_bus *bus)
> +{
> +       int temp, err, i;
> +
> +       for (i = 0; i < 2; i++) {
> +               hip04_mdio_write(bus, i, 22, 0);
> +               temp = hip04_mdio_read(bus, i, MII_BMCR);
> +               temp |= BMCR_RESET;
> +               err = hip04_mdio_write(bus, i, MII_BMCR, temp);
> +               if (err < 0)
> +                       return err;
> +       }
> +
> +       mdelay(500);

This does not look correct, you should iterate over all possible PHYs:
PHY_MAX_ADDR instead of hardcoding the loop to 2.

I think we might want to remove the mdio bus reset callback in general
as the PHY library should already take care of software resetting the
PHY to put it in a sane state, as well as waiting for the appropriate
delay before using, unlike here, where you do not poll for BMCR_RESET
to be cleared by the PHY.

> +       return 0;
> +}
> +
> +static int hip04_mdio_probe(struct platform_device *pdev)
> +{
> +       struct resource *r;
> +       struct mii_bus *bus;
> +       struct hip04_mdio_priv *priv;
> +       int ret;
> +
> +       r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       if (!r) {
> +               dev_err(&pdev->dev, "No SMI register address given\n");
> +               return -ENODEV;
> +       }
> +
> +       bus = mdiobus_alloc_size(sizeof(struct hip04_mdio_priv));
> +       if (!bus) {
> +               dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
> +               return -ENOMEM;
> +       }
> +
> +       bus->name = "hip04_mdio_bus";
> +       bus->read = hip04_mdio_read;
> +       bus->write = hip04_mdio_write;
> +       bus->reset = hip04_mdio_reset;
> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii",
> +                dev_name(&pdev->dev));
> +       bus->parent = &pdev->dev;
> +       priv = bus->priv;
> +       priv->base = devm_ioremap(&pdev->dev, r->start, resource_size(r));
> +       if (!priv->base) {
> +               dev_err(&pdev->dev, "Unable to remap SMI register\n");
> +               ret = -ENODEV;
> +               goto out_mdio;
> +       }
> +
> +       ret = of_mdiobus_register(bus, pdev->dev.of_node);
> +       if (ret < 0) {
> +               dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
> +               goto out_mdio;
> +       }
> +
> +       platform_set_drvdata(pdev, bus);
> +
> +       return 0;
> +
> +out_mdio:
> +       mdiobus_free(bus);
> +       return ret;
> +}
> +
> +static int hip04_mdio_remove(struct platform_device *pdev)
> +{
> +       struct mii_bus *bus = platform_get_drvdata(pdev);
> +
> +       mdiobus_unregister(bus);
> +       mdiobus_free(bus);
> +
> +       return 0;
> +}
> +
> +static const struct of_device_id hip04_mdio_match[] = {
> +       { .compatible = "hisilicon,hip04-mdio" },
> +       { }
> +};
> +MODULE_DEVICE_TABLE(of, hip04_mdio_match);
> +
> +static struct platform_driver hip04_mdio_driver = {
> +       .probe = hip04_mdio_probe,
> +       .remove = hip04_mdio_remove,
> +       .driver = {
> +               .name = "hip04-mdio",
> +               .owner = THIS_MODULE,
> +               .of_match_table = hip04_mdio_match,
> +       },
> +};
> +
> +module_platform_driver(hip04_mdio_driver);
> +
> +MODULE_DESCRIPTION("HISILICON P04 MDIO interface driver");
> +MODULE_LICENSE("GPL v2");
> +MODULE_ALIAS("platform:hip04-mdio");
> --
> 1.7.9.5
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
