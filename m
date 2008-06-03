From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC] Make board force selection of PHYLIB
Date: Tue, 03 Jun 2008 10:10:34 -0500
Message-ID: <48455EEA.3040909@freescale.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org> <83820D83-487C-4586-9867-F4226A87A276@freescale.com> <48445851.4090105@garzik.org> <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org> <48448020.5020407@freescale.com> <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, adrian.bunk@movial.fi
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60186 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbYFCPLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:11:14 -0400
In-Reply-To: <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> How is this as a fix.
> 
> - k
> 
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> index 7ff29d5..9e5c884 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -34,6 +34,7 @@ config MPC85xx_MDS
>  	bool "Freescale MPC85xx MDS"
>  	select DEFAULT_UIMAGE
>  	select QUICC_ENGINE
> +	select PHYLIB if GIANFAR=m
>  	help
>  	  This option enables support for the MPC85xx MDS board

I assume you'll also ifdef-protect the phy calls in the platform code?

I'd rather avoid adding another case where the kernel needs to know what 
modules are being built, though, especially if the result of changing 
the .config and building modules is a mysterious runtime failure (due to 
a missing platform fixup) rather than compile- or insertion-time.

-Scott
