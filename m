From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net/fec: gasket needs to be enabled for some i.mx
Date: Mon, 4 Jul 2011 08:55:23 +0200
Message-ID: <20110704065523.GX6069@pengutronix.de>
References: <20110630161935.GA7977@S2100-06.ap.freescale.net>
 <1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	u.kleine-koenig@pengutronix.de, LW@KARO-electronics.de,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	"David S. Miller" <davem@davemloft.net>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52462 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab1GDGz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 02:55:27 -0400
Content-Disposition: inline
In-Reply-To: <1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Fri, Jul 01, 2011 at 06:11:22PM +0800, Shawn Guo wrote:
> On the recent i.mx (mx25/50/53), there is a gasket inside fec
> controller which needs to be enabled no matter phy works in MII
> or RMII mode.
> 
> The current code enables the gasket only when phy interface is RMII.
> It's broken when the driver works with a MII phy.  The patch uses
> platform_device_id to distinguish the SoCs that have the gasket and
> enables it on these SoCs for both MII and RMII mode.
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Sascha Hauer <s.hauer@pengutronix.de>
> ---
>  arch/arm/mach-imx/clock-imx25.c                 |    2 +-
>  arch/arm/mach-imx/clock-imx27.c                 |    2 +-
>  arch/arm/mach-imx/clock-imx35.c                 |    2 +-
>  arch/arm/mach-mx5/clock-mx51-mx53.c             |    4 +-
>  arch/arm/plat-mxc/devices/platform-fec.c        |   17 ++++++++-------
>  arch/arm/plat-mxc/include/mach/devices-common.h |    1 +
>  drivers/net/fec.c                               |   26 ++++++++++++++++++++--

I either need your Ack for this or we need to split this up into two
patches. Pushing this through the net tree is probably not a good idea.

Sascha

