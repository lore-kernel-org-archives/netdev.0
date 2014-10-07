From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx ring full
 of requests
Date: Tue, 07 Oct 2014 09:12:30 -0400
Message-ID: <5433E6BE.6070401@oracle.com>
References: <5432B6D2.9030503@oracle.com>	<5432BC96.6060709@citrix.com>	<5432E26C.3020207@oracle.com> <20141006.170748.1817067290457286845.davem@redhat.com> <5433B5C8.9060309@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@redhat.com>, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31688 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaJGNMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 09:12:45 -0400
In-Reply-To: <5433B5C8.9060309@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2014/10/7 5:43, David Vrabel wrote:
> On 06/10/14 22:07, David Miller wrote:
>> From: annie li <annie.li@oracle.com>
>> Date: Mon, 06 Oct 2014 14:41:48 -0400
>>
>>> On 2014/10/6 12:00, David Vrabel wrote:
>>>>>>     +    queue->rx.req_prod_pvt = req_prod;
>>>>>> +
>>>>>> +    /* Not enough requests? Try again later. */
>>>>>> +    if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
>>>>>> +        mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
>>>>>> +        return;
>>>>> If the previous for loop breaks because of failure of
>>>>> xennet_alloc_one_rx_buffer, then notify_remote_via_irq is missed here
>>>>> if
>>>>> the code returns directly.
>>>> This is deliberate -- there's no point notifying the backend if there
>>>> aren't enough requests for the next packet.  Since we don't know what
>>>> the next packet might be we assume it's the largest possible.
>>> That makes sense.
>>> However, the largest packet case does not happen so
>>> frequently. Moreover, netback checks the slots every incoming skb
>>> requires in xenvif_rx_ring_slots_available, not only concerning the
>>> largest case.
> An upcoming change to netback will cause it to wait for enough slots for
> the largest possible packet.

Netback knows the exact slot number that incoming skb will consumes, is 
there any reason to let it wait for the largest possible packets?

Thanks
Annie
