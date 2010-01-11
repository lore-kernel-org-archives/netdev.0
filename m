From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 3/5] ethtool: Introduce n-tuple filter
	programming support
Date: Mon, 11 Jan 2010 19:32:33 +0000
Message-ID: <1263238353.2781.38.camel@achroite.uk.solarflarecom.com>
References: <20100107044741.28605.31414.stgit@localhost.localdomain>
	 <20100107044905.28605.54076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Luca Deri <deri@ntop.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54180 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab0AKTch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 14:32:37 -0500
In-Reply-To: <20100107044905.28605.54076.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-01-06 at 20:49 -0800, Jeff Kirsher wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> This patchset enables the ethtool layer to program n-tuple
> filters to an underlying device.  The idea is to allow capable
> hardware to have static rules applied that can assist steering
> flows into appropriate queues.
[...]
> @@ -500,6 +529,8 @@ struct ethtool_ops {
>  	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
>  	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
>  	int	(*reset)(struct net_device *, u32 *);
> +	int	(*set_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *);
> +	int	(*get_rx_ntuple)(struct net_device *, struct ethtool_rx_ntuple *, void *);
>  };
>  #endif /* __KERNEL__ */
>  
[...]

It it really necessary to add new driver operations?  It seems to me
that it would be preferable to extend {get,set}_rx_nfc() and have the
ethtool common code convert between the ethtool_rxnfc and
ethtool_rx_ntuple structures.  Does that seem possible?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

