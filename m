From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Sun, 25 Jul 2010 13:24:14 +0200
Message-ID: <4C4C1EDE.7020400@hartkopp.net>
References: <1279816844-12138-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, davem@davemloft.net
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:15970 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286Ab0GYLYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 07:24:13 -0400
In-Reply-To: <1279816844-12138-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Marc,

first of all thanks for your contribution of the flexcan driver!

But i have a question regarding the Kconfig change that has been finally
committed to net-next-2.6.

It looks like the pulled code has some extra HAVE_CAN_FLEXCAN config option -
which may be something of your debugging environment - which was not part of
the original posted patch, where CAN_FLEXCAN depended on (ARCH_MX25 || ARCH_MX35).

Please see the two posted sections below ...

The depency of (ARCH_MX25 || ARCH_MX35) makes more sense to me ;-)

Regards,
Oliver

On 22.07.2010 18:40, Marc Kleine-Budde wrote:
> Hello,
> 
> sorry for the confusion about the last minute problem with the driver,
> it was false alarm. Someone had troubles a driver derived from fsl's
> original one.
> 
> David, please feel free to merge the driver now. :)
> 
> Cheers, Marc


> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 2c5227c..9d9e453 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -73,6 +73,15 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will be
>  	  called janz-ican3.ko.
>  
> +config HAVE_CAN_FLEXCAN
> +	bool
> +
> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV && HAVE_CAN_FLEXCAN
> +	---help---
> +	  Say Y here if you want to support for Freescale FlexCAN.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"



On 21.07.2010 23:04, Marc Kleine-Budde wrote:
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 2c5227c..25924dd 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -73,6 +73,12 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will be
>  	  called janz-ican3.ko.
>
> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV && (ARCH_MX25 || ARCH_MX35)
> +	---help---
> +	  Say Y here if you want to support for Freescale FlexCAN.
> +
>  source "drivers/net/can/mscan/Kconfig"
>
>  source "drivers/net/can/sja1000/Kconfig"
