From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Focusing the XDP project
Date: Wed, 22 Feb 2017 10:43:28 +0100
Message-ID: <20170222104328.4b9c6c5d@redhat.com>
References: <20170220111343.76f77748@redhat.com>
        <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
        <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com>
        <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
        <CALzJLG-323ZOyruHok3=jz526bnw=SoYtYSym8RrA3Z5=g0u9Q@mail.gmail.com>
        <CALx6S37s=Kcy+wEbojVHjiAoLZC_4V5qzMLe=-QXtJYVtwTAew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43194 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751347AbdBVJnd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Feb 2017 04:43:33 -0500
In-Reply-To: <CALx6S37s=Kcy+wEbojVHjiAoLZC_4V5qzMLe=-QXtJYVtwTAew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 21 Feb 2017 14:54:35 -0800 Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Feb 21, 2017 at 2:29 PM, Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
[...]
> > The only complexity XDP is adding to the drivers is the constrains on
> > RX memory management and memory model, calling the XDP program itself
> > and handling the  action is really a simple thing once you have the
> > correct memory model.

Exactly, that is why I've been looking at introducing a generic
facility for a memory model for drivers.  This should help simply
drivers.  Due to performance needs this need to be a very thin API layer
on top of the page allocator. (That's why I'm working with Mel Gorman
to get more close integration with the page allocator e.g. a bulking
facility).

> > Who knows! maybe someday XDP will define one unified RX API for all
> > drivers and it even will handle normal stack delivery it self :).
> >  
> That's exactly the point and what we need for TXDP. I'm missing why
> doing this is such rocket science other than the fact that all these
> drivers are vastly different and changing the existing API is
> unpleasant. The only functional complexity I see in creating a generic
> batching interface is handling return codes asynchronously. This is
> entirely feasible though...

I'll be happy as long as we get a batching interface, then we can
incrementally do the optimizations later.

In the future, I do hope (like Saeed) this RX API will evolve into
delivering (a bulk of) raw-packet-pages into the netstack, this should
simplify drivers, and we can keep the complexity and SKB allocations
out of the drivers.
To start with, we can play with doing this delivering (a bulk of)
raw-packet-pages into Tom's TXDP engine/system?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
