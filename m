From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH-2.4] e100: incorrect use of "&&" instead of "&"
Date: Mon, 27 Nov 2006 09:31:34 -0800
Message-ID: <456B20F6.8010009@intel.com>
References: <20061125213517.GA5965@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, davem@davemloft.net, linux-net@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23176 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1758273AbWK0RcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 12:32:05 -0500
To: Willy Tarreau <w@1wt.eu>
In-Reply-To: <20061125213517.GA5965@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Willy Tarreau wrote:
> Hi guys,
> 
> I'm about to apply this fix to 2.4. 2.6 is not affected.
> Do you have any objection ?

Willy,

you didn't CC netdev. linux-net is a users list, you didn't CC the maintainers of the 
driver. Please do this. We're more than happy to help, even for 2.4 kernels.


Patch looks good, please apply.

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

Cheers,

Auke


> 
> Thanks in advance,
> Willy
> 
> 
> From e716301a8829bd45e60ac48939afa80753534b59 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 25 Nov 2006 22:11:36 +0100
> Subject: [PATCH] e100: incorrect use of "&&" instead of "&"
> 
> In e100_do_ethtool_ioctl(), bdp->flags is a bitfield and is
> checked for some bits but the AND operation is performed with
> && instead of &. Obvious fix is to use "&" as in all other
> places. 2.6 does not seem affected.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  drivers/net/e100/e100_main.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/e100/e100_main.c b/drivers/net/e100/e100_main.c
> index c9d801a..d67a145 100644
> --- a/drivers/net/e100/e100_main.c
> +++ b/drivers/net/e100/e100_main.c
> @@ -3292,11 +3292,11 @@ #ifdef	ETHTOOL_GPAUSEPARAM
>  		if ((bdp->flags & IS_BACHELOR)
>  		    && (bdp->params.b_params & PRM_FC)) {
>  			epause.autoneg = 1;
> -			if (bdp->flags && DF_LINK_FC_CAP) {
> +			if (bdp->flags & DF_LINK_FC_CAP) {
>  				epause.rx_pause = 1;
>  				epause.tx_pause = 1;
>  			}
> -			if (bdp->flags && DF_LINK_FC_TX_ONLY)
> +			if (bdp->flags & DF_LINK_FC_TX_ONLY)
>  				epause.tx_pause = 1;
>  		}
>  		rc = copy_to_user(ifr->ifr_data, &epause, sizeof(epause))
