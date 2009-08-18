From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Alacrityvm-devel] [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver objects
Date: Tue, 18 Aug 2009 21:04:30 +0000
Message-ID: <200908182104.30500.arnd@arndb.de>
References: <4A870964.9090408@codemonkey.ws> <20090818182735.GD17631@ovro.caltech.edu> <20090818203522.GA20393@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>,
	Avi Kivity <avi@redhat.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>,
	Gregory Haskins <ghaskins@novell.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752178AbZHRVEh@vger.kernel.org>
In-Reply-To: <20090818203522.GA20393@redhat.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 August 2009 20:35:22 Michael S. Tsirkin wrote:
> On Tue, Aug 18, 2009 at 10:27:52AM -0700, Ira W. Snyder wrote:
> > Also, in my case I'd like to boot Linux with my rootfs over NFS. Is
> > vhost-net capable of this?
> > 
> > I've had Arnd, BenH, and Grant Likely (and others, privately) contact me
> > about devices they are working with that would benefit from something
> > like virtio-over-PCI. I'd like to see vhost-net be merged with the
> > capability to support my use case. There are plenty of others that would
> > benefit, not just myself.

yes.

> > I'm not sure vhost-net is being written with this kind of future use in
> > mind. I'd hate to see it get merged, and then have to change the ABI to
> > support physical-device-to-device usage. It would be better to keep
> > future use in mind now, rather than try and hack it in later.
> 
> I still need to think your usage over. I am not so sure this fits what
> vhost is trying to do. If not, possibly it's better to just have a
> separate driver for your device.

I now think we need both. virtio-over-PCI does it the right way for its
purpose and can be rather generic. It could certainly be extended to
support virtio-net on both sides (host and guest) of KVM, but I think
it better fits the use where a kernel wants to communicate with some
other machine where you normally wouldn't think of using qemu.

Vhost-net OTOH is great in the way that it serves as an easy way to
move the virtio-net code from qemu into the kernel, without changing
its behaviour. It should even straightforward to do live-migration between
hosts with and without it, something that would be much harder with
the virtio-over-PCI logic. Also, its internal state is local to the
process owning its file descriptor, which makes it much easier to
manage permissions and cleanup of its resources.

	Arnd <><
