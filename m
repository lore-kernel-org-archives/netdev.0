From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] [v2, -net] cpsw/netcp: cpts depends on posix_timers
Date: Mon, 20 Mar 2017 20:17:16 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1703202016420.2304@knanqh.ubzr>
References: <20170320085849.1038064-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        "David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>,
        WingMan Kwok <w-kwok2@ti.com>,
        =?ISO-8859-15?Q?Uwe_Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170320085849.1038064-1-arnd@arndb.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Mar 2017, Arnd Bergmann wrote:

> With posix timers having become optional, we get a build error with
> the cpts time sync option of the CPSW driver:
> 
> drivers/net/ethernet/ti/cpts.c: In function 'cpts_find_ts':
> drivers/net/ethernet/ti/cpts.c:291:23: error: implicit declaration of function 'ptp_classify_raw';did you mean 'ptp_classifier_init'? [-Werror=implicit-function-declaration]
> 
> This adds a hard dependency on PTP_CLOCK to avoid the problem, as
> building it without PTP support makes no sense anyway.
> 
> Fixes: baa73d9e478f ("posix-timers: Make them configurable")
> Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Nicolas Pitre <nico@linaro.org>

> ---
> v2: use 'depends on' instead of 'select' as suggested by Nico.
> ---
>  drivers/net/ethernet/ti/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index d923890a9fda..9e631952b86f 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -76,7 +76,7 @@ config TI_CPSW
>  config TI_CPTS
>  	bool "TI Common Platform Time Sync (CPTS) Support"
>  	depends on TI_CPSW || TI_KEYSTONE_NETCP
> -	imply PTP_1588_CLOCK
> +	depends on PTP_1588_CLOCK
>  	---help---
>  	  This driver supports the Common Platform Time Sync unit of
>  	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
> -- 
> 2.9.0
> 
> 
