From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Thu, 27 Oct 2016 18:43:59 -0700
Message-ID: <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
References: <20161028002814-mutt-send-email-mst@kernel.org>
 <20161027.174218.654961317277160121.davem@davemloft.net> <20161028011739-mutt-send-email-mst@kernel.org>
 <20161027.213512.334468356710231957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        shrijeet@gmail.com, Tom Herbert <tom@herbertland.com>,
        Netdev <netdev@vger.kernel.org>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>, nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33918 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933403AbcJ1BoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 21:44:01 -0400
Received: by mail-oi0-f68.google.com with SMTP id p136so7601925oic.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 18:44:00 -0700 (PDT)
In-Reply-To: <20161027.213512.334468356710231957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 6:35 PM, David Miller <davem@davemloft.net> wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 28 Oct 2016 01:25:48 +0300
>
>> On Thu, Oct 27, 2016 at 05:42:18PM -0400, David Miller wrote:
>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>> Date: Fri, 28 Oct 2016 00:30:35 +0300
>>>
>>> > Something I'd like to understand is how does XDP address the
>>> > problem that 100Byte packets are consuming 4K of memory now.
>>>
>>> Via page pools.  We're going to make a generic one, but right now
>>> each and every driver implements a quick list of pages to allocate
>>> from (and thus avoid the DMA man/unmap overhead, etc.)
>>
>> So to clarify, ATM virtio doesn't attempt to avoid dma map/unmap
>> so there should be no issue with that even when using sub/page
>> regions, assuming DMA APIs support sub-page map/unmap correctly.
>
> That's not what I said.
>
> The page pools are meant to address the performance degradation from
> going to having one packet per page for the sake of XDP's
> requirements.
>
> You still need to have one packet per page for correct XDP operation
> whether you do page pools or not, and whether you have DMA mapping
> (or it's equivalent virutalization operation) or not.

Maybe I am missing something here, but why do you need to limit things
to one packet per page for correct XDP operation?  Most of the drivers
out there now are usually storing something closer to at least 2
packets per page, and with the DMA API fixes I am working on there
should be no issue with changing the contents inside those pages since
we won't invalidate or overwrite the data after the DMA buffer has
been synchronized for use by the CPU.
