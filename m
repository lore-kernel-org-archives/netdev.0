From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 1/7] bna: Brocade 1860 IOC PLL, Reg Defs and ASIC
 Mode Changes
Date: Tue, 27 Sep 2011 16:26:11 -0700
Message-ID: <1317165971.19340.5.camel@Joe-Laptop>
References: <1317155951-17242-1-git-send-email-rmody@brocade.com>
	 <1317155951-17242-2-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52169 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752319Ab1I0X0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 19:26:13 -0400
In-Reply-To: <1317155951-17242-2-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-27 at 13:39 -0700, Rasesh Mody wrote:
> Add logic to set ASIC specfic interface in IOC, HW interface initialization
> APIs, mode based initialization and MSI-X resource allocation for 1860 with
> no asic block. Add new h/w specific register definitions and setup registers
> used by IOC logic.

decidedly trivial...

> diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
[]
> @@ -1981,7 +1981,13 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
>  		BUG_ON(1);
>  	}
>  
> -	bfa_nw_ioc_set_ct_hwif(ioc);
> +	/**
> +	 * Set asic specific interfaces.
> +	 */
> +	if (ioc->asic_gen == BFI_ASIC_GEN_CT)
> +		bfa_nw_ioc_set_ct_hwif(ioc);
> +	else
> +		bfa_nw_ioc_set_ct2_hwif(ioc);
[]
> diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
[]
>  	/**
>  	 * sram memory access
>  	 */

> @@ -256,6 +310,64 @@ bfa_ioc_ct_reg_init(struct bfa_ioc *ioc)
[]
> +	/**
> +	 * sram memory access
> +	 */

There's at least a few places where this introductory /**
comment style is used.  Perhaps this confuses kernel-doc.
I think that it should just be /*
