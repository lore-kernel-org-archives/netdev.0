From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ibm emac: delete module references; phy.c only
 supported as built-in
Date: Mon, 27 Feb 2012 19:56:35 +0000
Message-ID: <1330372595.2720.1.camel@bwh-desktop>
References: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <benh@kernel.crashing.org>,
	<linuxppc-dev@lists.ozlabs.org>, <jwboyer@gmail.com>,
	<mporter@kernel.crashing.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47689 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754904Ab2B0T4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 14:56:42 -0500
In-Reply-To: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-27 at 14:47 -0500, Paul Gortmaker wrote:
> The Makefile has it as "ibm_emac-y := mal.o core.o phy.o" so there is
> no way this can be built modular, so remove all references to module
> support.

No, that's nonsense.  You need to look at whether ibm_emac.o can be
added to obj-m (which it can).

Ben.

> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
> index d3b9d10..fb96387 100644
> --- a/drivers/net/ethernet/ibm/emac/phy.c
> +++ b/drivers/net/ethernet/ibm/emac/phy.c
> @@ -11,13 +11,15 @@
>   * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
>   *                <benh@kernel.crashing.org>
>   *
> + * Originally listed as MODULE_LICENSE("GPL") in the code, but that
> + * was removed, since this code is only supported as non-modular.
> + *
>   * Based on the arch/ppc version of the driver:
>   *
>   * (c) 2003, Benjamin Herrenscmidt (benh@kernel.crashing.org)
>   * (c) 2004-2005, Eugene Surovegin <ebs@ebshome.net>
>   *
>   */
> -#include <linux/module.h>
>  #include <linux/kernel.h>
>  #include <linux/types.h>
>  #include <linux/netdevice.h>
> @@ -537,5 +539,3 @@ int emac_mii_phy_probe(struct mii_phy *phy, int address)
>  
>  	return 0;
>  }
> -
> -MODULE_LICENSE("GPL");

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
