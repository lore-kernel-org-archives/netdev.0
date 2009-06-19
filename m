From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Fri, 19 Jun 2009 23:20:44 +0930
Message-ID: <200906192320.44904.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38048 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbZFSNuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2009 09:50:44 -0400
In-Reply-To: <20090619043613.GA15163@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Jun 2009 02:06:13 pm Herbert Xu wrote:
> On Fri, Jun 19, 2009 at 01:07:19PM +0930, Rusty Russell wrote:
> > You didn't comment on my patch which tried to fix NETDEV_TX_BUSY tho?
> However, that is still wrong for many packet schedulers.  For
> example, if the requeued packet is of a lower priority, and a
> higher priority packet comes along, we want the higher priority
> packet to preempt the requeued packet.  Right now it just doesn't
> happen.
>
> This is not as trivial as it seems because on a busy host this can
> happen many times a second.  With TX_BUSY the QoS guarantees are
> simply not workable.

Your use of the word guarantee here indicates an idealized concept of QoS 
which cannot exist on any NIC which has a queue.  We should try to approach 
the ideal, but understand we cannot reach it.

AFAICT, having a non-resortable head entry in the queue is exactly like having 
one-packet slightly longer queue on the NIC.  A little further from the ideal, 
but actually *less* damaging to QoS idea unless it happens on every second 
packet.

On the other hand, we're underutilizing the queue to avoid it.  I find that a 
little embarrassing.

> > We provided an API, people used it.  Constantly trying to disclaim our
> > responsibility for the resulting mess makes me fucking ANGRY.
>
> Where have I disclaimed responsibility? If we were doing that
> then we wouldn't be having this discussion.

"Anyway, I don't think we should reshape our APIs based on how
broken the existing users are."

Perhaps I was reading too much into it, but the implication that we should 
blame the driver authors for writing their drivers in what I consider to be 
the most straightforward and efficient way.

I feel we're being horribly deceptive by giving them a nice API, and upon 
review, telling them "don't use that".  And it's been ongoing for far too 
long.

> In fact queueing it in the driver is just as bad as return TX_BUSY!

Agreed (modulo the tcpdump issue).  And worse, because it's ugly and complex!

Thanks,
Rusty.
