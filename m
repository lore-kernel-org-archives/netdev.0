From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: spi_ks8995: remove sysfs bin file by registered
 attribute
Date: Tue, 04 Nov 2014 10:15:22 -0800
Message-ID: <545917BA.50800@gmail.com>
References: <1415057109-8506-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Vladimir Zapolskiy <vz@mleia.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:54493 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbaKDSPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 13:15:55 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so14149672pdi.30
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 10:15:55 -0800 (PST)
In-Reply-To: <1415057109-8506-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2014 03:25 PM, Vladimir Zapolskiy wrote:
> When a sysfs binary file is asked to be removed, it is found by
> attribute name, so strictly speaking this change is not a fix, but
> just in case when attribute name is changed in the driver or sysfs
> internals are changed, it might be better to remove the previously
> created file using right the same binary attribute.
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/spi_ks8995.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
> index eab57fc..4653015 100644
> --- a/drivers/net/phy/spi_ks8995.c
> +++ b/drivers/net/phy/spi_ks8995.c
> @@ -353,7 +353,9 @@ static int ks8995_probe(struct spi_device *spi)
>  
>  static int ks8995_remove(struct spi_device *spi)
>  {
> -	sysfs_remove_bin_file(&spi->dev.kobj, &ks8995_registers_attr);
> +	struct ks8995_switch *ks = spi_get_drvdata(spi);
> +
> +	sysfs_remove_bin_file(&spi->dev.kobj, &ks->regs_attr);
>  
>  	return 0;
>  }
> 
