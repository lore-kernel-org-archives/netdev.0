From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3] Provide a zero-copy method on KVM virtio-net.
Date: Wed, 10 Feb 2010 14:40:04 +0100
Message-ID: <201002101440.05063.arnd@arndb.de>
References: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, mst@redhat.com,
	jdike@c2.user-mode-linux.org
To: Xin Xiaohui <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:52084 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835Ab0BJNkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 08:40:35 -0500
In-Reply-To: <1265802540-6122-1-git-send-email-xiaohui.xin@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 February 2010, Xin Xiaohui wrote:
> The idea is simple, just to pin the guest VM user space and then
> let host NIC driver has the chance to directly DMA to it. 
> The patches are based on vhost-net backend driver. We add a device
> which provides proto_ops as sendmsg/recvmsg to vhost-net to
> send/recv directly to/from the NIC driver. KVM guest who use the
> vhost-net backend may bind any ethX interface in the host side to
> get copyless data transfer thru guest virtio-net frontend.
> 
> We provide multiple submits and asynchronous notifiicaton to 
> vhost-net too.

This does a lot of things that I had planned for macvtap. It's
great to hear that you have made this much progress.

However, I'd hope that we could combine this with the macvtap driver,
which would give us zero-copy transfer capability both with and
without vhost, as well as (tx at least) when using multiple guests
on a macvlan setup.

For transmit, it should be fairly straightforward to hook up
your zero-copy method and the vhost-net interface into the
macvtap driver.

You have simplified the receiv path significantly by assuming
that the entire netdev can receive into a single guest, right?
I'm assuming that the idea is to allow VMDq adapters to simply
show up as separate adapters and have the driver handle this
in a hardware specific way.
My plan for this was to instead move support for VMDq into the
macvlan driver so we can transparently use VMDq on hardware where
available, including zero-copy receives, but fall back to software
operation on non-VMDq hardware.

	Arnd
