From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv7] add mergeable buffers support to vhost_net
Date: Mon, 3 May 2010 18:56:14 +0300
Message-ID: <20100503155613.GB12449@redhat.com>
References: <20100503103410.GA11113@redhat.com> <OF639FB51C.80B669F0-ON88257718.0054F654-88257718.0055FB45@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.osdl.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752973Ab0ECQBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 12:01:00 -0400
Content-Disposition: inline
In-Reply-To: <OF639FB51C.80B669F0-ON88257718.0054F654-88257718.0055FB45@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 03, 2010 at 08:39:08AM -0700, David Stevens wrote:
> "Michael S. Tsirkin" <mst@redhat.com> wrote on 05/03/2010 03:34:11 AM:
> 
> > On Wed, Apr 28, 2010 at 01:57:12PM -0700, David L Stevens wrote:
> > > This patch adds mergeable receive buffer support to vhost_net.
> > > 
> > > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> > 
> > I've been doing some more testing before sending out a pull
> > request, and I see a drastic performance degradation in guest to host
> > traffic when this is applied but mergeable buffers are not in used
> > by userspace (existing qemu-kvm userspace).
> 
>         Actually, I wouldn't expect it to work at all;
> the qemu-kvm
> patch (particularly the feature bit setting bug fix) is required.

Which bugfix is that?

> Without it, I think the existing code will tell the guest to use
> mergeable buffers while turning it off in vhost.

It should not do that, specifically
vhost_net_get_features does:
	features &= ~(1 << VIRTIO_NET_F_MRG_RXBUF);
unconditionally. This was added with:
5751995a20e77cd9d61d00f7390401895fa172a6

I forced mergeable buffers off with -global virtio-net-pci.mrg_rxbuf=off
and it did not seem to help either.

> That was completely
> non-functional for me -- what version of qemu-kvm are you using?

992cc816c433332f2e93db033919a9ddbfcd1da4 or later should work well
AFAIK.

>         What I did to test w/o mergeable buffers is turn off the
> bit in VHOST_FEATURES.

It should be enough to force mergeable buffers to off by qemu command
line: -global virtio-net-pci.mrg_rxbuf=off 

> I'll recheck these, but qemu-kvm definitely
> must be updated; the original doesn't correctly handle feature bits.
> 
>                                                                 +-DLS

Hmm, I don't see the bug.

-- 
MST
