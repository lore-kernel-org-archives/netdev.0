From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] A device for zero-copy based on KVM virtio-net.
Date: Wed, 7 Apr 2010 11:15:32 +0300
Message-ID: <20100407081532.GB9550@redhat.com>
References: <20100308112849.GI7482@redhat.com> <1270114038-5048-1-git-send-email-xiaohui.xin@intel.com> <20100401110841.GE3323@redhat.com> <97F6D3BD476C464182C1B7BABF0B0AF5C183234A@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"jdike@c2.user-mode-linux.org" <jdike@c2.user-mode-linux.org>,
	"yzhao81@gmail.com" <yzhao81@gmail.com>
To: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064Ab0DGITn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 04:19:43 -0400
Content-Disposition: inline
In-Reply-To: <97F6D3BD476C464182C1B7BABF0B0AF5C183234A@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 07, 2010 at 10:41:08AM +0800, Xin, Xiaohui wrote:
> Michael,
>  
> >> Qemu needs a userspace write, is that a synchronous one or
> >>asynchronous one?
> 
> >It's a synchronous non-blocking write.
> Sorry, why the Qemu live migration needs the device have a userspace write?
> how does the write operation work? And why a read operation is not cared here?
> 
> Thanks
> Xiaohui

Roughly, with ethernet bridges, moving a device from one location in
the network to another makes forwarding tables incorrect (or incomplete),
until outgoing traffic from the device causes these tables
to be updated. Since there's no guarantee that guest
will generate outgoing traffic, after migration qemu sends out several
dummy packets itself.

-- 
MST
