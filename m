From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: vlan 03/07: Add ethtool support
Date: Mon, 7 Jul 2008 17:52:18 +0100
Message-ID: <20080707165217.GC28029@solarflare.com>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain> <20080707123601.23947.96915.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:39540 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756888AbYGGQwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 12:52:25 -0400
Content-Disposition: inline
In-Reply-To: <20080707123601.23947.96915.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> vlan: Add ethtool support
> 
> Add ethtool support for querying the device for offload settings.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
[...]
> +static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
> +{
> +	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
> +	struct net_device *real_dev = vlan->real_dev;
> +
> +	if (real_dev->ethtool_ops == NULL ||
> +	    real_dev->ethtool_ops->get_rx_csum == NULL)
> +		return 0;
> +	return real_dev->ethtool_ops->get_rx_csum(real_dev);

But we don't know whether RX checksum offload applies to VLAN-tagged
packets (or, admittedly, any specific protocol).  It would be nice if there
was a feature flag for this so it could be advertised in vlan_features.

> +}
> +
> +static const struct ethtool_ops vlan_ethtool_ops = {
> +	.get_link		= ethtool_op_get_link,
> +	.get_rx_csum		= vlan_ethtool_get_rx_csum,

Can't we also add:

	.get_tx_csum		= ethtool_op_get_tx_csum,
	.get_sg			= ethtool_op_get_sg,
	.get_tso		= ethtool_op_get_tso,
	.get_flags		= ethtool_op_get_flags,

?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
