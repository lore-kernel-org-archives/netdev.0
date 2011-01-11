From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Tue, 11 Jan 2011 11:27:17 +0100
Message-ID: <20110111102717.GG26617@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, u.kleine-koenig@pengutronix.de,
	lw@karo-electronics.de, w.sang@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50287 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541Ab1AKK1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 05:27:45 -0500
Content-Disposition: inline
In-Reply-To: <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 06, 2011 at 03:13:13PM +0800, Shawn Guo wrote:
> This patch is to add mx28 dual fec support. Here are some key notes
> for mx28 fec controller.
> 
>  - The mx28 fec controller naming ENET-MAC is a different IP from FEC
>    used on other i.mx variants.  But they are basically compatible
>    on software interface, so it's possible to share the same driver.
>  - ENET-MAC design on mx28 made an improper assumption that it runs
>    on a big-endian system. As the result, driver has to swap every
>    frame going to and coming from the controller.
>  - The external phys can only be configured by fec0, which means fec1
>    can not work independently and both phys need to be configured by
>    mii_bus attached on fec0.
>  - ENET-MAC reset will get mac address registers reset too.
>  - ENET-MAC MII/RMII mode and 10M/100M speed are configured
>    differently FEC.
>  - ETHER_EN bit must be set to get ENET-MAC interrupt work.
> 
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v4:
>  - Use #ifndef CONFIG_ARM to include ColdFire header files
>  - Define quirk bits in id_entry.driver_data to handle controller
>    difference, which is more scalable than using device name
>  - Define fec0_mii_bus as a static function in fec_enet_mii_init
>    to fold the mii_bus instance attached on fec0
>  - Use cpu_to_be32 over __swab32 in function swap_buffer
> 
> Changes for v3:
>  - Move v2 changes into patch #3
>  - Use device name to check if it's running on ENET-MAC
> 
>  drivers/net/Kconfig |    7 ++-
>  drivers/net/fec.c   |  148 +++++++++++++++++++++++++++++++++++++++++++++------
>  drivers/net/fec.h   |    5 +-
>  3 files changed, 139 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 4f1755b..f34629b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1944,18 +1944,19 @@ config 68360_ENET
>  config FEC
>  	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
>  	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
> -		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5
> +		MACH_MX27 || ARCH_MX35 || ARCH_MX25 || ARCH_MX5 || SOC_IMX28
>  	select PHYLIB
>  	help
>  	  Say Y here if you want to use the built-in 10/100 Fast ethernet
>  	  controller on some Motorola ColdFire and Freescale i.MX processors.
>  
>  config FEC2
> -	bool "Second FEC ethernet controller (on some ColdFire CPUs)"
> +	bool "Second FEC ethernet controller"
>  	depends on FEC
>  	help
>  	  Say Y here if you want to use the second built-in 10/100 Fast
> -	  ethernet controller on some Motorola ColdFire processors.
> +	  ethernet controller on some Motorola ColdFire and Freescale
> +	  i.MX processors.

This option is used nowhere and should be removed. Certainly it does not
have the effect of enabling the second ethernet controller.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
