From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 7/9] net/eipoib: Add main driver functionality
Date: Thu, 19 Jul 2012 18:46:38 +0300
Message-ID: <50082BDE.2040005@mellanox.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>  <1342609202-32427-8-git-send-email-ogerlitz@mellanox.com> <1342705789.2617.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:40203 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750852Ab2GSPqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:46:52 -0400
In-Reply-To: <1342705789.2617.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/2012 4:49 PM, Ben Hutchings wrote:
> On Wed, 2012-07-18 at 14:00 +0300, Or Gerlitz wrote:
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
>
> Why not implement ndo_get_stats64?  I don't think there's any good
> reason for a new driver not to.

Indeed, will do  ndo_get_stats64

>
>
>> +	.ndo_vlan_rx_add_vid = eth_ipoib_vlan_rx_add_vid,
>> +	.ndo_vlan_rx_kill_vid = eth_ipoib_vlan_rx_kill_vid,
>
> These shouldn't be needed.

ok, here's the point, the eIPoIB driver maps Ethernet vlans to 
infiniband/IPoIB pkeys
(partition keys). The underlying IPoIB devices work with these pkeys
in a way which is HW accelerated, and we want the eIPoIB driver to be 
considered as one
that support HW accelerate vlans. E.g on the TX flow we don't want that 
any special SW
handling by the 8021q driver will be done on the skb except for setting 
the skb->vlan_tci
field, and in the RX flow, we set skb->vlan_tci field and don't want 
that 8021q to try
and extract it from the headers, etc.

For that end, I was under the impression all the three 
NETIF_F_HW_VLAN_{TX,RX,FILTER)
features need to be advertized. From your comment I understand now that 
RX/TX are enough
in that respect?



>
>
> [...]
>> +/* netdev events handlers */
>> +static inline int is_ipoib_pif_intf(struct net_device *dev)
>> +{
>> +	if (ARPHRD_INFINIBAND == dev->type && dev->priv_flags & IFF_EIPOIB_PIF)
>> +			return 1;
> [...]
>
> Wrong indentation.

will fix, thanks for spotting this.

Or.
