From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, 2/2] igb:  Implementation of ethtool priv_flags for igb
 driver.
Date: Fri, 02 Sep 2011 22:31:36 +0100
Message-ID: <1314999096.3419.16.camel@bwh-desktop>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
	 <1314996631-4773-2-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29316 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986Ab1IBVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:31:39 -0400
In-Reply-To: <1314996631-4773-2-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 13:50 -0700, Carolyn Wyborny wrote:
> This patch adds igb driver support for the ethtool private flags
> interface. Two features are initially configured for private flags
> support as an example for use with the implementation in ethtoool
> application.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |    2 +
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   28 ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igb/igb_main.c    |    1 +
>  3 files changed, 31 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index bb47ed1..a8be3eb 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -360,6 +360,7 @@ struct igb_adapter {
>  	u32 rss_queues;
>  	u32 wvbr;
>  	int node;
> +	u32 pflags;
>  };
>  
>  #define IGB_FLAG_HAS_MSI           (1 << 0)
> @@ -367,6 +368,7 @@ struct igb_adapter {
>  #define IGB_FLAG_QUAD_PORT_A       (1 << 2)
>  #define IGB_FLAG_QUEUE_PAIRS       (1 << 3)
>  #define IGB_FLAG_DMAC              (1 << 4)
> +#define IGB_FLAG_EEE               (1 << 5)
>  
>  /* DMA Coalescing defines */
>  #define IGB_MIN_TXPBSIZE           20408
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index 64fb4ef..3a251c7 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -696,6 +696,9 @@ static void igb_get_drvinfo(struct net_device *netdev,
>  	drvinfo->testinfo_len = IGB_TEST_LEN;
>  	drvinfo->regdump_len = igb_get_regs_len(netdev);
>  	drvinfo->eedump_len = igb_get_eeprom_len(netdev);
> +#ifdef ETHTOOL_GPFLAGS

That macro is always defined,

> +	drvinfo->n_priv_flags = 2;

This is not enough.  You need to support ETH_SS_PRIV_FLAGS in the
get_sset_count and get_strings operations.

> +#endif
>  }
>  
>  static void igb_get_ringparam(struct net_device *netdev,
> @@ -2171,6 +2174,29 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
>  	}
>  }
>  
> +static int igb_set_pflags(struct net_device *netdev, u32 data)
> +{
> +	u32 supported_flags = IGB_FLAG_EEE;
> +	struct igb_adapter *adapter = netdev_priv(netdev);
> +
> +	if (data & supported_flags) {
[...]

If the number of flags is 2, then the supported flags must be numbered
(1 << 0) and (1 << 1).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
