From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 5/6] Switch SPI driver calls its own driver switch
 register function
Date: Thu, 7 Sep 2017 23:40:36 +0200
Message-ID: <20170907214036.GS11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218F4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A1B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A1B@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:09:22PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> SPI driver calls own specific switch register function.
> Shutdown callback function is added to reset switch to default state.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/ksz_spi.c b/drivers/net/dsa/microchip/ksz_spi.c
> index c519469..d03eb83 100644
> --- a/drivers/net/dsa/microchip/ksz_spi.c
> +++ b/drivers/net/dsa/microchip/ksz_spi.c
> @@ -25,6 +25,8 @@
>  
>  #include "ksz_priv.h"
>  
> +int ksz9477_switch_register(struct ksz_device *dev);

Hi Tristram

This should be placed in a header file somewhere, not here.

> +static void ksz_spi_shutdown(struct spi_device *spi) {
> +	struct ksz_device *dev = spi_get_drvdata(spi);
> +
> +	if (dev)
> +		dev->dev_ops->reset(dev);

shutdown seems like a better name for this op, not reset.

> +}
> +
>  static const struct of_device_id ksz_dt_ids[] = {
>  	{ .compatible = "microchip,ksz9477" },
>  	{},
> @@ -207,6 +217,7 @@ static int ksz_spi_remove(struct spi_device *spi)
>  	},
>  	.probe	= ksz_spi_probe,
>  	.remove	= ksz_spi_remove,
> +	.shutdown = ksz_spi_shutdown,
>  };
>  
>  module_spi_driver(ksz_spi_driver);
