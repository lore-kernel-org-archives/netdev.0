From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 10/10] ixgbe: Add support for set_channels
 ethtool operation
Date: Wed, 16 Jan 2013 16:19:17 +0000
Message-ID: <1358353157.2923.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
	 <20130110185846.29578.94872.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <therbert@google.com>, <ycai@google.com>,
	<eric.dumazet@gmail.com>, <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20201 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975Ab3APQTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 11:19:21 -0500
In-Reply-To: <20130110185846.29578.94872.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-10 at 10:58 -0800, Alexander Duyck wrote:
> This change adds support for the ethtool set_channels operation.
> 
> Since the ixgbe driver has to support DCB as well as the other modes the
> assumption I made here is that the number of channels in DCB modes refers
> to the number of queues per traffic class, not the number of queues total.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

In DCB mode are there separate IRQs for the different classes?

[...]
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -2775,6 +2775,45 @@ static void ixgbe_get_channels(struct net_device *dev,
>  	ch->combined_count = adapter->ring_feature[RING_F_FDIR].indices;
>  }
>  
> +static int ixgbe_set_channels(struct net_device *dev,
> +			      struct ethtool_channels *ch)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> +	unsigned int count = ch->combined_count;
> +
> +	/* verify they are not requesting separate vectors */
> +	if (ch->rx_count || ch->tx_count)
> +		return -EINVAL;
> +
> +	/* ignore other_count since it is not changeable */
[...]

Please do return an error if the command specifies a change to
other_count.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
