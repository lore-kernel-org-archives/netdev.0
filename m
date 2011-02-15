From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Tue, 15 Feb 2011 16:48:49 +0000
Message-ID: <1297788529.2584.12.camel@bwh-desktop>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6195 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716Ab1BOQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 11:48:52 -0500
In-Reply-To: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-15 at 08:24 -0800, Tom Herbert wrote:
> Support fetching and retrieving RX indirection table via ethtool.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/bnx2x/bnx2x.h         |    2 +
>  drivers/net/bnx2x/bnx2x_ethtool.c |   58 +++++++++++++++++++++++++++++++++++++
>  drivers/net/bnx2x/bnx2x_main.c    |   23 +++++++++++----
>  3 files changed, 77 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
> index 236d79a..bf16119 100644
> --- a/drivers/net/bnx2x/bnx2x.h
> +++ b/drivers/net/bnx2x/bnx2x.h
> @@ -1076,6 +1076,7 @@ struct bnx2x {
>  	int			num_queues;
>  	int			disable_tpa;
>  	int			int_mode;
> +	u32			rx_indir_table[128];

Shouldn't the dimension be TSTORM_INDIRECTION_TABLE_SIZE?

[...]
> +static int bnx2x_set_rxfh_indir(struct net_device *dev,
> +				const struct ethtool_rxfh_indir *indir)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	size_t i;
> +
> +	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
> +		return -ENOENT;
[...]

I think the error code for this should be -EOPNOTSUPP.  Similarly in
bnx2x_get_rxfh_indir().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

