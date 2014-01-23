From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH net-next 0/3] virtio_net: add aRFS support
Date: Thu, 23 Jan 2014 16:26:09 +0200
Message-ID: <20140123142609.GD21572@redhat.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
 <52D75EA5.1050000@redhat.com>
 <CAEH94Lg8aL2UcrdgSW6ahtiSYTE0=z1o8Q0hHf0t9RpPVvGiDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932095AbaAWOVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 09:21:31 -0500
Content-Disposition: inline
In-Reply-To: <CAEH94Lg8aL2UcrdgSW6ahtiSYTE0=z1o8Q0hHf0t9RpPVvGiDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 04:48:43PM +0800, Zhi Yong Wu wrote:
> On Thu, Jan 16, 2014 at 12:23 PM, Jason Wang <jasowang@redhat.com> wrote:
> > On 01/15/2014 10:20 PM, Zhi Yong Wu wrote:
> >>
> >> From: Zhi Yong Wu<wuzhy@linux.vnet.ibm.com>
> >>
> >> HI, folks
> >>
> >> The patchset is trying to integrate aRFS support to virtio_net. In this
> >> case,
> >> aRFS will be used to select the RX queue. To make sure that it's going
> >> ahead
> >> in the correct direction, although it is still one RFC and isn't tested,
> >> it's
> >> post out ASAP. Any comment are appreciated, thanks.
> >>
> >> If anyone is interested in playing with it, you can get this patchset from
> >> my
> >> dev git on github:
> >>    git://github.com/wuzhy/kernel.git virtnet_rfs
> >>
> >> Zhi Yong Wu (3):
> >>    virtio_pci: Introduce one new config api vp_get_vq_irq()
> >>    virtio_net: Introduce one dummy function virtnet_filter_rfs()
> >>    virtio-net: Add accelerated RFS support
> >>
> >>   drivers/net/virtio_net.c      |   67
> >> ++++++++++++++++++++++++++++++++++++++++-
> >>   drivers/virtio/virtio_pci.c   |   11 +++++++
> >>   include/linux/virtio_config.h |   12 +++++++
> >>   3 files changed, 89 insertions(+), 1 deletions(-)
> >>
> >
> > Please run get_maintainter.pl before sending the patch. You'd better at
> > least cc virtio maintainer/list for this.
> Is this one must for virtio stuff?

See Documentation/SubmittingPatches

> >
> > The core aRFS method is a noop in this RFC which make this series no much
> > sense to discuss. You should at least mention the big picture here in the
> > cover letter. I suggest you should post a RFC which can run and has expected
> > result or you can just raise a thread for the design discussion.
> Yes, it currently miss some important stuff as i said in another mail
> of this series.
> 
> >
> > And this method has been discussed before, you can search "[net-next RFC
> > PATCH 5/5] virtio-net: flow director support" in netdev archive for a very
> > old prototype implemented by me. It can work and looks like most of this RFC
> > have already done there.
> ah? Can you let me know the result of your discussion? Will checked
> it, thanks for your pointer.
> >
> > A basic question is whether or not we need this, not all the mq cards use
> > aRFS (see ixgbe ATR). And whether or not it can bring extra overheads? For
> > virtio, we want to reduce the vmexits as much as possible but this aRFS
> Good question, i also have concern about this, and don't know if Tom
> has good explanation.
> > seems introduce a lot of more of this. Making a complex interfaces just for
> > an virtual device may not be good, simple method may works for most of the
> > cases.
> >
> > We really should consider to offload this to real nic. VMDq and L2
> > forwarding offload may help in this case.
> 
> By the way, Stefan, can you let us know your concerns here? as we
> talked in irc channel. :)
> 
> 
> -- 
> Regards,
> 
> Zhi Yong Wu
