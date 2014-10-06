From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx ring full
 of requests
Date: Mon, 06 Oct 2014 14:41:48 -0400
Message-ID: <5432E26C.3020207@oracle.com>
References: <1412256826-18874-1-git-send-email-david.vrabel@citrix.com> <5432B6D2.9030503@oracle.com> <5432BC96.6060709@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20039 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753036AbaJFSmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 14:42:01 -0400
In-Reply-To: <5432BC96.6060709@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/10/6 12:00, David Vrabel wrote:
>>>    +    queue->rx.req_prod_pvt = req_prod;
>>> +
>>> +    /* Not enough requests? Try again later. */
>>> +    if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
>>> +        mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
>>> +        return;
>> If the previous for loop breaks because of failure of
>> xennet_alloc_one_rx_buffer, then notify_remote_via_irq is missed here if
>> the code returns directly.
> This is deliberate -- there's no point notifying the backend if there
> aren't enough requests for the next packet.  Since we don't know what
> the next packet might be we assume it's the largest possible.
That makes sense.
However, the largest packet case does not happen so frequently. 
Moreover, netback checks the slots every incoming skb requires in 
xenvif_rx_ring_slots_available, not only concerning the largest case.

Thanks
Annie
