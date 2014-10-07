From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1] xen-netfront: always keep the Rx ring full
 of requests
Date: Tue, 7 Oct 2014 10:43:36 +0100
Message-ID: <5433B5C8.9060309@citrix.com>
References: <5432B6D2.9030503@oracle.com>	<5432BC96.6060709@citrix.com>	<5432E26C.3020207@oracle.com> <20141006.170748.1817067290457286845.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <boris.ostrovsky@oracle.com>,
	<xen-devel@lists.xenproject.org>
To: David Miller <davem@redhat.com>, <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7324 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbaJGJnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 05:43:39 -0400
In-Reply-To: <20141006.170748.1817067290457286845.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/14 22:07, David Miller wrote:
> From: annie li <annie.li@oracle.com>
> Date: Mon, 06 Oct 2014 14:41:48 -0400
> 
>>
>> On 2014/10/6 12:00, David Vrabel wrote:
>>>>>    +    queue->rx.req_prod_pvt = req_prod;
>>>>> +
>>>>> +    /* Not enough requests? Try again later. */
>>>>> +    if (req_prod - queue->rx.rsp_cons < NET_RX_SLOTS_MIN) {
>>>>> +        mod_timer(&queue->rx_refill_timer, jiffies + (HZ/10));
>>>>> +        return;
>>>> If the previous for loop breaks because of failure of
>>>> xennet_alloc_one_rx_buffer, then notify_remote_via_irq is missed here
>>>> if
>>>> the code returns directly.
>>> This is deliberate -- there's no point notifying the backend if there
>>> aren't enough requests for the next packet.  Since we don't know what
>>> the next packet might be we assume it's the largest possible.
>> That makes sense.
>> However, the largest packet case does not happen so
>> frequently. Moreover, netback checks the slots every incoming skb
>> requires in xenvif_rx_ring_slots_available, not only concerning the
>> largest case.

An upcoming change to netback will cause it to wait for enough slots for
the largest possible packet.

> I have an opinion about the sysfs stuff.
> 
> It's user facing, so even if it doesn't influence behavior any more
> you have to keep the files around, just make them nops.

That's a good point.

David
