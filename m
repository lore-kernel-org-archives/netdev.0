From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 7/9] net/eipoib: Add main driver
 functionality
Date: Thu, 19 Jul 2012 14:49:49 +0100
Message-ID: <1342705789.2617.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
	 <1342609202-32427-8-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29328 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750894Ab2GSNtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 09:49:53 -0400
In-Reply-To: <1342609202-32427-8-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:00 +0300, Or Gerlitz wrote:
[...]
> +/* ----------------------------- VLAN funcs ---------------------------------- */
> +static int eth_ipoib_vlan_rx_add_vid(struct net_device *dev,
> +				     unsigned short vid)
> +{
> +	return 0;
> +}
> +
> +static int eth_ipoib_vlan_rx_kill_vid(struct net_device *dev,
> +				      unsigned short vid)
> +{
> +	return 0;
> +}
[...]
> +/* -------------------------- Device entry points --------------------------- */
> +static struct net_device_stats *parent_get_stats(struct net_device *parent_dev)
> +{
[...]
> +static const struct net_device_ops parent_netdev_ops = {
> +	.ndo_init		= parent_init,
> +	.ndo_uninit		= parent_uninit,
> +	.ndo_open		= parent_open,
> +	.ndo_stop		= parent_close,
> +	.ndo_start_xmit		= parent_tx,
> +	.ndo_select_queue	= parent_select_q,
> +	/* parnt mtu is min(slaves_mtus) */
> +	.ndo_change_mtu		= NULL,
> +	.ndo_fix_features	= parent_fix_features,
> +	/*
> +	 * initial mac address is randomized, can be changed
> +	 * thru this func later
> +	 */
> +	.ndo_set_mac_address = eth_mac_addr,
> +	.ndo_get_stats = parent_get_stats,

Why not implement ndo_get_stats64?  I don't think there's any good
reason for a new driver not to.

> +	.ndo_vlan_rx_add_vid = eth_ipoib_vlan_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid = eth_ipoib_vlan_rx_kill_vid,

These shouldn't be needed.

[...]
> +/* netdev events handlers */
> +static inline int is_ipoib_pif_intf(struct net_device *dev)
> +{
> +	if (ARPHRD_INFINIBAND == dev->type && dev->priv_flags & IFF_EIPOIB_PIF)
> +			return 1;
[...]

Wrong indentation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
