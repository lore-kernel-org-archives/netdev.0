From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/5] be2net: Fix to apply duplex value as
 unknown when link is down.
Date: Thu, 26 Apr 2012 18:24:36 +0100
Message-ID: <1335461076.2712.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <cf78444f-636f-44c5-beb7-5626b8a3df17@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Somnath Kotur <Somnath.Kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15549 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752161Ab2DZRYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 13:24:42 -0400
In-Reply-To: <cf78444f-636f-44c5-beb7-5626b8a3df17@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 19:58 +0530, Somnath Kotur wrote:
> From: Somnath Kotur <somnath.kotur@emulex.com>
> 
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index 5296df5..bb2add7 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -618,7 +618,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
>  		ecmd->supported = adapter->phy.supported;
>  	}
>  
> -	ecmd->duplex = DUPLEX_FULL;
> +	ecmd->duplex = netif_carrier_ok(netdev) ? DUPLEX_FULL : -1;
>  	ecmd->phy_address = adapter->port_num;
>  
>  	return 0;

I don't see any problem with reporting full-duplex all the time if you
don't support any half-duplex link modes.  But we don't yet have
consistency between drivers in speed/duplex reporting while the link is
down, so I won't insist that that is the right thing to do.

However you should use DUPLEX_UNKNOWN rather than -1.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
