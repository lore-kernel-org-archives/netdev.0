From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH v3 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 14 Apr 2010 18:35:57 +0200
Message-ID: <201004141835.57673.arnd@arndb.de>
References: <1270805865-16901-1-git-send-email-xiaohui.xin@intel.com> <201004141757.54829.arnd@arndb.de> <20100414161610.GA10897@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	jdike@linux.intel.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:50470 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407Ab0DNQgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 12:36:09 -0400
In-Reply-To: <20100414161610.GA10897@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 April 2010, Michael S. Tsirkin wrote:
> > > 
> > > qemu needs the ability to inject raw packets into device
> > > from userspace, bypassing vhost/virtio (for live migration).
> > 
> > Ok, but since there is only a write callback and no read, it won't
> > actually be able to do this with the current code, right?
> 
> I think it'll work as is, with vhost qemu only ever writes,
> never reads from device. We'll also never need GSO etc
> which is a large part of what tap does (and macvtap will
> have to do).

Ah, I see. I didn't realize that qemu needs to write to the
device even if vhost is used. But for the case of migration to
another machine without vhost, wouldn't qemu also need to read?

> > Moreover, it seems weird to have a new type of interface here that
> > duplicates tap/macvtap with less functionality. Coming back
> > to your original comment, this means that while mpassthru is currently
> > not duplicating the actual code from macvtap, it would need to do
> > exactly that to get the qemu interface right!
> > 
> I don't think so, see above. anyway, both can reuse tun.c :)

There is one significant difference between macvtap/mpassthru and
tun/tap in that the directions are reversed. While macvtap and
mpassthru forward data from write into dev_queue_xmit and from
skb_receive into read, tun/tap forwards data from write into
skb_receive and from start_xmit into read.

Also, I'm not really objecting to duplicating code between
macvtap and mpassthru, as the implementation can always be merged.
My main objection is instead to having two different _user_interfaces_
for doing the same thing.

	Arnd
