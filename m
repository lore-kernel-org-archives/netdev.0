From: Greg Ungerer <gregungerer00@gmail.com>
Subject: Re: [PATCH] fec: Remove unneeded asm header files
Date: Thu, 18 Apr 2013 21:56:43 +1000
Message-ID: <516FDF7B.10808@gmail.com>
References: <1366251498-11677-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gerg@uclinux.org, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:61890 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab3DRL4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 07:56:49 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so1547442pad.12
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 04:56:49 -0700 (PDT)
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

fec_main.c?  It doesn't exist in 3.9-rc7.
Comments and tests below based on fec.c in 3.9-rc7.


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

There is a very bogus looking call to flush_cache_all() conditional on
CONFIG_M532x, and I suspect this won't compile if you take this out.


> -
> -#ifndef CONFIG_ARM
> -#include <asm/coldfire.h>
> -#include <asm/mcfsim.h>
> -#endif

No problem with this part. I tested on a couple of ColdFire targets with
this and they still compile ok.

Regards
Greg
