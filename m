From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2] ibm_newemac: Fixes entry of short packets
Date: Fri, 04 Jul 2008 08:17:39 -0400
Message-ID: <486E14E3.6080402@garzik.org>
References: <1214902699-10534-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48162 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbYGDMRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:17:43 -0400
In-Reply-To: <1214902699-10534-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> Short packets has to be discarded by the driver. So this patch addresses the
> issue of discarding the short packets of size lesser then ethernet header
> size.
> 
> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
>  drivers/net/ibm_newemac/core.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
> index ca63fa0..babc79a 100644
> --- a/drivers/net/ibm_newemac/core.c
> +++ b/drivers/net/ibm_newemac/core.c
> @@ -1636,6 +1636,12 @@ static int emac_poll_rx(void *param, int budget)
>  			goto next;
>  		}
>  
> +		if (len < ETH_HLEN) {
> +			++dev->estats.rx_dropped_stack;
> +			emac_recycle_rx_skb(dev, slot, len);
> +			goto next;
> +		}
> +
>  		if (len && len < EMAC_RX_COPY_THRESH) {

applied 2.6.26


