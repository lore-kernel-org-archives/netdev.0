From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH 08/15] ixgbe: use IS_ENABLED() instead of checking for
 built-in or module
Date: Mon, 12 Sep 2016 08:36:03 -0700
Message-ID: <1473694563.4320.4.camel@gmail.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
         <1473689026-6983-9-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Javier Martinez Canillas <javier@osg.samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-9-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-09-12 at 10:03 -0400, Javier Martinez Canillas wrote:
> The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
> built-in or as a module, use that macro instead of open coding the same.
> 
> Using the macro makes the code more readable by helping abstract away some
> of the Kconfig built-in and module enable details.
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
> ---
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> index 33c025055011..b06e32d0d22a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
> @@ -45,10 +45,10 @@
>  #include "ixgbe_type.h"
>  #include "ixgbe_common.h"
>  #include "ixgbe_dcb.h"
> -#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
> +#if IS_ENABLED(CONFIG_FCOE)

I was wondering what happens if CONFIG_FCOE_MODULE is defined but not
CONFIG_FCOE but then couldn't even find CONFIG_FCOE_MODULE in any
Kconfigs anywhere in the current tree.

Looks good to me.

      * Reviewed-by: Greg Rose <grose@lightfleet.com>

>  #define IXGBE_FCOE
>  #include "ixgbe_fcoe.h"
> -#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
> +#endif /* IS_ENABLED(CONFIG_FCOE) */
>  #ifdef CONFIG_IXGBE_DCA
>  #include <linux/dca.h>
>  #endif
