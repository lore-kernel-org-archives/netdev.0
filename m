From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/4] virtio_net: don't free buffers in xmit ring
Date: Tue, 2 Jun 2009 23:13:52 +0930
Message-ID: <200906022313.52808.rusty@rustcorp.com.au>
References: <200905292346.24141.rusty@rustcorp.com.au> <1243930422.9146.60.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53681 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbZFBNn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 09:43:56 -0400
In-Reply-To: <1243930422.9146.60.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Jun 2009 05:43:42 pm Mark McLoughlin wrote:
> On Fri, 2009-05-29 at 23:46 +0930, Rusty Russell wrote:
> > The virtio_net driver is complicated by the two methods of freeing old
> > xmit buffers (in addition to freeing old ones at the start of the xmit
> > path).
> >
> > The original code used a 1/10 second timer attached to xmit_free(),
> > reset on every xmit.  Before we orphaned skbs on xmit, the
> > transmitting userspace could block with a full socket until the timer
> > fired, the skb destructor was called, and they were re-woken.
>
> The timer was actually added to solve a hang when trying to unload
> nf_conntrack AFAIR - nf_conntrack was blocking on the skb being freed
> and we never actually freed it.
>
> I think skb_orphan() is enough to prevent this, is it?

Yep.

> > Unfortunately, VIRTIO_F_NOTIFY_ON_EMPTY makes quite a lot of work: a
> > host which is faster than the guest will fire the interrupt every xmit
> > packet (slowing the guest down further).
>
> Ouch. So, does simply disabling host support for
> VIRTIO_F_NOTIFY_ON_EMPTY speed up current guests?

That was my original change.  It cuts the interrupts, but there's enough else 
going on that there's not a reliably-measurable speedup (this is with lguest, 
haven't tested with kvm).

Cheers,
Rusty.
