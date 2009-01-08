From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 8 Jan 2009 13:51:27 -0800
Message-ID: <20090108215127.GA28935@ovro.caltech.edu>
References: <20090107195052.GA24981@ovro.caltech.edu> <20090108.111610.132149837.davem@davemloft.net> <20090108192716.GA19863@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, shemminger@vyatta.com, arnd@arndb.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:58441 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758379AbZAHVv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:51:29 -0500
Content-Disposition: inline
In-Reply-To: <20090108192716.GA19863@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 11:27:16AM -0800, Ira Snyder wrote:
> On Thu, Jan 08, 2009 at 11:16:10AM -0800, David Miller wrote:
> > From: Ira Snyder <iws@ovro.caltech.edu>
> > Date: Wed, 7 Jan 2009 11:50:52 -0800
> > 
> > > This adds support to Linux for a virtual ethernet interface which uses the
> > > PCI bus as its transport mechanism. It creates a simple, familiar, and fast
> > > method of communication for two devices connected by a PCI interface.
> > 
> > Well, it looks like much more than that to me.
> > 
> > What is this UART thing in here for?
> > 
> > I can only assume it's meant to be used as a console port between the
> > x86 host and the powerpc nodes.
> > 
> 
> Exactly right. I needed it to tell the U-Boot bootloader to tftp the
> kernel and boot the board. These boards don't keep their PCI settings
> (assigned by the BIOS at boot) over a soft or hard reset.
> 
> I couldn't think of a better way to get them started.
> 
> > You haven't even mentioned this UART aspect even indirectly in the
> > commit message.
> > 
> 
> Sorry, I'll add something about it.
> 
> > This just looks like yet another set of virtualization drivers
> > to me.  You could have just have easily built this using your
> > own PCI backplane framework, and using the virtio stuff on top.
> > 
> > And the virtio stuff has all kinds of snazzy optimizations that
> > will likely improve your throughput, it has console drivers that
> > distributions already probe for and attach appropriately, etc.
> > 
> > In short I really don't like this conceptually, it can be done
> > so much better using facilities we already have that are
> > heavily optimized and userland understands already.
> 
> I've had a really hard time understanding the virtio code. I haven't
> been able to find much in the way of documentation for it. Can you point
> me to some code that does anything vaguely similar to what you are
> suggesting?
> 
> Arnd Bergmann said that there is a similar driver (for different
> hardware) that uses virtio, but it is very slow, because it doesn't use
> the DMA controller to transfer data. I need at very minimum 40MB/sec of
> client -> host data transfer.
> 

Rusty, since you wrote the virtio code, can you point me at the things I
would need to implement to use virtio over the PCI bus.

The guests (PowerPC computers running Linux) are PCI cards in the host
system (an Intel Pentium3-M system). The guest computers can access all
of the host's memory. The guests provide a 1MB (movable) window into
their memory.

The PowerPC computers also have a DMA controller, which I've used to get
better throughput from my driver. I have a way to create interrupts to
both the host and guest systems.

I've read your paper titled: "virtio: Towards a De-Facto Standard For
Virtual I/O Devices"

If I read that correctly, then I should implement all of the functions
in struct virtqueue_ops appropriately, and the existing virtio drivers
should just work. The only concern I have there is how to make guest ->
host transfer use the DMA controller. I've done all programming of it
from the guest kernel, using the Linux DMAEngine API.

Are there any other implementations other than virtio_ring?

I appreciate any input you can give. If I should be CCing someone else,
just let me know and I'll drop you from the CC list.

Thanks,
Ira
