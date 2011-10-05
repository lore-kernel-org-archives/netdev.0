From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] Add ethtool -g support to 8139cp
Date: Wed, 05 Oct 2011 19:50:48 +0100
Message-ID: <1317840648.2802.27.camel@bwh-desktop>
References: <20111005180854.3D68129003A8@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <raj@tardy.cup.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53002 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933573Ab1JESuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 14:50:52 -0400
In-Reply-To: <20111005180854.3D68129003A8@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-05 at 11:08 -0700, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> Add support for reporting ring sizes via ethtool -g to the 8139cp driver.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index c77d5af..1dcfe57 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -1324,6 +1324,19 @@ static void cp_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info
>  	strcpy (info->bus_info, pci_name(cp->pdev));
>  }
>  
> +static void cp_get_ringparam(struct net_device *dev,
> +				struct ethtool_ringparam *ring)
> +{
> +	ring->rx_max_pending = CP_RX_RING_SIZE;
> +	ring->tx_max_pending = CP_TX_RING_SIZE;
> +	ring->rx_mini_max_pending = 0;
> +	ring->rx_jumbo_max_pending = 0;
> +	ring->rx_pending = CP_RX_RING_SIZE;
> +	ring->tx_pending = CP_TX_RING_SIZE;
> +	ring->rx_mini_pending = 0;
> +	ring->rx_jumbo_pending = 0;
> +}

You generally don't need to set fields to zero in ethtool 'get'
operations, as the ethtool core will initialise the entire structure to
zero.

Ben.

>  static int cp_get_regs_len(struct net_device *dev)
>  {
>  	return CP_REGS_SIZE;
> @@ -1525,6 +1538,7 @@ static const struct ethtool_ops cp_ethtool_ops = {
>  	.get_eeprom_len		= cp_get_eeprom_len,
>  	.get_eeprom		= cp_get_eeprom,
>  	.set_eeprom		= cp_set_eeprom,
> +	.get_ringparam		= cp_get_ringparam,
>  };
>  
>  static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
