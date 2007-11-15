From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET: Officially deprecate "ether=" in favour of "netdev=".
Date: Wed, 14 Nov 2007 21:31:00 -0800
Message-ID: <473BD994.2070809@linux-foundation.org>
References: <alpine.LFD.0.9999.0711142318370.4120@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux M68K mailing list <linux-m68k@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Robert P. J. Day" <rpjday@crashcourse.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38980 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750806AbXKOFbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 00:31:20 -0500
In-Reply-To: <alpine.LFD.0.9999.0711142318370.4120@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert P. J. Day wrote:
> Given that it's well established that the "ether=" kernel parameter is
> deprecated in favour of the newer "netdev=", might as well make it
> official.
>
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
>
> ---
>
>  Documentation/feature-removal-schedule.txt |    6 ++++++
>  Documentation/kernel-parameters.txt        |    2 ++
>  Documentation/m68k/kernel-options.txt      |    6 +++++-
>  Documentation/networking/3c505.txt         |    3 ++-
>  drivers/net/3c59x.c                        |    3 ++-
>  drivers/net/atp.c                          |    2 +-
>  drivers/net/es3210.c                       |    5 +++++
>  net/ethernet/eth.c                         |   13 ++++++++++++-
>  8 files changed, 35 insertions(+), 5 deletions(-)
>
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> index 20c4c8b..5c041fd 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -333,3 +333,9 @@ Why:	This driver has been marked obsolete for many years.
>  Who:	Stephen Hemminger <shemminger@linux-foundation.org>
>
>  ---------------------------
> +
> +What:	"ether=" boot-time option
> +When:	September 2008
> +Why:	Obsoleted by newer and equivalent "netdev=" option.
> +Who:	Robert P. J. Day <rpjday@crashcourse.ca> or whoever else wants to
> +	do it when the time comes.
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index 33121d6..8b2676b 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -623,6 +623,8 @@ and is between 256 and 4096 characters. It is defined in the file
>  	ether=		[HW,NET] Ethernet cards parameters
>  			This option is obsoleted by the "netdev=" option, which
>  			has equivalent usage. See its documentation for details.
> +			"ether=" has been scheduled for removal -- see the file
> +			Documentation/feature-removal-schedule.txt.
>
>  	eurwdt=		[HW,WDT] Eurotech CPU-1220/1410 onboard watchdog.
>  			Format: <io>[,<irq>]
> diff --git a/Documentation/m68k/kernel-options.txt b/Documentation/m68k/kernel-options.txt
> index 248589e..9aab529 100644
> --- a/Documentation/m68k/kernel-options.txt
> +++ b/Documentation/m68k/kernel-options.txt
> @@ -218,7 +218,7 @@ drive (with "root=").
>  3) General Device Options (Amiga and Atari)
>  ===========================================
>
> -3.1) ether=
> +3.1) ether=  [Equivalently, netdev=]
>  -----------
>
>  Syntax: ether=[<irq>[,<base_addr>[,<mem_start>[,<mem_end>]]]],<dev-name>
> @@ -233,6 +233,10 @@ Linux/m68k (ariadne, a2065, hydra) don't use them because Zorro boards
>  are really Plug-'n-Play, so the "ether=" option is useless altogether
>  for Linux/m68k.
>
> +  NOTE:  The "ether=" option is deprecated in favour of the newer
> +"netdev=" option.  "ether=" has been scheduled for removal -- see the
> +file Documentation/feature-removal-schedule.txt for details.
> +
>
>  3.2) hd=
>  --------
> diff --git a/Documentation/networking/3c505.txt b/Documentation/networking/3c505.txt
> index 72f38b1..0498775 100644
> --- a/Documentation/networking/3c505.txt
> +++ b/Documentation/networking/3c505.txt
> @@ -5,7 +5,8 @@ The default DMA channel is 6; this is _not_ autoprobed, so you must
>  make sure you configure it correctly.  If loading the driver as a
>  module, you can do this with "modprobe 3c505 dma=n".  If the driver is
>  linked statically into the kernel, you must either use an "ether="
> -statement on the command line, or change the definition of ELP_DMA in 3c505.h.
> +(or equivalent and preferred "netdev=") statement on the command line,
> +or change the definition of ELP_DMA in 3c505.h.
>
>  The driver will warn you if it has to fall back on the compiled in
>  default DMA channel.
> diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
> index 6f8e7d4..8268962 100644
> --- a/drivers/net/3c59x.c
> +++ b/drivers/net/3c59x.c
> @@ -1046,7 +1046,8 @@ static int __devinit vortex_probe1(struct device *gendev,
>  	if (dev->mem_start) {
>  		/*
>  		 * The 'options' param is passed in as the third arg to the
> -		 * LILO 'ether=' argument for non-modular use
> +		 * LILO 'ether=' (or equivalent and preferred 'netdev=') argument
> +		 * for non-modular use
>  		 */
>  		option = dev->mem_start;
>  	}
> diff --git a/drivers/net/atp.c b/drivers/net/atp.c
> index 62f09e5..1cf5c17 100644
> --- a/drivers/net/atp.c
> +++ b/drivers/net/atp.c
> @@ -114,7 +114,7 @@ static int xcvr[NUM_UNITS]; 			/* The data transfer mode. */
>
>  	The data transfer mode is stored in the 'dev->if_port' field.  Its default
>  	value is '4'.  It may be overridden at boot-time using the third parameter
> -	to the "ether=..." initialization.
> +	to the "ether=..." (or equivalent and preferred "netdev=...") initialization.
>
>  	The header file <atp.h> provides inline functions that encapsulate the
>  	register and data access methods.  These functions are hand-tuned to
> diff --git a/drivers/net/es3210.c b/drivers/net/es3210.c
> index deefa51..51a66eb 100644
> --- a/drivers/net/es3210.c
> +++ b/drivers/net/es3210.c
> @@ -40,6 +40,11 @@
>  	   these registers is disabled there. In the meantime, boot with:
>  	   ether=<IRQ>,0,0x<shared_mem_addr>,eth0 to override the IRQ and
>  	   shared memory detection. (The i/o port detection is okay.)
> +
> +	   NOTE:  The "ether=" option has been deprecated in favour of the
> +	   newer and equivalent "netdev=" option, and has been scheduled for
> +	   removal.  See Documentation/feature-removal-schedule.txt for
> +	   details.
>
>  	2) Module support currently untested. Probably works though.
>
> diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
> index 6b2e454..29a0217 100644
> --- a/net/ethernet/eth.c
> +++ b/net/ethernet/eth.c
> @@ -31,6 +31,8 @@
>   *				  older network drivers and IFF_ALLMULTI.
>   *	Christer Weinigel	: Better rebuild header message.
>   *             Andrew Morton    : 26Feb01: kill ether_setup() - use netdev_boot_setup().
> + *             Robert P. J. Day : Add ether_boot_setup() to allow deprecation warning
> +				  for "ether=" boot-time option.
>   *
>   
We don't use comments for changelog any more, please don't add any.

>   *		This program is free software; you can redistribute it and/or
>   *		modify it under the terms of the GNU General Public License
> @@ -60,7 +62,16 @@
>  #include <asm/uaccess.h>
>  #include <asm/system.h>
>
> -__setup("ether=", netdev_boot_setup);
> +static int __init
> +ether_boot_setup(char *str)
> +{
> +	printk(KERN_NOTICE "The 'ether' option is deprecated and "
> +		"is scheduled for removal in late 2008\n");
> +	printk(KERN_NOTICE "Use 'netdev=<value>' instead\n");
> +	return netdev_boot_setup(str);
> +}
> +
> +__setup("ether=", ether_boot_setup);
>
>   
Why bother. I would removing it?

Actually setting the network up from command line is a nuisance anyway:
   * device names change after boot up on most systems
   * it scales badly to lots of devices
   * format of values is driver specific and include pre-device scanning 
stuff (base address, irq, etc)
IMHO both forms of setup should be relegated to the legacy dust bin, and 
just use standard setup
tools via init ram disk if needed.
