From: Patrick McHardy <kaber@trash.net>
Subject: Re: vlan 03/07: Add ethtool support
Date: Mon, 07 Jul 2008 19:47:04 +0200
Message-ID: <48725698.1030809@trash.net>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain> <20080707123601.23947.96915.sendpatchset@localhost.localdomain> <20080707165217.GC28029@solarflare.com> <48724B81.2070708@trash.net> <20080707172119.GD28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33978 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725AbYGGRrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 13:47:07 -0400
In-Reply-To: <20080707172119.GD28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Patrick McHardy wrote:
>> Ben Hutchings wrote:
>>> Patrick McHardy wrote:
>>>> vlan: Add ethtool support
>>>>
>>>> Add ethtool support for querying the device for offload settings.
>>>>
>>>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>>> [...]
>>>> +static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
>>>> +{
>>>> +	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
>>>> +	struct net_device *real_dev = vlan->real_dev;
>>>> +
>>>> +	if (real_dev->ethtool_ops == NULL ||
>>>> +	    real_dev->ethtool_ops->get_rx_csum == NULL)
>>>> +		return 0;
>>>> +	return real_dev->ethtool_ops->get_rx_csum(real_dev);
>>> But we don't know whether RX checksum offload applies to VLAN-tagged
>>> packets (or, admittedly, any specific protocol).  It would be nice if there
>>> was a feature flag for this so it could be advertised in vlan_features.
>> True, for now the assumption is that it works for VLANs.
>> I don't think that assumption is unreasonable, but I can
>> look into a separate flag for this.
> 
> I would be surprised if there aren't some NICs that only check frames with
> protocol/length set to ETH_P_IP.

Yes, probably. But this is only informational and it won't be
any wronger than on the device itself. So no big deal I'd say,
but if you prefer I can also remove the TX csum support.

>>> Can't we also add:
>>>
>>> 	.get_tx_csum		= ethtool_op_get_tx_csum,
>>> 	.get_sg			= ethtool_op_get_sg,
>>> 	.get_tso		= ethtool_op_get_tso,
>>> 	.get_flags		= ethtool_op_get_flags,
>> Besides get_flags all of these are handled by default handlers.
> 
> So they are.
> 
>> What is get_flags used for?
> 
> Currently only LRO, but potentially other offload features.

LRO is currently not supported by the VLAN code, at least
not directly (drivers supporting VLAN accel can do VLAN
LRO though). So for now it seems useless to add it.
