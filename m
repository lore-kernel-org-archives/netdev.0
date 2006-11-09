From: "Jeffrey V. Merkey" <jmerkey@soleranetworks.com>
Subject: Re: e1000 driver 2.6.18 - how to waste processor cycles
Date: Thu, 09 Nov 2006 01:46:52 -0700
Message-ID: <4552EAFC.5060400@soleranetworks.com>
References: <45524E3A.7080301@soleranetworks.com> <4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff V. Merkey" <jmerkey@soleranetworks.com>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	NetDEV list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc14.comcast.net ([204.127.192.84]:14552 "EHLO
	rwcrmhc14.comcast.net") by vger.kernel.org with ESMTP
	id S1753760AbWKIHhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 02:37:36 -0500
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0611081701i26ee7ce0k1f822dbbe52c2c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

> included netdev...
>
> On 11/8/06, Jeff V. Merkey <jmerkey@soleranetworks.com> wrote:
>
>>
>> Is there a good reason the skb refill routine in e1000_alloc_rx_buffers
>> needs to go and touch and remap skb memory
>> on already loaded descriptors/  This seems extremely wasteful of
>> processor cycles when refilling the ring buffer.
>>
>> I note that the archtiecture has changed and is recycling buffers from
>> the rx_irq routine and when the routine is called
>> to refill the ring buffers, a lot of wasteful and needless calls for
>> map_skb is occurring.
>
>
> we have to unmap the descriptor (or at least do
> pci_dma_sync_single_for_cpu / pci_dma_sync_single_for_device) because
> the dma API says we can't be guaranteed the cacheable memory is
> consistent until we do one of the afore mentioned pci dma ops.

In the case I am referring to, the memory is already mapped with a 
previous call, which means it may be getting
mapped twice.

Jeff

>
> we have to do *something* before we access it.  Simplest path is to
> unmap it and then recycle/map it.
>
> If you can show that it is faster to use pci_dma_sync_single_for_cpu
> and friends I'd be glad to take a patch.
>
> Hope this helps,
>  Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

