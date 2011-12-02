From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] e1000e: Fix bug for e1000e interrupt default mode
 select.
Date: Fri, 2 Dec 2011 17:55:22 +0000
Message-ID: <1322848522.2807.3.camel@bwh-desktop>
References: <1322809906-6428-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jeffrey.t.kirsher@intel.com>, <jesse.brandeburg@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	Prabhakar <prabhakar@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27695 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752919Ab1LBRza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 12:55:30 -0500
In-Reply-To: <1322809906-6428-1-git-send-email-galak@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-02 at 01:11 -0600, Kumar Gala wrote:
> From: Prabhakar <prabhakar@freescale.com>
> 
> If the kernel config does not have MSI enabled (CONFIG_PCI_MSI) the driver
> should not default to MSI interrupt mode but legacy interrupt mode.

It is supposed to automatically fall-back to legacy interrupt mode.
Does that not work?

Also, are there really systems with PCI Express and no MSI support?

Ben.

> Signed-off-by: Jin Qing <b24347@freescale.com>
> Signed-off-by: Prabhakar <prabhakar@freescale.com>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
>  drivers/net/ethernet/intel/e1000e/param.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
> index 20e93b0..18c35c6 100644
> --- a/drivers/net/ethernet/intel/e1000e/param.c
> +++ b/drivers/net/ethernet/intel/e1000e/param.c
> @@ -388,8 +388,13 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
>  		static struct e1000_option opt = {
>  			.type = range_option,
>  			.name = "Interrupt Mode",
> +#ifdef CONFIG_PCI_MSI
>  			.err  = "defaulting to 2 (MSI-X)",
>  			.def  = E1000E_INT_MODE_MSIX,
> +#else
> +			.err  = "defaulting to 0 (Legacy)",
> +			.def  = E1000E_INT_MODE_LEGACY,
> +#endif
>  			.arg  = { .r = { .min = MIN_INTMODE,
>  					 .max = MAX_INTMODE } }
>  		};

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
