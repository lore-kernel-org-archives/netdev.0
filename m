From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: converting fore200e driver to use request_firmware()
Date: Thu, 7 Feb 2008 11:43:17 -0800
Message-ID: <20080207114317.0b9f6db1@extreme>
References: <20080206.160542.07994571.davem@davemloft.net>
	<200802071920.m17JKJMb029314@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:53093 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427AbYBGTnX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 14:43:23 -0500
In-Reply-To: <200802071920.m17JKJMb029314@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Feb 2008 14:20:19 -0500
"chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil> wrote:

> In message <20080206.160542.07994571.davem@davemloft.net>,David Miller writes:
> >> however, i ran into a little problem with the sbus interface.  what should
> >> i pass for 'struct device *' for an sbus device?
> >
> >"&sdev->ofdev.dev" should work
> 
> thanks!  that is what i needed.  so what i have works on pci and is
> quite a bit cleaner than the current mess for the firmware.  the only
> iffy part is the conversion of the struct fore_200e to a struct device
> which is depends your bus.  perhaps it should be a seperate routine.
> 
> any comments on the following?
> 
> diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
> index 1c7ae30..a5303ee 100644
> --- a/drivers/atm/Kconfig
> +++ b/drivers/atm/Kconfig
> @@ -325,81 +325,21 @@ config ATM_IA_DEBUG
>  	  speed of the driver, and the size of your syslog files! When
>  	  inactive, they will have only a modest impact on performance.
>  
> -config ATM_FORE200E_MAYBE
> +config ATM_FORE200E
>  	tristate "FORE Systems 200E-series"
> -	depends on PCI || SBUS
> +	depends on (PCI || SBUS)
>  	---help---
>  	  This is a driver for the FORE Systems 200E-series ATM adapter
>  	  cards. It simultaneously supports PCA-200E and SBA-200E models
>  	  on PCI and SBUS hosts. Say Y (or M to compile as a module
>  	  named fore_200e) here if you have one of these ATM adapters.
>  
> -	  Note that the driver will actually be compiled only if you
> -	  additionally enable the support for PCA-200E and/or SBA-200E
> -	  cards.
> -
>  	  See the file <file:Documentation/networking/fore200e.txt> for
>  	  further details.
>  

Think you  now need to select FW_LOADER?

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
