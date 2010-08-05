From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Fri, 6 Aug 2010 02:20:42 +0300
Message-ID: <20100805232042.GA27651@redhat.com>
References: <20100804230441.GJ23951@ovro.caltech.edu>
 <20100805213050.GA24984@redhat.com>
 <20100805230102.GD4757@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Zang Roy <r61911@freescale.com>, netdev@vger.kernel.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759580Ab0HEX0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 19:26:32 -0400
Content-Disposition: inline
In-Reply-To: <20100805230102.GD4757@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 05, 2010 at 04:01:03PM -0700, Ira W. Snyder wrote:
> On Fri, Aug 06, 2010 at 12:30:50AM +0300, Michael S. Tsirkin wrote:
> > Hi Ira,
> > 
> > > Making my life harder since the last time I tried this, mainline commit
> > > 7c5e9ed0c (virtio_ring: remove a level of indirection) has removed the
> > > possibility of using an alternative virtqueue implementation. The commit
> > > message suggests that you might be willing to add this capability back.
> > > Would this be an option?
> > 
> > Sorry about that.
> > 
> > With respect to this commit, we only had one implementation upstream
> > and extra levels of indirection made extending the API
> > much harder for no apparent benefit.
> > 
> > When there's more than one ring implementation with very small amount of
> > common code, I think that it might make sense to readd the indirection
> > back, to separate the code cleanly.
> > 
> > OTOH if the two implementations share a lot of code, I think that it
> > might be better to just add a couple of if statements here and there.
> > This way compiler even might have a chance to compile the code out if
> > the feature is disabled in kernel config.
> > 
> 
> The virtqueue implementation I envision will be almost identical to the
> current virtio_ring virtqueue implementation, with the following
> exceptions:
> 
> * the "shared memory" will actually be remote, on the PCI BAR of a device
> * iowrite32(), ioread32() and friends will be needed to access the memory
> * there will only be a fixed number of virtqueues available, due to PCI
>   BAR size
> * cross-endian virtqueues must work
> * kick needs to be cross-machine (using PCI IRQ's)
> 
> I don't think it is feasible to add this to the existing implementation.
> I think the requirement of being cross-endian will be the hardest to
> overcome. Rusty did not envision the cross-endian use case when he
> designed this, and it shows, in virtio_ring, virtio_net and vhost. I
> have no idea what to do about this. Do you have any ideas?

My guess is sticking an if around each access in virtio would hurt,
if this is what you are asking about.

Just a crazy idea: vhost already uses wrappers like get_user etc,
maybe when building kernel for your board you could
redefine these to also byteswap?

-- 
MST
