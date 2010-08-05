From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: Using virtio as a physical (wire-level) transport
Date: Thu, 5 Aug 2010 16:01:03 -0700
Message-ID: <20100805230102.GD4757@ovro.caltech.edu>
References: <20100804230441.GJ23951@ovro.caltech.edu>
 <20100805213050.GA24984@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	Zang Roy <r61911@freescale.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:52045 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758938Ab0HEXBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 19:01:06 -0400
Content-Disposition: inline
In-Reply-To: <20100805213050.GA24984@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 06, 2010 at 12:30:50AM +0300, Michael S. Tsirkin wrote:
> Hi Ira,
> 
> > Making my life harder since the last time I tried this, mainline commit
> > 7c5e9ed0c (virtio_ring: remove a level of indirection) has removed the
> > possibility of using an alternative virtqueue implementation. The commit
> > message suggests that you might be willing to add this capability back.
> > Would this be an option?
> 
> Sorry about that.
> 
> With respect to this commit, we only had one implementation upstream
> and extra levels of indirection made extending the API
> much harder for no apparent benefit.
> 
> When there's more than one ring implementation with very small amount of
> common code, I think that it might make sense to readd the indirection
> back, to separate the code cleanly.
> 
> OTOH if the two implementations share a lot of code, I think that it
> might be better to just add a couple of if statements here and there.
> This way compiler even might have a chance to compile the code out if
> the feature is disabled in kernel config.
> 

The virtqueue implementation I envision will be almost identical to the
current virtio_ring virtqueue implementation, with the following
exceptions:

* the "shared memory" will actually be remote, on the PCI BAR of a device
* iowrite32(), ioread32() and friends will be needed to access the memory
* there will only be a fixed number of virtqueues available, due to PCI
  BAR size
* cross-endian virtqueues must work
* kick needs to be cross-machine (using PCI IRQ's)

I don't think it is feasible to add this to the existing implementation.
I think the requirement of being cross-endian will be the hardest to
overcome. Rusty did not envision the cross-endian use case when he
designed this, and it shows, in virtio_ring, virtio_net and vhost. I
have no idea what to do about this. Do you have any ideas?


I plan to create a custom socket similar to tun/macvtap which will use
DMA to transfer around data. This, along with a few other tricks, will
allow me to use vhost_net to operate the device. Along with a custom
virtqueue implementation meeting the requirements above, this seems like
a good plan.

Thanks for responding,
Ira
