From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: Fix handling of skbs requiring
 too many slots
Date: Wed, 04 Jun 2014 11:59:45 -0400
Message-ID: <538F4271.7080505@oracle.com>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com> <538F369B.7010100@oracle.com> <538F3E6A.7000002@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, linux@eikelenboom.it,
	paul.durrant@citrix.com, david.vrabel@citrix.com,
	xen-devel@lists.xenproject.org, davem@davemloft.net
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32490 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbaFDP75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 11:59:57 -0400
In-Reply-To: <538F3E6A.7000002@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/6/4 11:42, Zoltan Kiss wrote:
> On 04/06/14 16:09, annie li wrote:
>>
>> On 2014/6/3 16:30, Zoltan Kiss wrote:
>>> A recent commit (a02eb4 "xen-netback: worse-case estimate in
>>> xenvif_rx_action is
>>> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but
>>> that triggers
>>> the next BUG_ON a few lines down, as the packet consumes more slots 
>>> than
>>> estimated.
>>> This patch introduces full_coalesce on the skb callback buffer, which
>>> is used in
>>> start_new_rx_buffer() to decide whether netback needs coalescing more
>>> aggresively. By doing that, no packet should need more than
>>> XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE data slots,
>>
>> (XEN_NETIF_MAX_TX_SIZE+1) / PAGE_SIZE here?
>
> Do you think about the GSO slot? That's why I wrote "data slot", 
> however that's probably not a clear terminology.

What I mean is: XEN_NETIF_MAX_TX_SIZE is 0xFFFF, and 
XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE turns out to be 15 slots when 
PAGE_SIZE is 4096. You was trying to use XEN_NETIF_MAX_TX_SIZE as max 
size of packet - 64k?

> I'll add then that excluding GSO slot, as it doesn't carry data 
> directly, therefore it's irrelevant from this point of view.

Correct.:-)

Thanks
Annie
>
> Zoli
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
