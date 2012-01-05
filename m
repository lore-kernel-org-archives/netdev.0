From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 05 Jan 2012 15:45:02 -0800
Message-ID: <4F0635FE.6050507@xenotime.net>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gwingerde@gmail.com,
	larry.finger@lwfinger.net, davem@davemloft.net,
	bhutchings@solarflare.com, greg@kroah.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325796541-11402-1-git-send-email-festevam@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/2012 12:49 PM, Fabio Estevam wrote:
> MISC_DEVICES option alone does not select any kernel code and can cause dependency build warnings, such as:
> 
> warning: (KS8851 && AX88796_93CX6 && RTL8180 && RTL8187 && ADM8211 && RT2400PCI && RT2500PCI && RT61PCI && RT2800PCI && R8187SE) selects EEPROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)
> 
> Remove MISC_DEVICES option so that any dependency on this symbol is avoided.

I thought that one purpose of MISC_DEVICES was to allow anyone to disable all
options under it with one click (or keystroke), but since several drivers now
"select MISC_DEVICES", that does not work.

I would like to be able to disable all MISC_DEVICES, but since that
does not currently function, this change is OK with me.


> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> This applies against linux-next
> 
>  drivers/misc/Kconfig                |   17 +++--------------
>  drivers/mmc/host/Kconfig            |    1 -
>  drivers/net/ethernet/micrel/Kconfig |    1 -
>  3 files changed, 3 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
> index 6a1a092..c779509 100644
> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -2,24 +2,14 @@
>  # Misc strange devices
>  #
>  
> -# This one has to live outside of the MISC_DEVICES conditional,
> -# because it may be selected by drivers/platform/x86/hp_accel.
> +menu "Misc devices"
> +
>  config SENSORS_LIS3LV02D
>  	tristate
>  	depends on INPUT
>  	select INPUT_POLLDEV
>  	default n
>  
> -menuconfig MISC_DEVICES
> -	bool "Misc devices"
> -	---help---
> -	  Say Y here to get to see options for device drivers from various
> -	  different categories. This option alone does not add any kernel code.
> -
> -	  If you say N, all options in this submenu will be skipped and disabled.
> -
> -if MISC_DEVICES
> -
>  config AD525X_DPOT
>  	tristate "Analog Devices Digital Potentiometers"
>  	depends on (I2C || SPI) && SYSFS
> @@ -516,5 +506,4 @@ source "drivers/misc/ti-st/Kconfig"
>  source "drivers/misc/lis3lv02d/Kconfig"
>  source "drivers/misc/carma/Kconfig"
>  source "drivers/misc/altera-stapl/Kconfig"
> -
> -endif # MISC_DEVICES
> +endmenu
> diff --git a/drivers/mmc/host/Kconfig b/drivers/mmc/host/Kconfig
> index cf444b0..00fcbed 100644
> --- a/drivers/mmc/host/Kconfig
> +++ b/drivers/mmc/host/Kconfig
> @@ -477,7 +477,6 @@ config MMC_SDHI
>  config MMC_CB710
>  	tristate "ENE CB710 MMC/SD Interface support"
>  	depends on PCI
> -	select MISC_DEVICES
>  	select CB710_CORE
>  	help
>  	  This option enables support for MMC/SD part of ENE CB710/720 Flash
> diff --git a/drivers/net/ethernet/micrel/Kconfig b/drivers/net/ethernet/micrel/Kconfig
> index 1ea811c..fe42fc0 100644
> --- a/drivers/net/ethernet/micrel/Kconfig
> +++ b/drivers/net/ethernet/micrel/Kconfig
> @@ -42,7 +42,6 @@ config KS8851
>  	select NET_CORE
>  	select MII
>  	select CRC32
> -	select MISC_DEVICES
>  	select EEPROM_93CX6
>  	---help---
>  	  SPI driver for Micrel KS8851 SPI attached network chip.


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
