From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: Fwd: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Mon, 20 Jan 2014 17:49:32 +0100
Message-ID: <20140120164932.GA3569@stefanha-thinkpad>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
 <52D75EA5.1050000@redhat.com>
 <CAEH94Lg7ygXgHqE8ubE+nuunicDqgmnCfO2AuDSS2nXgv5GikQ@mail.gmail.com>
 <20140116085253.GA32073@stefanha-thinkpad.redhat.com>
 <52D89DA0.1020804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhi Yong Wu <zwu.kernel@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbaAUVUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 16:20:47 -0500
Content-Disposition: inline
In-Reply-To: <52D89DA0.1020804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 11:04:00AM +0800, Jason Wang wrote:
> On 01/16/2014 04:52 PM, Stefan Hajnoczi wrote:
> > On Thu, Jan 16, 2014 at 04:34:10PM +0800, Zhi Yong Wu wrote:
> >> CC: stefanha, MST, Rusty Russel
> >>
> >> ---------- Forwarded message ----------
> >> From: Jason Wang <jasowang@redhat.com>
> >> Date: Thu, Jan 16, 2014 at 12:23 PM
> >> Subject: Re: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
> >> To: Zhi Yong Wu <zwu.kernel@gmail.com>
> >> Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com,
> >> davem@davemloft.net, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> >>
> >>
> >> On 01/15/2014 10:20 PM, Zhi Yong Wu wrote:
> >>> From: Zhi Yong Wu<wuzhy@linux.vnet.ibm.com>
> >>>
> >>> HI, folks
> >>>
> >>> The patchset is trying to integrate aRFS support to virtio_net. In this case,
> >>> aRFS will be used to select the RX queue. To make sure that it's going ahead
> >>> in the correct direction, although it is still one RFC and isn't tested, it's
> >>> post out ASAP. Any comment are appreciated, thanks.
> >>>
> >>> If anyone is interested in playing with it, you can get this patchset from my
> >>> dev git on github:
> >>>    git://github.com/wuzhy/kernel.git virtnet_rfs
> >>>
> >>> Zhi Yong Wu (3):
> >>>    virtio_pci: Introduce one new config api vp_get_vq_irq()
> >>>    virtio_net: Introduce one dummy function virtnet_filter_rfs()
> >>>    virtio-net: Add accelerated RFS support
> >>>
> >>>   drivers/net/virtio_net.c      |   67 ++++++++++++++++++++++++++++++++++++++++-
> >>>   drivers/virtio/virtio_pci.c   |   11 +++++++
> >>>   include/linux/virtio_config.h |   12 +++++++
> >>>   3 files changed, 89 insertions(+), 1 deletions(-)
> >>>
> >> Please run get_maintainter.pl before sending the patch. You'd better
> >> at least cc virtio maintainer/list for this.
> >>
> >> The core aRFS method is a noop in this RFC which make this series no
> >> much sense to discuss. You should at least mention the big picture
> >> here in the cover letter. I suggest you should post a RFC which can
> >> run and has expected result or you can just raise a thread for the
> >> design discussion.
> >>
> >> And this method has been discussed before, you can search "[net-next
> >> RFC PATCH 5/5] virtio-net: flow director support" in netdev archive
> >> for a very old prototype implemented by me. It can work and looks like
> >> most of this RFC have already done there.
> >>
> >> A basic question is whether or not we need this, not all the mq cards
> >> use aRFS (see ixgbe ATR). And whether or not it can bring extra
> >> overheads? For virtio, we want to reduce the vmexits as much as
> >> possible but this aRFS seems introduce a lot of more of this. Making a
> >> complex interfaces just for an virtual device may not be good, simple
> >> method may works for most of the cases.
> >>
> >> We really should consider to offload this to real nic. VMDq and L2
> >> forwarding offload may help in this case.
> > Zhi Yong and I had an IRC chat.  I wanted to post my questions on the
> > list - it's still the same concern I had in the old email thread that
> > Jason mentioned.
> >
> > In order for virtio-net aRFS to make sense there needs to be an overall
> > plan for pushing flow mapping information down to the physical NIC.
> > That's the only way to actually achieve the benefit of steering:
> > processing the packet on the CPU where the application is running.
> 
> There are several places that the packet needs to be processing:
> 1) If you mean send the interrupt of virtio-net to the vcpu that the
> application is running, current virito-net has already had the ability
> with the help of flow caches of tun and the vcpu private queue
> configuration of XPS and irq affinity hint which is automatically done
> through the driver itself.
> 2) If you mean send the interrupt or doing the softirq of the host card
> to the cpu where vhost thread is running, recent RFS support of tun can
> do this.
> 3) And about the affinity of vhost thread and vcpu thread, this seems
> beyond the scope of aRFS.

I guess you're right, the vhost thread affinity is a factor if we're
trying to take the interrupt on the host CPU that will eventually
execute the vcpu.  It's beyond the scope of this effort but something
that would be nice to eventually solve.

Stefan
