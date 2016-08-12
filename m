From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 01/18] liquidio: Consolidate common
 functionality
Date: Fri, 12 Aug 2016 12:21:09 -0700
Message-ID: <1471029669.18251.6.camel@perches.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
	 <1471026035-15323-2-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0110.hostedemail.com ([216.40.44.110]:39598 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751091AbcHLTVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:21:18 -0400
In-Reply-To: <1471026035-15323-2-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-12 at 11:20 -0700, Raghu Vatsavayi wrote:
> Consolidate common functionality of various devices
> from different files into lio_core.c/octeon_console.c.

trivial notes:

> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
[]
> +void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
> +{
[]
> +	case OCTNET_CMD_CHANGE_MACADDR:
> +		mac = ((u8 *)&nctrl->udd[0]) + 2;
> +		netif_info(lio, probe, lio->netdev,
> +			   "MACAddr changed to %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",

			   "MACAddr changed to %pM\n", mac);
[]

> +	case OCTNET_CMD_TNL_RX_CSUM_CTL:
> +		if (nctrl->ncmd.s.param1 == OCTNET_CMD_RXCSUM_ENABLE) {
> +			netif_info(lio, probe, lio->netdev,
> +				   "%s RX Checksum Offload Enabled\n",
> +				   netdev->name);
> +		} else if (nctrl->ncmd.s.param1 ==
> +			   OCTNET_CMD_RXCSUM_DISABLE) {
> +			netif_info(lio, probe, lio->netdev,
> +				   "%s RX Checksum Offload Disabled\n",
> +				   netdev->name);

Aren't these a bit redundant output with the both name
output of lio->netdev->name and netdev->name?

> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
[]
> @@ -297,11 +297,10 @@ lio_get_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
>  
>  	eeprom->magic = oct_dev->pci_dev->vendor;
>  	board_info = (struct octeon_board_info *)(&oct_dev->boardinfo);
> -	len =
> -		sprintf((char *)bytes,
> -			"boardname:%s serialnum:%s maj:%lld min:%lld\n",
> -			board_info->name, board_info->serial_number,
> -			board_info->major, board_info->minor);
> +	len = sprintf((char *)bytes,
> +		      "boardname:%s serialnum:%s maj:%lld min:%lld\n",
> +		      board_info->name, board_info->serial_number,
> +		      board_info->major, board_info->minor);

snprintf might be better and len doesn't seem useful here
 
>  	return 0;
>  }
