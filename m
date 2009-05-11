From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries
 (VIRTIO_RING_F_INDIRECT_DESC)
Date: Mon, 11 May 2009 18:10:38 +0100
Message-ID: <1242061838.25337.8.camel@blaa>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com>
	 <1240318745.443.42.camel@blaa> <49F56239.9010509@redhat.com>
	 <200905041149.00724.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dlaor@redhat.com, netdev@vger.kernel.org,
	Dor Laor <dor@redhat.com>, Avi Kivity <avi@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53988 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900AbZEKRLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 13:11:45 -0400
In-Reply-To: <200905041149.00724.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-05-04 at 11:49 +0930, Rusty Russell wrote:
> On Mon, 27 Apr 2009 05:13:53 pm Dor Laor wrote:
> > Mark McLoughlin wrote:
> > > Hi Rusty,
> > >
> > > On Thu, 2008-12-18 at 17:10 +0000, Mark McLoughlin wrote:
> > >   
> > >> Add a new feature flag for indirect ring entries. These are ring
> > >> entries which point to a table of buffer descriptors.
> > >>
> > >> The idea here is to increase the ring capacity by allowing a larger
> > >> effective ring size whereby the ring size dictates the number of
> > >> requests that may be outstanding, rather than the size of those
> > >> requests.
> 
> OK, just so we track our mistakes.
> 
> 1) virtio_rings must be physically contiguous, even though they actually
>    have two independent parts.
> 2) The number of elements in a ring must be a power of 2.
> 3) virtio_pci tells the guest what number of elements to use.
> 4) The guest has to allocate that much physically contiguous memory, or fail.
> 
> In practice, 128 elements = 2 pages, 256 elements = 3 pages, 512 elements
> = 5 pages.  Order 1, order 2, order 3 under Linux.  1 is OK, 2 is iffy, 3 is
> hard.
> 
> Blocked from doing the simpler thing, we've decided to go with a layer
> of indirection.  But the patch is simple and clean, so there's nothing
> fundamental to object to.

Still have one FIXME in the patch worth looking at - at what point
should we use an indirect entry rather than consuming N entries? 

> I can't find 3/3, did it go missing?

Following up with all three patches again.

Cheers,
Mark.

