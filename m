From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xen-netfront: report link speed to ethtool
Date: Fri, 18 Nov 2011 17:46:34 +0000
Message-ID: <1321638394.2883.32.camel@bwh-desktop>
References: <20111118164805.GA14345@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42386 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753Ab1KRRqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 12:46:38 -0500
In-Reply-To: <20111118164805.GA14345@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-11-18 at 17:48 +0100, Olaf Hering wrote:
> Add .get_settings function, return fake data so that ethtool can get
> enough information. For some application like VCS, this is useful,
> otherwise some of application logic will get panic.
> The reported data refers to VMWare vmxnet.
> 
> Signed-off-by: Xin Wei Hu <xwhu@suse.com>
> Signed-off-by: Chunyan Liu <cyliu@suse.com>
> Signed-off-by: Olaf Hering <olaf@aepfle.de>

NAK, we should not just make things up.

Ben.

> ---
>  drivers/net/xen-netfront.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> Index: linux-3.2-rc2/drivers/net/xen-netfront.c
> ===================================================================
> --- linux-3.2-rc2.orig/drivers/net/xen-netfront.c
> +++ linux-3.2-rc2/drivers/net/xen-netfront.c
> @@ -1727,6 +1727,17 @@ static void netback_changed(struct xenbu
>  	}
>  }
>  
> +static int xennet_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
> +{
> +	ecmd->supported = SUPPORTED_1000baseT_Full | SUPPORTED_TP;
> +	ecmd->advertising = ADVERTISED_TP;
> +	ecmd->port = PORT_TP;
> +	ecmd->transceiver = XCVR_INTERNAL;
> +	ecmd->speed = SPEED_1000;
> +	ecmd->duplex = DUPLEX_FULL;
> +	return 0;
> +}
> +
>  static const struct xennet_stat {
>  	char name[ETH_GSTRING_LEN];
>  	u16 offset;
> @@ -1774,6 +1785,7 @@ static const struct ethtool_ops xennet_e
>  {
>  	.get_link = ethtool_op_get_link,
>  
> +	.get_settings = xennet_get_settings,
>  	.get_sset_count = xennet_get_sset_count,
>  	.get_ethtool_stats = xennet_get_ethtool_stats,
>  	.get_strings = xennet_get_strings,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
