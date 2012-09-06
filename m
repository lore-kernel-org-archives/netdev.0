From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 10/12] qlcnic: register dump utility
Date: Thu, 6 Sep 2012 18:38:09 +0100
Message-ID: <1346953089.2714.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346912529-17406-1-git-send-email-sony.chacko@qlogic.com>
	 <1346912529-17406-11-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8847 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932075Ab2IFRiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:38:12 -0400
In-Reply-To: <1346912529-17406-11-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 02:22 -0400, Sony Chacko wrote:
> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Modify 82xx driver to support new adapter - Qlogic 83XX CNA
> Common register dump utility for 82xx and 83xx adapters
[...]
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
> @@ -525,21 +525,7 @@ static void qlcnic_get_channels(struct net_device *dev,
>  static int qlcnic_set_channels(struct net_device *dev,
>  		struct ethtool_channels *channel)
>  {
> -	struct qlcnic_adapter *adapter = netdev_priv(dev);
> -	int err;
> -
> -	if (channel->other_count || channel->combined_count ||
> -	    channel->tx_count != channel->max_tx)
> -		return -EINVAL;
> -
> -	err = qlcnic_validate_max_rss(dev, channel->max_rx, channel->rx_count);
> -	if (err)
> -		return err;
> -
> -	err = qlcnic_set_max_rss(adapter, channel->rx_count);
> -	netdev_info(dev, "allocated 0x%x sds rings\n",
> -				 adapter->max_sds_rings);
> -	return err;
> +	return 0;
>  }
[...]

No, I don't think so.  If you're going to remove support for this
operation then delete the function entirely.  And don't put it in a
patch that's supposed to do something unrelated.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
