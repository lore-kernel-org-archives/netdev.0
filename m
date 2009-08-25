From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH] TI DaVinci EMAC: delay DaVinci EMAC initialization
Date: Tue, 25 Aug 2009 14:21:46 +0300
Message-ID: <87fxbgjfzp.fsf@deeprootsystems.com>
References: <1250714395-9588-1-git-send-email-sudhakar.raj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, davem@davemloft.net
To: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64401 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765AbZHYLVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 07:21:49 -0400
Received: by bwz19 with SMTP id 19so1993729bwz.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 04:21:50 -0700 (PDT)
In-Reply-To: <1250714395-9588-1-git-send-email-sudhakar.raj@ti.com> (Sudhakar Rajashekhara's message of "Wed\, 19 Aug 2009 16\:39\:55 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sudhakar Rajashekhara <sudhakar.raj@ti.com> writes:

> On TI's DA850/OMAP-L138 EVM, MAC address is stored in SPI
> flash which is accessed using MTD interface.
>
> This patch delays the initialization of DaVinci EMAC driver
> by changing module_init to late_initcall. This helps SPI and
> MTD drivers to get initialized before EMAC thereby enabling
> EMAC driver to read the MAC address while booting and use it.
>
> Tested with NFS on DM644x, DM6467, DA830/OMAP-L137 and
> DA850/OMAP-L138 EVMs.
>
> Signed-off-by: Sudhakar Rajashekhara <sudhakar.raj@ti.com>
> Reviewed-by: Chaithrika U S <chaithrika@ti.com>

Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>

> ---
>  drivers/net/davinci_emac.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 12fd446..5e6652b 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -2817,7 +2817,7 @@ static int __init davinci_emac_init(void)
>  {
>  	return platform_driver_register(&davinci_emac_driver);
>  }
> -module_init(davinci_emac_init);
> +late_initcall(davinci_emac_init);
>  
>  /**
>   * davinci_emac_exit: EMAC driver module exit
> -- 
> 1.5.6
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
