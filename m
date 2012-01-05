From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 5 Jan 2012 19:17:58 +0000
Message-ID: <1325791078.3764.30.camel@bwh-desktop>
References: <1325770673-17309-1-git-send-email-festevam@gmail.com>
	 <4F05CBA9.1070602@lwfinger.net>
	 <20120105.122004.1170447281304011158.davem@davemloft.net>
	 <CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>
	 <CAOMZO5DTDpp8+9FOjPXGFQtQPg7Pv5qfAwFO3UC6AUdEDgpHYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <Larry.Finger@lwfinger.net>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<gwingerde@gmail.com>, <linville@tuxdriver.com>,
	<fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25320 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932235Ab2AETSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:18:09 -0500
In-Reply-To: <CAOMZO5DTDpp8+9FOjPXGFQtQPg7Pv5qfAwFO3UC6AUdEDgpHYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-05 at 17:02 -0200, Fabio Estevam wrote:
> On Thu, Jan 5, 2012 at 4:06 PM, Fabio Estevam <festevam@gmail.com> wrote:
> 
> > I have tried selecting MISC_DEVICES in the Kconfig's, but the warning remains.
> >
> > I agree with Ben's comment: "That seems like a bug, since MISC_DEVICES
> > doesn't by itself select any
> > code.  (It's also not a meaningful category and maybe ought not to be an
> > option at all.)"
> 
> What about the aproach below?
> 
> drivers/misc/Kconfig |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
> index 6a1a092..9c7a474 100644
> --- a/drivers/misc/Kconfig
> +++ b/drivers/misc/Kconfig
> @@ -10,15 +10,8 @@ config SENSORS_LIS3LV02D
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
> +menu "Misc devices"
> 
> -if MISC_DEVICES
> 
>  config AD525X_DPOT
>  	tristate "Analog Devices Digital Potentiometers"
> @@ -516,5 +509,4 @@ source "drivers/misc/ti-st/Kconfig"
>  source "drivers/misc/lis3lv02d/Kconfig"
>  source "drivers/misc/carma/Kconfig"
>  source "drivers/misc/altera-stapl/Kconfig"
> -
> -endif # MISC_DEVICES
> +endmenu

Yes, that's what I was thinking of.

> This would remove the unneeded dependency of MISC_DEVICES.
> 
> I know I need to take extra care not to break other things, but just
> would like to get a feedback if this approach goes into the right
> direction.

Right, you'll have to delete all dependencies on MISC_DEVICES.  Maybe
remove it from defconfigs as well, though I'm not sure whether it's
normal to do that at the same time.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
