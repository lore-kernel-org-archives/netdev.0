From: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Wed, 01 Jun 2016 20:47:22 -0500
Message-ID: <1464832042.22191.23.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com>
	<CAPDyKFqx2JMLzXoDxGCKFYMFV47+SegnkuWFXKvsQHK7L5w-1g@mail.gmail.com>
	<5339448.D8rpq4ofAC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iomm
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5339448.D8rpq4ofAC@wuerfel>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-05-30 at 15:15 +0200, Arnd Bergmann wrote:
> diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
> new file mode 100644
> index 000000000000..2f30698f5bcf
> --- /dev/null
> +++ b/drivers/soc/fsl/guts.c
> @@ -0,0 +1,130 @@
> +/*
> + * Freescale QorIQ Platforms GUTS Driver
> + *
> + * Copyright (C) 2016 Freescale Semiconductor, Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/io.h>
> +#include <linux/platform_device.h>
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/of_address.h>
> +#include <linux/of_platform.h>
> +#include <linux/sys_soc.h>
> +
> +#define GUTS_PVR	0x0a0
> +#define GUTS_SVR	0x0a4
> +
> +struct guts {
> +	void __iomem *regs;

We already have a struct to define guts.  Why are you not using it?  Why do
you consider using it to be "abuse"?  What if we want to move more guts
functionality into this driver?

> +	bool little_endian;
> +	struct soc_device_attribute soc;
> +};
> +
> +static u32 fsl_guts_get_svr(struct guts *guts)
> +{
> +	if (guts->little_endian)
> +		return ioread32(guts->regs + GUTS_SVR);
> +	else
> +		return ioread32be(guts->regs + GUTS_SVR);
> +}
> +
> +static u32 fsl_guts_get_pvr(struct guts *guts)
> +{
> +	if (guts->little_endian)
> +		return ioread32(guts->regs + GUTS_PVR);
> +	else
> +		return ioread32be(guts->regs + GUTS_PVR);
> +}

You've removed the fallback to mfspr() on PPC, which would be helpful in some
virtualized environments where we don't have the guts node (but do have other
directly assigned devices).  Of course, this is a consequence of the
conversion into a platform device.

> +
> +/*
> + * Table for matching compatible strings, for device tree
> + * guts node, for Freescale QorIQ SOCs.
> + */
> +static const struct of_device_id fsl_guts_of_match[] = {
> +	/* For T4 & B4 Series SOCs */
> +	{ .compatible = "fsl,qoriq-device-config-1.0", .data = "T4/B4
> series" },
[snip]
> +	{ .compatible = "fsl,qoriq-device-config-2.0", .data = "P series"

As noted in my comment on patch 3/4, these descriptions are reversed.

They're also incomplete.  t2080 has device config 2.0.  t1040 is described as
2.0 though it should probably be 2.1 (or better, drop the generic compatible
altogether).

> +	/*
> +	 * syscon devices default to little-endian, but on powerpc we have
> +	 * existing device trees with big-endian maps and an absent
> endianess
> +	 * "big-property"
> +	 */
> +	if (!IS_ENABLED(CONFIG_POWERPC) &&
> +	    !of_property_read_bool(dev->of_node, "big-endian"))
> +		guts->little_endian = true;

This is not a syscon device (Yangbo's patch to add a guts node on ls2080 is
the only guts node that says "syscon", and that was a leftover from earlier
revisions and should probably be removed).  Even if it were, where is it
documented that syscon defaults to little-endian?  

Documentation/devicetree/bindings/common-properties.txt says that the
individual binding specifies the default.  The default for this node should be
big-endian because that's what existed before there was a need to describe the
endianness.  And we need an update to the guts binding to specify that.

> +
> +	guts->regs = devm_ioremap_resource(dev, 0);
> +	if (!guts->regs) {
> +		ret = -ENOMEM;
> +		kfree(guts);
> +		goto out;
> +	}
> +
> +	fsl_guts_init(dev, guts);
> +	ret = 0;
> +out:
> +	return ret;
> +}
> +
> +static struct platform_driver fsl_soc_guts = {
> +	.probe = fsl_guts_probe,
> +	.driver.of_match_table = fsl_guts_of_match,
> +};
> +
> +module_platform_driver(fsl_soc_guts);

Again, this means that the information is not available during early boot,
such as in the clock driver.  Thus we would not be able to convert clk-qoriq's
direct mfspr(SPRN_SVR) into an soc_device_match() (or anything else that makes
use of this file), nor would we be able to move its access of the guts RCW
registers into this driver.

-Scott
