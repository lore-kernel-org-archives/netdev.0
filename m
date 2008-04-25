From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/6] ibm_newemac: Fix problem with jumbo frame support
 and EMAC V4.patch
Date: Fri, 25 Apr 2008 02:01:37 -0400
Message-ID: <481173C1.8060300@pobox.com>
References: <20080422004758.1A823DE19B@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58440 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889AbYDYGBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:01:41 -0400
In-Reply-To: <20080422004758.1A823DE19B@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> From: Stefan Roese <sr@denx.de>
> 
> This fixes the jumbo frame support on EMAC V4 systems. Now the correct
> bit is set depending on the EMAC version configured.
> 
> Tested on Kilauea (405EX) and Canyonlands (460EX).
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> ---
>  drivers/net/ibm_newemac/core.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index 0789802..486901f 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -524,7 +524,10 @@ static int emac_configure(struct emac_instance *dev)
>  		rx_size = dev->rx_fifo_size_gige;
>  
>  		if (dev->ndev->mtu > ETH_DATA_LEN) {
> -			mr1 |= EMAC_MR1_JPSM;
> +			if (emac_has_feature(dev, EMAC_FTR_EMAC4))
> +				mr1 |= EMAC4_MR1_JPSM;
> +			else
> +				mr1 |= EMAC_MR1_JPSM;
>  			dev->stop_timeout = STOP_TIMEOUT_1000_JUMBO;
>  		} else
>  			dev->stop_timeout = STOP_TIMEOUT_1000;

applied 1-6


