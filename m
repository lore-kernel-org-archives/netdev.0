From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 1/1] netdev: DM9000: Added typecasting to supress some warnings on Blackfin
Date: Mon, 13 Oct 2008 10:17:25 +0100
Message-ID: <20081013091725.GG31627@trinity.fluff.org>
References: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ben@simtec.co.uk, s.hauer@pengutronix.de, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Javier Herrero <jherrero@hvsistemas.es>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.fluff.org ([89.145.97.151]:49463 "EHLO
	trinity.fluff.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbYJMJRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 05:17:38 -0400
Content-Disposition: inline
In-Reply-To: <1223889009-31336-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 05:10:09PM +0800, Bryan Wu wrote:
> From: Javier Herrero <jherrero@hvsistemas.es>

No, your arch definitions of writesb and co are wrong if they
are not taking 'void __iomem *' arguments.
 
> Signed-off-by: Javier Herrero <jherrero@hvsistemas.es>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  drivers/net/dm9000.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> index f42c23f..c4737ca 100644
> --- a/drivers/net/dm9000.c
> +++ b/drivers/net/dm9000.c
> @@ -188,35 +188,35 @@ iow(board_info_t * db, int reg, int value)
>  
>  static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
>  {
> -	writesb(reg, data, count);
> +	writesb((int)reg, data, count);
>  }
>  
>  static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
>  {
> -	writesw(reg, data, (count+1) >> 1);
> +	writesw((int)reg, data, (count+1) >> 1);
>  }
>  
>  static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
>  {
> -	writesl(reg, data, (count+3) >> 2);
> +	writesl((int)reg, data, (count+3) >> 2);
>  }
>  
>  /* input block from chip to memory */
>  
>  static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
>  {
> -	readsb(reg, data, count);
> +	readsb((int)reg, data, count);
>  }
>  
>  
>  static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
>  {
> -	readsw(reg, data, (count+1) >> 1);
> +	readsw((int)reg, data, (count+1) >> 1);
>  }
>  
>  static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
>  {
> -	readsl(reg, data, (count+3) >> 2);
> +	readsl((int)reg, data, (count+3) >> 2);
>  }
>  
>  /* dump block from chip to null */
> -- 
> 1.5.6

-- 
-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.

