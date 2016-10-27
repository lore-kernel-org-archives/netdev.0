From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 28 Oct 2016 01:25:48 +0300
Message-ID: <20161028011739-mutt-send-email-mst@kernel.org>
References: <20161027105514.4c0374dd@redhat.com>
 <58126CF4.5090500@gmail.com>
 <20161028002814-mutt-send-email-mst@kernel.org>
 <20161027.174218.654961317277160121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, brouer@redhat.com, shrijeet@gmail.com,
        tom@herbertland.com, netdev@vger.kernel.org,
        shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034190AbcJ0WZv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 18:25:51 -0400
Content-Disposition: inline
In-Reply-To: <20161027.174218.654961317277160121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 27, 2016 at 05:42:18PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Fri, 28 Oct 2016 00:30:35 +0300
> 
> > Something I'd like to understand is how does XDP address the
> > problem that 100Byte packets are consuming 4K of memory now.
> 
> Via page pools.  We're going to make a generic one, but right now
> each and every driver implements a quick list of pages to allocate
> from (and thus avoid the DMA man/unmap overhead, etc.)

So to clarify, ATM virtio doesn't attempt to avoid dma map/unmap
so there should be no issue with that even when using sub/page
regions, assuming DMA APIs support sub-page map/unmap correctly.

The only reason virtio attempts to use sub-page fragments is to conserve
memory so that truesize for a 100byte packets won't be 4K. Are you
saying pools will somehow mean we won't need to worry about that so
effectively truesize=100byte even though the rest of the 4k page goes
unused? If so we'll happily go back to allocate memory in 4K chunks like
we used to before 2613af0ed18a, and remove a bunch of complexity.

-- 
MST
