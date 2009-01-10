From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Sat, 10 Jan 2009 12:18:17 -0600
Message-ID: <4968E669.8040707@codemonkey.ws>
References: <1231351563.7109.130.camel@lappy> <200901102148.54962.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>,
	kvm <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Mark McLoughlin <markmc@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:17224 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbZAJSS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 13:18:28 -0500
In-Reply-To: <200901102148.54962.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Thursday 08 January 2009 04:36:03 Alex Williamson wrote:
>   
>> virtio_net: Add MAC fitler table support
>>     
>
> Ah, I see.  You really want multiple mac addresses, not just multicast
> filtering?
>
> Anthony, you think a control channel?  We can add a virtqueue, but it seems like a lot of work...
>   

I think it's the only way to solve the problem in a virtio friendly way.

Another option would be extending the config space by a very large 
size.  We would have to make some changes to virtio-pci to switch to 
MMIO but that's easy enough.  From a high level perspective, I don't 
like the idea of having the config space be extremely large and used as 
a communication mechanism between guests.  It really should be for 
device configuration data that's relatively static.  I think we abuse 
the config space in the virtio-balloon driver.

Ideally, you'd have an area of guest memory sized by the guest (so there 
was no intrinsic limit on table size) that was given to the host to use 
as the filter tables.  The only way this works with virtio is if you 
send this over a virtqueue in the form of messages.  You could write a 
pfn to the config space but then you lose all the mapping/unmapping 
abstraction that virtqueue gives you (even though we don't do anything 
useful with that abstraction today :-)).

So yeah, I think a control queue is the way to go.

Regards,

Anthony Liguori

> Rusty.
>   

