From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/4] wl1251: split wl251 platform data to a separate
 structure
Date: Thu, 14 Nov 2013 10:51:33 -0800
Message-ID: <20131114185132.GQ10317@atomide.com>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-2-git-send-email-sre@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felipe Balbi <balbi@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Luciano Coelho <coelho@ti.com>
To: Sebastian Reichel <sre@debian.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1382890469-25286-2-git-send-email-sre@debian.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Sebastian Reichel <sre@debian.org> [131027 09:15]:
> From: Luciano Coelho <coelho@ti.com>
> 
> Move the wl1251 part of the wl12xx platform data structure into a new
> structure specifically for wl1251.  Change the platform data built-in
> block and board files accordingly.
> 
> Cc: Tony Lindgren <tony@atomide.com>
> Signed-off-by: Luciano Coelho <coelho@ti.com>
> Acked-by: Tony Lindgren <tony@atomide.com>
> Reviewed-by: Felipe Balbi <balbi@ti.com>
> ---
>  arch/arm/mach-omap2/board-omap3pandora.c       |  4 +--
>  arch/arm/mach-omap2/board-rx51-peripherals.c   |  2 +-
>  drivers/net/wireless/ti/wilink_platform_data.c | 37 +++++++++++++++++++++-----
>  drivers/net/wireless/ti/wl1251/sdio.c          | 12 ++++-----
>  drivers/net/wireless/ti/wl1251/spi.c           |  2 +-
>  include/linux/wl12xx.h                         | 22 ++++++++++++++-
>  6 files changed, 62 insertions(+), 17 deletions(-)
> 
> diff --git a/arch/arm/mach-omap2/board-omap3pandora.c b/arch/arm/mach-omap2/board-omap3pandora.c
> index de1bc6b..24f3c1b 100644
> --- a/arch/arm/mach-omap2/board-omap3pandora.c
> +++ b/arch/arm/mach-omap2/board-omap3pandora.c
> @@ -536,7 +536,7 @@ static struct spi_board_info omap3pandora_spi_board_info[] __initdata = {
>  
>  static void __init pandora_wl1251_init(void)
>  {
> -	struct wl12xx_platform_data pandora_wl1251_pdata;
> +	struct wl1251_platform_data pandora_wl1251_pdata;
>  	int ret;
>  
>  	memset(&pandora_wl1251_pdata, 0, sizeof(pandora_wl1251_pdata));
> @@ -550,7 +550,7 @@ static void __init pandora_wl1251_init(void)
>  		goto fail_irq;
>  
>  	pandora_wl1251_pdata.use_eeprom = true;
> -	ret = wl12xx_set_platform_data(&pandora_wl1251_pdata);
> +	ret = wl1251_set_platform_data(&pandora_wl1251_pdata);
>  	if (ret < 0)
>  		goto fail_irq;
>  
> diff --git a/arch/arm/mach-omap2/board-rx51-peripherals.c b/arch/arm/mach-omap2/board-rx51-peripherals.c
> index 65e3627..0d8e7d2 100644
> --- a/arch/arm/mach-omap2/board-rx51-peripherals.c
> +++ b/arch/arm/mach-omap2/board-rx51-peripherals.c
> @@ -82,7 +82,7 @@ enum {
>  	RX51_SPI_MIPID,		/* LCD panel */
>  };
>  
> -static struct wl12xx_platform_data wl1251_pdata;
> +static struct wl1251_platform_data wl1251_pdata;
>  static struct tsc2005_platform_data tsc2005_pdata;
>  
>  #if defined(CONFIG_SENSORS_LIS3_I2C) || defined(CONFIG_SENSORS_LIS3_I2C_MODULE)

If this is not going into v3.13, these will cause conflicts
with the mach-omap2/board-*.c files for v3.14.

So it might be best to do a minimal header patch first that
can be merged in by both linux-omap and wireless trees.

Regards,

Tony
