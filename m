From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Thu, 05 Jan 2012 14:13:31 -0500 (EST)
Message-ID: <20120105.141331.83457091828476806.davem@davemloft.net>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	<1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	<1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab2AETNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:13:36 -0500
In-Reply-To: <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jan 2012 18:46:47 +0100

>> @@ -189,8 +189,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
>>  	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
>>  	 * Both skb->head and skb_shared_info are cache line aligned.
>>  	 */
>> -	size = SKB_DATA_ALIGN(size);
>> -	size += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>> +	size = SKB_DATA_ALIGN(size + sizeof(struct skb_shared_info));
>>  	data = kmalloc_node_track_caller(size, gfp_mask, node);
>>  	if (!data)
>>  		goto nodata;
> 
> Unfortunately this makes the frequently use part of skb_shared_info not
> any more in a single cache line.
> 
> This will slow down many operations like kfree_skb() of cold skbs (TX
> completion for example)

My concerns match Eric's here.

Ian, you state that you attempted to look into schemes that put the
destructor info somewhere other than skb_shared_info() and that none
of them worked well.

But what kind of issues do you run into if you add this into struct
page itself?  Other subsystems could then use this facility too, and
if I recall there was even some talk of this.
