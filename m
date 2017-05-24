From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v6 net-next 01/17] net: qualcomm: remove unnecessary
 includes
Date: Wed, 24 May 2017 15:41:11 -0400 (EDT)
Message-ID: <20170524.154111.404338711401048909.davem@davemloft.net>
References: <1495545173-22150-1-git-send-email-stefan.wahren@i2se.com>
        <1495545173-22150-2-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, jslaby-IBi9RG/b67k@public.gmane.org, LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org,
        kubakici-5tc4TXWwyLM@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefan.wahren-eS4NqCHxEME@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1495545173-22150-2-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Date: Tue, 23 May 2017 15:12:37 +0200

> Most of the includes in qca_7k.c are unnecessary so we better remove them.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> ---
>  drivers/net/ethernet/qualcomm/qca_7k.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
> index f0066fb..557d53c 100644
> --- a/drivers/net/ethernet/qualcomm/qca_7k.c
> +++ b/drivers/net/ethernet/qualcomm/qca_7k.c
> @@ -23,11 +23,7 @@
>   *   kernel-based SPI device.
>   */
>  
> -#include <linux/init.h>
> -#include <linux/module.h>
> -#include <linux/moduleparam.h>
>  #include <linux/spi/spi.h>
> -#include <linux/version.h>
>  
>  #include "qca_7k.h"
>  
> -- 
> 2.1.4
> 

Changes like this drive me crazy.

The only reason you can remove those headers is because you are obtaining
things indirectly via qca_7k.h

And if that is indeed the case, you are also getting qca_spi.h which
in turn includes linux/spi/spi.h

So you could have removed that as well.

But seriously, it is so much harder to understand a driver and what
interfaces it needs via header files when you hide _all_ of it behind
these local private header files which just include _everything_
and then _every_ foo.c file in your driver gets _all_ of those kernel
headers whether they need it or not.

So if just one foo.c file needs 20 extra kernel headers than the rest
of the files in the driver, every foo.c file eats that cost of
including them.

I really don't like when drivers move in this direction for that
reason.  And at best, as described at the beginning of my response,
this change is incomplete.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