>  7 files changed, 38 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/arm/mach-imx/clock-imx25.c b/arch/arm/mach-imx/clock-imx25.c
> index a65838f..5527fff 100644
> --- a/arch/arm/mach-imx/clock-imx25.c
> +++ b/arch/arm/mach-imx/clock-imx25.c
> @@ -294,7 +294,7 @@ static struct clk_lookup lookups[] = {
>  	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c_clk)
>  	_REGISTER_CLOCK("imx-i2c.1", NULL, i2c_clk)
>  	_REGISTER_CLOCK("imx-i2c.2", NULL, i2c_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx25-fec.0", NULL, fec_clk)
>  	_REGISTER_CLOCK("imxdi_rtc.0", NULL, dryice_clk)
>  	_REGISTER_CLOCK("imx-fb.0", NULL, lcdc_clk)
>  	_REGISTER_CLOCK("imx2-wdt.0", NULL, wdt_clk)
> diff --git a/arch/arm/mach-imx/clock-imx27.c b/arch/arm/mach-imx/clock-imx27.c
> index 583f251..d197df2 100644
> --- a/arch/arm/mach-imx/clock-imx27.c
> +++ b/arch/arm/mach-imx/clock-imx27.c
> @@ -662,7 +662,7 @@ static struct clk_lookup lookups[] = {
>  	_REGISTER_CLOCK(NULL, "brom", brom_clk)
>  	_REGISTER_CLOCK(NULL, "emma", emma_clk)
>  	_REGISTER_CLOCK(NULL, "slcdc", slcdc_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx27-fec.0", NULL, fec_clk)
>  	_REGISTER_CLOCK(NULL, "emi", emi_clk)
>  	_REGISTER_CLOCK(NULL, "sahara2", sahara2_clk)
>  	_REGISTER_CLOCK(NULL, "ata", ata_clk)
> diff --git a/arch/arm/mach-imx/clock-imx35.c b/arch/arm/mach-imx/clock-imx35.c
> index 5a4cc1e..fb4007b 100644
> --- a/arch/arm/mach-imx/clock-imx35.c
> +++ b/arch/arm/mach-imx/clock-imx35.c
> @@ -461,7 +461,7 @@ static struct clk_lookup lookups[] = {
>  	_REGISTER_CLOCK("sdhci-esdhc-imx.0", NULL, esdhc1_clk)
>  	_REGISTER_CLOCK("sdhci-esdhc-imx.1", NULL, esdhc2_clk)
>  	_REGISTER_CLOCK("sdhci-esdhc-imx.2", NULL, esdhc3_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx35-fec.0", NULL, fec_clk)
>  	_REGISTER_CLOCK(NULL, "gpio", gpio1_clk)
>  	_REGISTER_CLOCK(NULL, "gpio", gpio2_clk)
>  	_REGISTER_CLOCK(NULL, "gpio", gpio3_clk)
> diff --git a/arch/arm/mach-mx5/clock-mx51-mx53.c b/arch/arm/mach-mx5/clock-mx51-mx53.c
> index 699b0d2..04c5a01 100644
> --- a/arch/arm/mach-mx5/clock-mx51-mx53.c
> +++ b/arch/arm/mach-mx5/clock-mx51-mx53.c
> @@ -1426,7 +1426,7 @@ static struct clk_lookup mx51_lookups[] = {
>  	_REGISTER_CLOCK("imx-uart.1", NULL, uart2_clk)
>  	_REGISTER_CLOCK("imx-uart.2", NULL, uart3_clk)
>  	_REGISTER_CLOCK(NULL, "gpt", gpt_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx51-fec.0", NULL, fec_clk)
>  	_REGISTER_CLOCK("mxc_pwm.0", "pwm", pwm1_clk)
>  	_REGISTER_CLOCK("mxc_pwm.1", "pwm", pwm2_clk)
>  	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c1_clk)
> @@ -1475,7 +1475,7 @@ static struct clk_lookup mx53_lookups[] = {
>  	_REGISTER_CLOCK("imx-uart.3", NULL, uart4_clk)
>  	_REGISTER_CLOCK("imx-uart.4", NULL, uart5_clk)
>  	_REGISTER_CLOCK(NULL, "gpt", gpt_clk)
> -	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
> +	_REGISTER_CLOCK("imx53-fec.0", NULL, fec_clk)
>  	_REGISTER_CLOCK(NULL, "iim_clk", iim_clk)
>  	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c1_clk)
>  	_REGISTER_CLOCK("imx-i2c.1", NULL, i2c2_clk)
> diff --git a/arch/arm/plat-mxc/devices/platform-fec.c b/arch/arm/plat-mxc/devices/platform-fec.c
> index ccc789e..3790c59 100644
> --- a/arch/arm/plat-mxc/devices/platform-fec.c
> +++ b/arch/arm/plat-mxc/devices/platform-fec.c
> @@ -10,40 +10,41 @@
>  #include <mach/hardware.h>
>  #include <mach/devices-common.h>
>  
> -#define imx_fec_data_entry_single(soc)					\
> +#define imx_fec_data_entry_single(soc, _devid)				\
>  	{								\
> +		.devid = _devid,					\
>  		.iobase = soc ## _FEC_BASE_ADDR,			\
>  		.irq = soc ## _INT_FEC,					\
>  	}
>  
>  #ifdef CONFIG_SOC_IMX25
>  const struct imx_fec_data imx25_fec_data __initconst =
> -	imx_fec_data_entry_single(MX25);
> +	imx_fec_data_entry_single(MX25, "imx25-fec");
>  #endif /* ifdef CONFIG_SOC_IMX25 */
>  
>  #ifdef CONFIG_SOC_IMX27
>  const struct imx_fec_data imx27_fec_data __initconst =
> -	imx_fec_data_entry_single(MX27);
> +	imx_fec_data_entry_single(MX27, "imx27-fec");
>  #endif /* ifdef CONFIG_SOC_IMX27 */
>  
>  #ifdef CONFIG_SOC_IMX35
>  const struct imx_fec_data imx35_fec_data __initconst =
> -	imx_fec_data_entry_single(MX35);
> +	imx_fec_data_entry_single(MX35, "imx35-fec");
>  #endif
>  
>  #ifdef CONFIG_SOC_IMX50
>  const struct imx_fec_data imx50_fec_data __initconst =
> -	imx_fec_data_entry_single(MX50);
> +	imx_fec_data_entry_single(MX50, "imx50-fec");
>  #endif
>  
>  #ifdef CONFIG_SOC_IMX51
>  const struct imx_fec_data imx51_fec_data __initconst =
> -	imx_fec_data_entry_single(MX51);
> +	imx_fec_data_entry_single(MX51, "imx51-fec");
>  #endif
>  
>  #ifdef CONFIG_SOC_IMX53
>  const struct imx_fec_data imx53_fec_data __initconst =
> -	imx_fec_data_entry_single(MX53);
> +	imx_fec_data_entry_single(MX53, "imx53-fec");
>  #endif
>  
>  struct platform_device *__init imx_add_fec(
> @@ -62,7 +63,7 @@ struct platform_device *__init imx_add_fec(
>  		},
>  	};
>  
> -	return imx_add_platform_device_dmamask("fec", 0,
> +	return imx_add_platform_device_dmamask(data->devid, 0,
>  			res, ARRAY_SIZE(res),
>  			pdata, sizeof(*pdata), DMA_BIT_MASK(32));
>  }
> diff --git a/arch/arm/plat-mxc/include/mach/devices-common.h b/arch/arm/plat-mxc/include/mach/devices-common.h
> index bf93820..6ac2450 100644
> --- a/arch/arm/plat-mxc/include/mach/devices-common.h
> +++ b/arch/arm/plat-mxc/include/mach/devices-common.h
> @@ -30,6 +30,7 @@ static inline struct platform_device *imx_add_platform_device(
>  
>  #include <linux/fec.h>
>  struct imx_fec_data {
> +	const char *devid;
>  	resource_size_t iobase;
>  	resource_size_t irq;
>  };
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 885d8ba..9161a82 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -66,14 +66,31 @@
>  #define FEC_QUIRK_ENET_MAC		(1 << 0)
>  /* Controller needs driver to swap frame */
>  #define FEC_QUIRK_SWAP_FRAME		(1 << 1)
> +/* Controller uses gasket */
> +#define FEC_QUIRK_USE_GASKET		(1 << 2)
>  
>  static struct platform_device_id fec_devtype[] = {
>  	{
> -		.name = DRIVER_NAME,
> +		.name = "imx25-fec",
> +		.driver_data = FEC_QUIRK_USE_GASKET,
> +	}, {
> +		.name = "imx27-fec",
>  		.driver_data = 0,
>  	}, {
>  		.name = "imx28-fec",
>  		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
> +	}, {
> +		.name = "imx35-fec",
> +		.driver_data = 0,
> +	}, {
> +		.name = "imx50-fec",
> +		.driver_data = FEC_QUIRK_USE_GASKET,
> +	}, {
> +		.name = "imx51-fec",
> +		.driver_data = 0,
> +	}, {
> +		.name = "imx53-fec",
> +		.driver_data = FEC_QUIRK_USE_GASKET,
>  	},
>  	{ }
>  };
> @@ -425,7 +442,7 @@ fec_restart(struct net_device *ndev, int duplex)
>  
>  	} else {
>  #ifdef FEC_MIIGSK_ENR
> -		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII) {
> +		if (id_entry->driver_data & FEC_QUIRK_USE_GASKET) {
>  			/* disable the gasket and wait */
>  			writel(0, fep->hwp + FEC_MIIGSK_ENR);
>  			while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
> @@ -434,8 +451,11 @@ fec_restart(struct net_device *ndev, int duplex)
>  			/*
>  			 * configure the gasket:
>  			 *   RMII, 50 MHz, no loopback, no echo
> +			 *   MII, 25 MHz, no loopback, no echo
>  			 */
> -			writel(1, fep->hwp + FEC_MIIGSK_CFGR);
> +			writel((fep->phy_interface == PHY_INTERFACE_MODE_RMII) ?
> +					1 : 0, fep->hwp + FEC_MIIGSK_CFGR);
> +
>  
>  			/* re-enable the gasket */
>  			writel(2, fep->hwp + FEC_MIIGSK_ENR);
> -- 
> 1.7.4.1
> 
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
