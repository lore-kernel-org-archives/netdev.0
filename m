From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 14 Apr 2010 22:39:49 +0200
Message-ID: <201004142239.50299.arnd@arndb.de>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <201004141835.57673.arnd@arndb.de> <20100414203142.GA11321@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100414203142.GA11321@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 April 2010 22:31:42 Michael S. Tsirkin wrote:
> On Wed, Apr 14, 2010 at 06:35:57PM +0200, Arnd Bergmann wrote:
> > On Wednesday 14 April 2010, Michael S. Tsirkin wrote:
> > > > > 
> > > > > qemu needs the ability to inject raw packets into device
> > > > > from userspace, bypassing vhost/virtio (for live migration).
> > > > 
> > > > Ok, but since there is only a write callback and no read, it won't
> > > > actually be able to do this with the current code, right?
> > > 
> > > I think it'll work as is, with vhost qemu only ever writes,
> > > never reads from device. We'll also never need GSO etc
> > > which is a large part of what tap does (and macvtap will
> > > have to do).
> > 
> > Ah, I see. I didn't realize that qemu needs to write to the
> > device even if vhost is used. But for the case of migration to
> > another machine without vhost, wouldn't qemu also need to read?
> 
> Not that I know. Why?

Well, if the guest not only wants to send data but also receive
frames coming from other machines, they need to get from the kernel
into qemu, and the only way I can see for doing that is to read
from this device if there is no vhost support around on the new
machine.

Maybe we're talking about different things here.

	Arnd
