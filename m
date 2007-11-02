From: Adrian Bunk <bunk@kernel.org>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
	`usbnet_set_settings':
Date: Fri, 2 Nov 2007 19:57:51 +0100
Message-ID: <20071102185751.GV30287@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711011632.18333.david-b@pacbell.net> <20071101234443.GD7227@stusta.de> <200711021145.15542.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:59313 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754889AbXKBS6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 14:58:16 -0400
Content-Disposition: inline
In-Reply-To: <200711021145.15542.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2007 at 11:45:15AM -0700, David Brownell wrote:
> On Thursday 01 November 2007, Adrian Bunk wrote:
> > The following combination of options is simply an unusual one:
> > 
> > CONFIG_MII=m
> > CONFIG_USB_USBNET=y
> > CONFIG_USB_USBNET_MII=n
> 
> I though that had been fixed for ages ...
> 
> This should do a better job of it.
> 
> - Dave
> 
> ==========	CUT HERE
> Simplify handling of the MII-dependent usbnet based adapters:  stick
> to forward dependencies, and explicitly handle the core dependency.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> ---
>  drivers/net/usb/Kconfig  |   23 ++++++++++++-----------
>  drivers/net/usb/usbnet.c |    9 ++++++++-
>  2 files changed, 20 insertions(+), 12 deletions(-)
> 
> --- a.orig/drivers/net/usb/Kconfig	2007-10-21 10:35:16.000000000 -0700
> +++ a/drivers/net/usb/Kconfig	2007-11-02 11:32:15.000000000 -0700
> @@ -93,13 +93,8 @@ config USB_RTL8150
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called rtl8150.
>  
> -config USB_USBNET_MII
> -	tristate
> -	default n
> -
>  config USB_USBNET
>  	tristate "Multi-purpose USB Networking Framework"
> -	select MII if USB_USBNET_MII != n
>  	---help---
>  	  This driver supports several kinds of network links over USB,
>  	  with "minidrivers" built around a common network driver core
> @@ -131,11 +126,19 @@ config USB_USBNET
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called usbnet.
>  
> +# usbnet core will support MII when MII is static, or both are modules
> +config USB_NET_MII
> +	tristate
> +	depends on USB_USBNET && NET_ETHERNET && (MII = y || MII = USB_USBNET)
> +	default MII
> +
> +comment "MII support is needed for most Ethernet adapters"
> +	depends on USB_USBNET && USB_NET_MII=n
>...

This approach has two disadvantages:
- it's complicated
- the MII stuff is an implementation detail, and we shouldn't bother
  the user with it (especially since we can do better)

If you want to keep the #ifdef's, what's the problem with the second 
patch I proposed to fix this bug?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

