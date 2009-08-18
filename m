From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus
	model for vbus_driver objects
Date: Tue, 18 Aug 2009 23:39:21 +0300
Message-ID: <20090818203921.GB20393@redhat.com>
References: <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <20090817174142.GA11140@redhat.com> <4A89BAC5.9040400@gmail.com> <20090818084606.GA13878@redhat.com> <20090818155329.GD31060@ovro.caltech.edu> <4A8ADC09.3030205@redhat.com> <20090818172752.GC17631@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751991AbZHRUlI@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090818172752.GC17631@ovro.caltech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 18, 2009 at 10:27:52AM -0700, Ira W. Snyder wrote:
> On Tue, Aug 18, 2009 at 07:51:21PM +0300, Avi Kivity wrote:
> > On 08/18/2009 06:53 PM, Ira W. Snyder wrote:
> >> So, in my system, copy_(to|from)_user() is completely wrong. There is no
> >> userspace, only a physical system. In fact, because normal x86 computers
> >> do not have DMA controllers, the host system doesn't actually handle any
> >> data transfer!
> >>    
> >
> > In fact, modern x86s do have dma engines these days (google for Intel  
> > I/OAT), and one of our plans for vhost-net is to allow their use for  
> > packets above a certain size.  So a patch allowing vhost-net to  
> > optionally use a dma engine is a good thing.
> >
> 
> Yes, I'm aware that very modern x86 PCs have general purpose DMA
> engines, even though I don't have any capable hardware. However, I think
> it is better to support using any PC (with or without DMA engine, any
> architecture) as the PCI master, and just handle the DMA all from the
> PCI agent, which is known to have DMA?
> 
> >> I used virtio-net in both the guest and host systems in my example
> >> virtio-over-PCI patch, and succeeded in getting them to communicate.
> >> However, the lack of any setup interface means that the devices must be
> >> hardcoded into both drivers, when the decision could be up to userspace.
> >> I think this is a problem that vbus could solve.
> >>    
> >
> > Exposing a knob to userspace is not an insurmountable problem; vhost-net  
> > already allows changing the memory layout, for example.
> >
> 
> Let me explain the most obvious problem I ran into: setting the MAC
> addresses used in virtio.
> 
> On the host (PCI master), I want eth0 (virtio-net) to get a random MAC
> address.
> 
> On the guest (PCI agent), I want eth0 (virtio-net) to get a specific MAC
> address, aa:bb:cc:dd:ee:ff.
> 
> The virtio feature negotiation code handles this, by seeing the
> VIRTIO_NET_F_MAC feature in it's configuration space. If BOTH drivers do
> not have VIRTIO_NET_F_MAC set, then NEITHER will use the specified MAC
> address. This is because the feature negotiation code only accepts a
> feature if it is offered by both sides of the connection.
> 
> In this case, I must have the guest generate a random MAC address and
> have the host put aa:bb:cc:dd:ee:ff into the guest's configuration
> space. This basically means hardcoding the MAC addresses in the Linux
> drivers, which is a big no-no.
> 
> What would I expose to userspace to make this situation manageable?
> 
> Thanks for the response,
> Ira

This calls for some kind of change in guest virtio.  vhost being a host
kernel only feature, does not deal with this problem.  But assuming
virtio in guest supports this somehow, vhost will not interfere: you do
the setup in qemu userspace anyway, vhost will happily use a network
device however you chose to set it up.

-- 
MST
