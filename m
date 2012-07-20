From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/6] e1000: configure and read MDI settings
Date: Sat, 21 Jul 2012 00:27:39 +0100
Message-ID: <1342826859.11373.123.camel@deadeye.wl.decadent.org.uk>
References: <1342820631-19738-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342820631-19738-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Tushar Dave <tushar.n.dave@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16527 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753059Ab2GTX1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 19:27:44 -0400
In-Reply-To: <1342820631-19738-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-20 at 14:43 -0700, Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> This is the implementation in e1000 to allow ethtool to force
> MDI state, allowing users to work around some improperly
> behaving switches.
> 
> Current get_settings behavior slightly changes in that now when link is down
> get_settings will return the MDI state of the last link because get_settings
> needs to succeed to allow the set to work even when link is down.
> 
> Forcing in this driver is for now only allowed when auto-neg is enabled.
> 
> To use must have the matching version of ethtool app that supports
> this functionality.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Tushar Dave <tushar.n.dave@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   34 ++++++++++++++++++++++
>  drivers/net/ethernet/intel/e1000/e1000_main.c    |    4 +++
>  2 files changed, 38 insertions(+)
> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> index 3103f0b..1d96bda 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
> @@ -174,6 +174,15 @@ static int e1000_get_settings(struct net_device *netdev,
>  
>  	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
>  			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
> +
> +	/* MDI-X => 1; MDI => 0 */
> +	if (hw->media_type == e1000_media_type_copper)
> +		ecmd->eth_tp_mdix = (!!adapter->phy_info.mdix_mode ?
> +							ETH_TP_MDI_X :
> +							ETH_TP_MDI);
> +	else
> +		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
[...]

Why don't you set ecmd->eth_tp_mdix_ctrl here?

If you also leave it as 0, it's impossible for userland to tell whether
the current mode was forced or automatically selected.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
