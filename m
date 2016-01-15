From: David Miller <davem@davemloft.net>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: use skb to determine
 number of required guest Rx requests
Date: Fri, 15 Jan 2016 11:34:30 -0500 (EST)
Message-ID: <20160115.113430.2270570646723842525.davem@davemloft.net>
References: <1452784710-11923-1-git-send-email-david.vrabel@citrix.com>
	<20160114.165456.1025501284568544813.davem@davemloft.net>
	<5698CA9D.5040707@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbcAOQed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 11:34:33 -0500
In-Reply-To: <5698CA9D.5040707@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Fri, 15 Jan 2016 10:31:57 +0000

> On 14/01/16 21:54, David Miller wrote:
>> From: David Vrabel <david.vrabel@citrix.com>
>> Date: Thu, 14 Jan 2016 15:18:30 +0000
>> 
>>> -	needed = xenvif_rx_ring_slots_needed(queue->vif);
>>> +	skb = skb_peek(&queue->rx_queue);
>>> +	if (!skb)
>>> +		return false;
>>> +
>>> +	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
>>> +	if (skb_is_gso(skb))
>>> +		needed++;
>> 
>> If I am not mistaken, we moved away from this kind of test exactly because
>> it is inaccurate and may under-estimate the needs.
>> 
>> It is possible for an N byte SKB to require N segments.  Therefore, the:
>> 
>> 	DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
>> 
>> calculation doesn't cut it.
> 
> After 1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b (xen-netback: always
> fully coalesce guest Rx packets) we always fully pack a packet into its
> guest Rx slots.  Each slot has space for XEN_PAGE_SIZE bytes so this
> calculation for the number of slots is correct.
> 
> Shall I resend with a more description changelog?

Yeah that would help a lot.
