From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 15:52:09 -0400 (EDT)
Message-ID: <20150407.155209.47396464487922345.davem@davemloft.net>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
	<cover.1428340371.git.romieu@fr.zoreil.com>
	<87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbDGTwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:52:12 -0400
In-Reply-To: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon,  6 Apr 2015 20:01:49 +0200

> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/ethernet/via/via-rhine.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index a191afc..00fea3d 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
>  				break;
>  			}
>  			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
> +			wmb();

dma_wmb() perhaps?  I think this is exactly the situation that interface was
added for.
