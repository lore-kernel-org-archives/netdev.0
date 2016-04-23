From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 2/2] net: ethernet: enc28j60: add device tree support
Date: Sun, 24 Apr 2016 00:20:24 +0200
Message-ID: <31567588.rB9VrggOb6@wuerfel>
References: <1461447800-11381-1-git-send-email-mhei@heimpold.de> <1461447800-11381-3-git-send-email-mhei@heimpold.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: Michael Heimpold <mhei@heimpold.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:60189 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbcDWWUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 18:20:46 -0400
In-Reply-To: <1461447800-11381-3-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 April 2016 23:43:20 Michael Heimpold wrote:
> diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
> index b723622..49635d7 100644
> --- a/drivers/net/ethernet/microchip/enc28j60.c
> +++ b/drivers/net/ethernet/microchip/enc28j60.c
> @@ -1634,9 +1634,20 @@ static int enc28j60_remove(struct spi_device *spi)
>         return 0;
>  }
>  
> +#ifdef CONFIG_OF
> +static const struct of_device_id enc28j60_dt_ids[] = {
> +       { .compatible = "microchip,enc28j60" },
> +       { /* sentinel */ }
> +};
> +MODULE_DEVICE_TABLE(of, enc28j60_dt_ids);
> +#else
> +#define enc28j60_dt_ids NULL
> +#endif
> +
>  static struct spi_driver enc28j60_driver = {
>         .driver = {
> -                  .name = DRV_NAME,
> +               .name = DRV_NAME,
> +               .of_match_table = enc28j60_dt_ids,
>          },
>         .probe = enc28j60_probe,
>         .remove = enc28j60_remove,
> -- 
> 

You probably also want to add support for calling of_get_mac_address()
here, to allow giving the device a fixed address from the boot loader.

I think you can drop the #ifdef and just define the device table
unconditionally.

	Arnd
