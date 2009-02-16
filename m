From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 27/43] drivers/net/sfc: fix sparse warnings: Should it be static?
Date: Mon, 16 Feb 2009 00:37:19 +0000
Message-ID: <20090216003718.GN15266@solarflare.com>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214214111.24377.87888.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:45628 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753550AbZBPAha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 19:37:30 -0500
Content-Disposition: inline
In-Reply-To: <20090214214111.24377.87888.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Eder wrote:
> Impact: Include header file and include the function under the same
> condition as in the header file.  If CONFIG_SFS_MTD is not defined
> than the functions 'efx_mtd_remove' and 'efx_mtd_rename' are defined
> 'static inline' with an empty function body in the header file.
> 
> Fix this sparse warnings:
>   drivers/net/sfc/mtd.c:204:6: warning: symbol 'efx_mtd_remove' was not declared. Should it be static?
>   drivers/net/sfc/mtd.c:221:6: warning: symbol 'efx_mtd_rename' was not declared. Should it be static?
>   drivers/net/sfc/mtd.c:230:5: warning: symbol 'efx_mtd_probe' was not declared. Should it be static?
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/net/sfc/mtd.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
> index 665cafb..94c9ed8 100644
> --- a/drivers/net/sfc/mtd.c
> +++ b/drivers/net/sfc/mtd.c
> @@ -15,6 +15,7 @@
>  #define EFX_DRIVER_NAME "sfc_mtd"
>  #include "net_driver.h"
>  #include "spi.h"
> +#include "efx.h"
>  
>  #define EFX_SPI_VERIFY_BUF_LEN 16
>  

OK, but...

> @@ -201,6 +202,7 @@ static void efx_mtd_sync(struct mtd_info *mtd)
>  	return;
>  }
>  
> +#ifdef CONFIG_SFC_MTD
>  void efx_mtd_remove(struct efx_nic *efx)
>  {
>  	if (efx->spi_flash && efx->spi_flash->mtd) {
> @@ -266,3 +268,4 @@ int efx_mtd_probe(struct efx_nic *efx)
>  
>  	return 0;
>  }
> +#endif /* CONFIG_SFC_MTD */

This is wrong.  The entire file is conditional on CONFIG_SFC_MTD.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
