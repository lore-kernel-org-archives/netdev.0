From: Ragner Magalhaes <ragner.magalhaes@indt.org.br>
Subject: Re: [PATCH 2/4] ibmveth: Implement ethtool hooks to enable/disable
 checksum offload
Date: Thu, 19 Jul 2007 14:17:03 -0400
Message-ID: <469FAA9F.9010207@indt.org.br>
References: <1184860086366-patch-mail.ibm.com> <200707191548.l6JFmEYM020387@d03av04.boulder.ibm.com> <469F8C80.7070302@indt.org.br> <469FA68F.9070607@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: brking@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([131.228.20.171]:25776 "EHLO
	mgw-ext12.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754299AbXGSSSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 14:18:03 -0400
In-Reply-To: <469FA68F.9070607@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ext Brian King wrote:
> Ragner Magalhaes wrote:
>> ext Brian King wrote:
>>
>>> +
>>> +static int ibmveth_set_rx_csum(struct net_device *dev, u32 data)
>>> +{
>>> +	struct ibmveth_adapter *adapter = dev->priv;
>>> +
>> Why do not to do
>>
>> 	if ((data && adapter->rx_csum) || (!data && !adapter->rx_csum))
>> 		return 0;
>> less two lines.
> 
> Ok.
> 
>> here also, as above ...
>>> +	if (data && (dev->features & NETIF_F_IP_CSUM))
>>> +		return 0;
>>> +	if (!data && !(dev->features & NETIF_F_IP_CSUM))
>>> +		return 0;
> 
> This change would make the line > 80 columns, which I prefer to avoid.
> Updated patch attached which addresses the first comment.
I think would not be ugly to make.

	if ((data && (dev->features & NETIF_F_IP_CSUM)) ||
		(!data && !(dev->features & NETIF_F_IP_CSUM)))
		return 0;

> 
> Thanks,
> 
> Brian
> 
> ---

Thanks,

Ragner
