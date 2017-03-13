From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [RESEND PATCH -net] cpsw/netcp: cpts depends on posix_timers
Date: Mon, 13 Mar 2017 16:09:48 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1703131608100.14436@knanqh.ubzr>
References: <20170313165849.1378558-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        John Stultz <john.stultz@linaro.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170313165849.1378558-1-arnd@arndb.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Mar 2017, Arnd Bergmann wrote:

> With posix timers having become optional, we get a build error with
> the cpts time sync option of the CPSW driver:
> 
> drivers/net/ethernet/ti/cpts.c: In function 'cpts_find_ts':
> drivers/net/ethernet/ti/cpts.c:291:23: error: implicit declaration of function 'ptp_classify_raw';did you mean 'ptp_classifier_init'? [-Werror=implicit-function-declaration]
> 
> It really makes no sense to build this driver if we can't use PTP,
> so it's better to go back to 'select PTP_1588_CLOCK' but instead
> add a dependency on POSIX_TIMERS. Adding 'depends on PTP_1588_CLOCK'
> might also work, but has the risk of circular dependencies when
> mixed with other drivers using 'imply'.

Could you elaborate on that risk please?


> Fixes: baa73d9e478f ("posix-timers: Make them configurable")
> Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Originally submitted on Dec 16, but not applied after I missed a
> reply from Nico. I confirmed that this is still needed for v4.10
> and v4.11-rc2 and am resending it without changes.
> ---
>  drivers/net/ethernet/ti/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> index d42257fbe9d9..c114efcd1575 100644
> --- a/drivers/net/ethernet/ti/Kconfig
> +++ b/drivers/net/ethernet/ti/Kconfig
> @@ -76,7 +76,8 @@ config TI_CPSW
>  config TI_CPTS_ENABLE
>  	bool "TI Common Platform Time Sync (CPTS) Support"
>  	depends on TI_CPSW || TI_KEYSTONE_NETCP
> -	imply PTP_1588_CLOCK
> +	depends on POSIX_TIMERS
> +	select PTP_1588_CLOCK
>  	---help---
>  	  This driver supports the Common Platform Time Sync unit of
>  	  the CPSW Ethernet Switch and Keystone 2 1g/10g Switch Subsystem.
> -- 
> 2.9.0
> 
> 
