From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: add checks for dma mapping errors
Date: Sat, 19 Dec 2015 12:54:33 -0500 (EST)
Message-ID: <20151219.125433.148505706922863925.davem@davemloft.net>
References: <1450475737-5959-1-git-send-email-khoroshilov@ispras.ru>
	<20151218.213607.1270121670262037282.davem@davemloft.net>
	<56754855.6080808@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbbLSRyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 12:54:38 -0500
In-Reply-To: <56754855.6080808@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 19 Dec 2015 15:06:45 +0300

> On 19.12.2015 05:36, David Miller wrote:
>> From: Alexey Khoroshilov <khoroshilov@ispras.ru>
>> Date: Sat, 19 Dec 2015 00:55:37 +0300
>>
>>> @@ -2093,6 +2099,10 @@ static netdev_tx_t start_tx(struct sk_buff
> *skb, struct net_device *dev)
>>>  	np->tx_skbuff[entry] = skb;
>>>  	np->tx_dma[entry] = pci_map_single(np->pci_dev,
>>>  				skb->data,skb->len, PCI_DMA_TODEVICE);
>>> +	if (pci_dma_mapping_error(np->pci_dev, np->tx_dma[entry])) {
>>> +		np->tx_skbuff[entry] = NULL;
>>> +		return NETDEV_TX_BUSY;
>>> +	}
>>>
>>>  	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
>>>
>>
>> Returning NETDEV_TX_BUSY and freeing the SKB will crash the system.
> 
> I do not quite understand what do you mean by 'freeing the SKB'.
> At least the patch left skb untouched.

Sorry, I misread your patch, I thought I saw a kfree there but
obviously there isn't.

>> NETDEV_TX_BUSY is only for buggy drivers that do not manage their
>> TX ring busy condition correctly, and thus need retries.
> 
> Ok, I will replace NETDEV_TX_BUSY by dropping the packet.

Thanks.
