From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] [4.11 regression] cpsw/netcp: refine cpts dependency
Date: Fri, 28 Apr 2017 08:15:57 -0700
Message-ID: <20170428151557.GJ3780@atomide.com>
References: <20170428150358.1537030-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Nicolas Pitre <nicolas.pitre@linaro.org>,
        WingMan Kwok <w-kwok2@ti.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:45550 "EHLO muru.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938067AbdD1PQB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 11:16:01 -0400
Content-Disposition: inline
In-Reply-To: <20170428150358.1537030-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Arnd Bergmann <arnd@arndb.de> [170428 08:06]:
> Tony Lindgren reports a kernel oops that resulted from my compile-time
> fix on the default config. This shows two problems:
> 
> a) configurations that did not already enable PTP_1588_CLOCK will
>    now miss the cpts driver
> 
> b) when cpts support is disabled, the driver crashes. This is a
>    preexisting problem that we did not notice before my patch.
> 
> While the second problem is still being investigated, this modifies
> the dependencies again, getting us back to the original state, with
> another 'select NET_PTP_CLASSIFY' added in to avoid the original
> link error we got, and the 'depends on POSIX_TIMERS' to hide
> the CPTS support when turning it on would be useless.
> 
> Cc: stable@vger.kernel.org # 4.11 needs this
> Fixes: 07fef3623407 ("cpsw/netcp: cpts depends on posix_timers")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Adding the Cc: stable in case this doesn't make it into 4.11
> any more.

Thanks this fixes the oops I'm seeing:

Tested-by: Tony Lindgren <tony@atomide.com>

>  drivers/net/ethernet/ti/Kconfig | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index 9e631952b86f..48a541eb0af2 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -76,7 +76,7 @@ config TI_CPSW
>  config TI_CPTS
>  	bool "TI Common Platform Time Sync (CPTS) Support"
>  	depends on TI_CPSW || TI_KEYSTONE_NETCP
> -	depends on PTP_1588_CLOCK
> +	depends on POSIX_TIMERS
>  	---help---
>  	  This driver supports the Common Platform Time Sync unit of
>  	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
> @@ -87,6 +87,8 @@ config TI_CPTS_MOD
>  	tristate
>  	depends on TI_CPTS
>  	default y if TI_CPSW=y || TI_KEYSTONE_NETCP=y
> +	select NET_PTP_CLASSIFY
> +	imply PTP_1588_CLOCK
>  	default m
>  
>  config TI_KEYSTONE_NETCP
> -- 
> 2.9.0
> 
