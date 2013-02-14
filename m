From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/5 net-next] tg3: Add 57766 device support.
Date: Thu, 14 Feb 2013 14:25:50 -0800
Message-ID: <1360880750.3051.7.camel@joe-AO722>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, nsujir@broadcom.com
To: Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55307 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759164Ab3BNWZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 17:25:51 -0500
In-Reply-To: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 14:13 -0800, Michael Chan wrote:
> From: Matt Carlson <mcarlson@broadcom.com>
> 
> The patch also adds a couple of fixes
> 
>  - For the 57766, bootcode needs to setup the PCIE Fast Training
>    Sequence (FTS) value to prevent transmit hangs. Unfortunately, it
>    does not have enough room in the selfboot case (i.e. devices with no
>    NVRAM).  The driver needs to implement this.
[]
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
[]
> @@ -9179,7 +9180,14 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
>  		}
>  
>  		if (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_57765_AX) {
> -			u32 grc_mode = tr32(GRC_MODE);
> +			u32 grc_mode;
> +
> +			/* Fix transmit hangs */
> +			val = tr32(TG3_CPMU_PADRNG_CTL);
> +			val |= TG3_CPMU_PADRNG_CTL_RDIV2;
> +			tw32(TG3_CPMU_PADRNG_CTL, val);
> +

This seems to write this val to more devices than just
a 57766.  Intentional?

> +			grc_mode = tr32(GRC_MODE);
>  
>  			/* Access the lower 1K of DL PCIE block registers. */
>  			val = grc_mode & ~GRC_MODE_PCIE_PORT_MASK;
