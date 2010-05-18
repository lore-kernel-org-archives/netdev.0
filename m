From: Juan Quintela <quintela@redhat.com>
Subject: Re: [PATCHv2] virtio: put last seen used index into ring itself
Date: Tue, 18 May 2010 13:26:36 +0200
Message-ID: <m3632l5u37.fsf@trasno.mitica>
References: <20100518021315.GA22852@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271Ab0ERL07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 07:26:59 -0400
In-Reply-To: <20100518021315.GA22852@redhat.com> (Michael S. Tsirkin's message
	of "Tue, 18 May 2010 05:13:15 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote:
> Generally, the Host end of the virtio ring doesn't need to see where
> Guest is up to in consuming the ring.  However, to completely understand
> what's going on from the outside, this information must be exposed.
> For example, host can reduce the number of interrupts by detecting
> that the guest is currently handling previous buffers.
>
> Fortunately, we have room to expand: the ring is always a whole number
> of pages and there's hundreds of bytes of padding after the avail ring
> and the used ring, whatever the number of descriptors (which must be a
> power of 2).
>
> We add a feature bit so the guest can tell the host that it's writing
> out the current value there, if it wants to use that.
>
> This is based on a patch by Rusty Russell, with the main difference
> being that we dedicate a feature bit to guest to tell the host it is
> writing the used index.  This way we don't need to force host to publish
> the last available index until we have a use for it.
>
> Another difference is that while the feature helps virtio-net,
> there have been conflicting reports wrt virtio-blk.
> The reason is unknown, it could be due to the fact that
> virtio-blk does not bother to disable interrupts at all.
> So for now, this patch only acks this feature for -net.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

It looks good.

Later, Juan.
