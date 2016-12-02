From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH net-next] liquidio: 'imply' ptp instead of 'select'
Date: Fri, 2 Dec 2016 18:20:13 -0500 (EST)
Message-ID: <alpine.LFD.2.20.1612021819350.13571@knanqh.ubzr>
References: <20161202230451.1639318-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        David Daney <david.daney@cavium.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Sunil Goutham <sgoutham@cavium.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202230451.1639318-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Dec 2016, Arnd Bergmann wrote:

> ptp now depends on the optional POSIX_TIMERS setting and fails to build
> if we select it without that:
> 
> warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> warning: (LIQUIDIO_VF && TI_CPTS) selects PTP_1588_CLOCK which has unmet direct dependencies (NET && POSIX_TIMERS)
> ERROR: "posix_clock_unregister" [drivers/ptp/ptp.ko] undefined!
> ERROR: "posix_clock_register" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_unregister_source" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_event" [drivers/ptp/ptp.ko] undefined!
> ERROR: "pps_register_source" [drivers/ptp/ptp.ko] undefined!
> 
> It seems that two patches have collided here, the build failure
> is a result of the combination. Changing the new option to 'imply'
> as well fixes it.
> 
> Fixes: 111fc64a237f ("liquidio CN23XX: VF registration")
> Fixes: d1cbfd771ce8 ("ptp_clock: Allow for it to be optional")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Nicolas Pitre <nico@linaro.org>

> ---
>  drivers/net/ethernet/cavium/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
> index bbc8bd16cb97..dcbce6cac63e 100644
> --- a/drivers/net/ethernet/cavium/Kconfig
> +++ b/drivers/net/ethernet/cavium/Kconfig
> @@ -77,7 +77,7 @@ config OCTEON_MGMT_ETHERNET
>  config LIQUIDIO_VF
>  	tristate "Cavium LiquidIO VF support"
>  	depends on 64BIT && PCI_MSI
> -	select PTP_1588_CLOCK
> +	imply PTP_1588_CLOCK
>  	---help---
>  	  This driver supports Cavium LiquidIO Intelligent Server Adapter
>  	  based on CN23XX chips.
> -- 
> 2.9.0
> 
> 
