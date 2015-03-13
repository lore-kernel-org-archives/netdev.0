From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: rewrite bcmgenet_rx_refill()
Date: Fri, 13 Mar 2015 15:48:44 -0400 (EDT)
Message-ID: <20150313.154844.1460460664757494447.davem@davemloft.net>
References: <20150312224800.AE7A7220365@puck.mtv.corp.google.com>
	<55032C64.3010706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, netdev@vger.kernel.org, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbCMTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:48:46 -0400
In-Reply-To: <55032C64.3010706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 13 Mar 2015 11:28:52 -0700

> On 12/03/15 15:48, Petri Gynther wrote:
>> Currently, bcmgenet_desc_rx() calls bcmgenet_rx_refill() at the end of
>> Rx packet processing loop, after the current Rx packet has already been
>> passed to napi_gro_receive(). However, bcmgenet_rx_refill() might fail
>> to allocate a new Rx skb, thus leaving a hole on the Rx queue where no
>> valid Rx buffer exists.
>> 
>> To eliminate this situation:
>> 1. Rewrite bcmgenet_rx_refill() to retain the current Rx skb on the Rx
>>    queue if a new replacement Rx skb can't be allocated and DMA-mapped.
>>    In this case, the data on the current Rx skb is effectively dropped.
>> 2. Modify bcmgenet_desc_rx() to call bcmgenet_rx_refill() at the top of
>>    Rx packet processing loop, so that the new replacement Rx skb is
>>    already in place before the current Rx skb is processed.
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Thanks! Have not noticed any performance impact doing 64B/1500B testing.

Applied, thanks everyone.
