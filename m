From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ixgbe: fix EEH recovery during reset on PPC
Date: Fri, 27 Jun 2008 01:33:47 -0400
Message-ID: <48647BBB.9040805@garzik.org>
References: <20080625000036.16592.6621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pl@us.ibm.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56736 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758119AbYF0Fdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:33:52 -0400
In-Reply-To: <20080625000036.16592.6621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Paul Larson <pl@us.ibm.com>
> 
> EEh is not recovering in a resonable amount of time on PPC during
> ixgbe_down().
> 
> Signed-off-by: Paul Larson <pl@us.ibm.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgbe/ixgbe_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 7b39394..5774377 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1969,7 +1969,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
>  	netif_carrier_off(netdev);
>  	netif_stop_queue(netdev);
>  
> -	ixgbe_reset(adapter);
> +	if (!pci_channel_offline(adapter->pdev))
> +		ixgbe_reset(adapter);
>  	ixgbe_clean_all_tx_rings(adapter);

applied 1-3


