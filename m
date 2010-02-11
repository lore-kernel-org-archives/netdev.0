From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Thu, 11 Feb 2010 15:40:08 +0800
Message-ID: <97F6D3BD476C464182C1B7BABF0B0AF5C11F641A@shzsmsx502.ccr.corp.intel.com>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
 <201002101440.05063.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>, "mst@redhat.com" <mst@redhat.com>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <201002101440.05063.arnd@arndb.de>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>On Wednesday 10 February 2010, Xin Xiaohui wrote:
> >The idea is simple, just to pin the guest VM user space and then
> >let host NIC driver has the chance to directly DMA to it. 
> >The patches are based on vhost-net backend driver. We add a device
> >which provides proto_ops as sendmsg/recvmsg to vhost-net to
> >send/recv directly to/from the NIC driver. KVM guest who use the
> >vhost-net backend may bind any ethX interface in the host side to
> >get copyless data transfer thru guest virtio-net frontend.
>> 
>> We provide multiple submits and asynchronous notifiicaton to 
> >vhost-net too.

>This does a lot of things that I had planned for macvtap. It's
>great to hear that you have made this much progress.
>
>However, I'd hope that we could combine this with the macvtap driver,
>which would give us zero-copy transfer capability both with and
>without vhost, as well as (tx at least) when using multiple guests
>on a macvlan setup.

You mean the zero-copy can work with macvtap driver without vhost.
May you give me some detailed info about your macvtap driver and the
relationship between vhost and macvtap to make me have a clear picture then?

>For transmit, it should be fairly straightforward to hook up
>your zero-copy method and the vhost-net interface into the
>macvtap driver.
>
>You have simplified the receiv path significantly by assuming
>that the entire netdev can receive into a single guest, right?

Yes.

>I'm assuming that the idea is to allow VMDq adapters to simply
>show up as separate adapters and have the driver handle this
>in a hardware specific way.

Does the VMDq driver do so now?

>My plan for this was to instead move support for VMDq into the
>macvlan driver so we can transparently use VMDq on hardware where
>available, including zero-copy receives, but fall back to software
>operation on non-VMDq hardware.

	Arnd
