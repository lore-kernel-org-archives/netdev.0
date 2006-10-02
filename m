From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Introduce BROKEN_ON_64BIT facility
Date: 02 Oct 2006 11:51:45 +0200
Message-ID: <p737izjhwpa.fsf@verdi.suse.de>
References: <20061002045512.GA8835@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org, kkeil@suse.de,
	kai.germaschewski@gmx.de, isdn4linux@listserv.isdn4linux.de,
	mac@melware.de, markus.lidel@shadowconnect.com, samuel@sortiz.org,
	Neela.Kolli@engenio.com, linux-scsi@vger.kernel.org,
	Greg KH <greg@kroah.com>, thomas@winischhofer.net
Return-path: <linux-scsi-owner@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061002045512.GA8835@havoc.gtf.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> writes:

> Add a broken-on-64bit option, similar to the existing broken-on-smp
> config option.  This is just the first pass, marking the obvious
> candidates.

When I had this problem in the past I just used && !64BIT.
How is this new option different?
>  config ISDN_CAPI_CAPI20
>  	tristate "CAPI2.0 /dev/capi support"
> -	depends on ISDN_CAPI
> +	depends on ISDN_CAPI && BROKEN_ON_64BIT
>  	help
>  	  This option will provide the CAPI 2.0 interface to userspace
>  	  applications via /dev/capi20. Applications should use the
> @@ -44,7 +44,7 @@ config ISDN_CAPI_CAPIFS
>  
>  config ISDN_CAPI_CAPIDRV
>  	tristate "CAPI2.0 capidrv interface support"
> -	depends on ISDN_CAPI && ISDN_I4L
> +	depends on ISDN_CAPI && ISDN_I4L && BROKEN_ON_64BIT

As discussed earlier ISDN is actually ok.
> diff --git a/drivers/message/i2o/Kconfig b/drivers/message/i2o/Kconfig
> index 6443392..0e135ce 100644
> --- a/drivers/message/i2o/Kconfig
> +++ b/drivers/message/i2o/Kconfig
> @@ -56,7 +56,7 @@ config I2O_EXT_ADAPTEC_DMA64
>  
>  config I2O_CONFIG
>  	tristate "I2O Configuration support"
> -	depends on I2O
> +	depends on I2O && BROKEN_ON_64BIT
>  	---help---
>  	  Say Y for support of the configuration interface for the I2O adapters.

AFAIK I2O got fixed too. Do you have any evidence that it is really
broken on 64bit?



-Andi
