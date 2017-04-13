From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/8] ftgmac100: Add ethtool n-way reset call
Date: Wed, 12 Apr 2017 17:00:15 -0700
Message-ID: <a08e926a-5d8b-cb02-a2dd-1256b255be27@gmail.com>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
 <20170412224443.17906-2-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34645 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754721AbdDMAAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 20:00:17 -0400
Received: by mail-qt0-f196.google.com with SMTP id r49so5985274qta.1
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 17:00:17 -0700 (PDT)
In-Reply-To: <20170412224443.17906-2-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2017 03:44 PM, Benjamin Herrenschmidt wrote:
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 796b37e..bbeb8e7 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -1043,11 +1043,11 @@ static void ftgmac100_get_drvinfo(struct net_device *netdev,
>  	strlcpy(info->bus_info, dev_name(&netdev->dev), sizeof(info->bus_info));
>  }
>  
> -static int ftgmac100_nway_reset(struct net_device *ndev)
> +static int ftgmac100_nway_reset(struct net_device *netdev)
>  {
> -	if (!ndev->phydev)
> +	if (!netdev->phydev)
>  		return -ENXIO;
> -	return phy_start_aneg(ndev->phydev);
> +	return phy_start_aneg(netdev->phydev);

Can you use phy_ethtool_nway_reset() which does that (and also checks if
phydev->drv is NULL which would be the case after an unbind).

>  }
>  
>  static void ftgmac100_get_ringparam(struct net_device *netdev,
> @@ -1088,6 +1088,7 @@ static const struct ethtool_ops ftgmac100_ethtool_ops = {
>  	.get_link		= ethtool_op_get_link,
>  	.get_link_ksettings	= phy_ethtool_get_link_ksettings,
>  	.set_link_ksettings	= phy_ethtool_set_link_ksettings,
> +	.nway_reset		= ftgmac100_nway_reset,
>  	.get_ringparam		= ftgmac100_get_ringparam,
>  	.set_ringparam		= ftgmac100_set_ringparam,
>  };
> 


-- 
Florian
