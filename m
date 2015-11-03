From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET is
 enabled
Date: Tue, 03 Nov 2015 14:50:27 -0500 (EST)
Message-ID: <20151103.145027.1401610638879230478.davem@davemloft.net>
References: <BN1PR0301MB07704B4966A54DC679505962CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
	<20151103.132015.944876907781932861.davem@davemloft.net>
	<BN1PR0301MB07708CE383BA67E83C161370CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kys@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932478AbbKCTuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 14:50:32 -0500
In-Reply-To: <BN1PR0301MB07708CE383BA67E83C161370CA2B0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Tue, 3 Nov 2015 18:49:05 +0000

>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Tuesday, November 3, 2015 1:20 PM
>> To: Haiyang Zhang <haiyangz@microsoft.com>
>> Cc: eric.dumazet@gmail.com; KY Srinivasan <kys@microsoft.com>;
>> edumazet@google.com; netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next] net: increase LL_MAX_HEADER if HYPERV_NET
>> is enabled
>> 
>> From: Haiyang Zhang <haiyangz@microsoft.com>
>> Date: Tue, 3 Nov 2015 17:34:47 +0000
>> 
>> > But we still keep this busy return in our code, just for "weird corner cases".
>> 
>> The queue_stopped condition must be precise.
> 
> The only case we return NETDEV_TX_BUSY is when the outgoing ring buffer is full, 
> which almost never happens because we stop the xmit queue if ring is <10% available.

I don't think you understand.

You must perform the queue stop operation such that it is impossible for your
->ndo_start_xmit() method to be invoked in a way such that you cannot transmit
the SKB given to you immediately.

It's quite tiring to keep trying to explain this over and over repeatedly.
