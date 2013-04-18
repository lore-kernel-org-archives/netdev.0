From: Greg Ungerer <gerg@uclinux.org>
Subject: Re: [PATCH] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 22:00:26 +1000
Message-ID: <516FE05A.2030604@uclinux.org>
References: <1366251498-11677-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail02.westnet.com.au ([203.10.1.243]:30924 "EHLO
	outbound-mail02.westnet.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755023Ab3DRMAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:00:33 -0400
In-Reply-To: <1366251498-11677-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fabio,

On 18/04/13 12:18, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> There is nothing in the driver that requires asm header files.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Greg,
> 
> I built this for ARM and x86 (tweaking Kconfig), but I don't have a m68k 
> toolchain installed here to test it.
> 
> Please build it for m68k if you have a chance. Thanks
> 
>  drivers/net/ethernet/freescale/fec_main.c |    7 -------

fec_main.c?  That doesn't exist in linux-3.9-rc7.
Comments and tests below based on fec.c in linux-3.9-rc7.


>  1 file changed, 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 719177b..22c0feb 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -50,13 +50,6 @@
>  #include <linux/pinctrl/consumer.h>
>  #include <linux/regulator/consumer.h>
>  
> -#include <asm/cacheflush.h>

There is a rather bogus looking call to flush_cache_all() conditional
on CONFIG_M532x, and I suspect removing this include will break that.


> -
> -#ifndef CONFIG_ARM
> -#include <asm/coldfire.h>
> -#include <asm/mcfsim.h>
> -#endif

No problem with this part. I compiled for a couple of ColdFire targets
and this is ok.

Regards
Greg
