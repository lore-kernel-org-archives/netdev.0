From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: default to 64-bit DMA on systems without memory
 below 4 GB
Date: Wed, 11 May 2016 22:31:26 +0200
Message-ID: <20160511203126.GA10093@electric-eye.fr.zoreil.com>
References: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ricardo.salveti@linaro.org,
	leo.duran@amd.com, graeme.gregory@linaro.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54434 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111AbcEKUbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 16:31:39 -0400
Content-Disposition: inline
In-Reply-To: <1462952869-23498-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> :
> The current logic around the 'use_dac' module parameter prevents the
> r81969 driver from being loadable on 64-bit systems without any RAM
> below 4 GB when the parameter is left at its default value.
> So introduce a new default value -1 which indicates that 64-bit DMA
> should be enabled implicitly, but only if setting a 32-bit DMA mask
> has failed earlier. This should prevent any regressions like the ones
> caused by previous attempts to change this code.

I am not a huge fan but if you really need it...

Which current kernel arches do exhibit the interesting
f*ck-legacy-32-bits-only-devices property you just described ?

[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 94f08f1e841c..a49e8a58e539 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -859,7 +859,8 @@ struct rtl8169_private {
>  MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
>  MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
>  module_param(use_dac, int, 0);
> -MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
> +MODULE_PARM_DESC(use_dac,
> +	"Enable PCI DAC. Unsafe on 32 bit PCI slot (default -1: enable on 64-bit archs only if needed");

Nit: the parameter is bizarre enough that you could leave the original
description.

-- 
Ueimor
