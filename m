From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: use skb to determine number
 of required guest Rx requests
Date: Fri, 15 Jan 2016 10:31:57 +0000
Message-ID: <5698CA9D.5040707@citrix.com>
References: <1452784710-11923-1-git-send-email-david.vrabel@citrix.com>
 <20160114.165456.1025501284568544813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>, <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:62373 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176AbcAOKcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 05:32:07 -0500
In-Reply-To: <20160114.165456.1025501284568544813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/16 21:54, David Miller wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Thu, 14 Jan 2016 15:18:30 +0000
> 
>> -	needed = xenvif_rx_ring_slots_needed(queue->vif);
>> +	skb = skb_peek(&queue->rx_queue);
>> +	if (!skb)
>> +		return false;
>> +
>> +	needed = DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
>> +	if (skb_is_gso(skb))
>> +		needed++;
> 
> If I am not mistaken, we moved away from this kind of test exactly because
> it is inaccurate and may under-estimate the needs.
> 
> It is possible for an N byte SKB to require N segments.  Therefore, the:
> 
> 	DIV_ROUND_UP(skb->len, XEN_PAGE_SIZE);
> 
> calculation doesn't cut it.

After 1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b (xen-netback: always
fully coalesce guest Rx packets) we always fully pack a packet into its
guest Rx slots.  Each slot has space for XEN_PAGE_SIZE bytes so this
calculation for the number of slots is correct.

Shall I resend with a more description changelog?

David
