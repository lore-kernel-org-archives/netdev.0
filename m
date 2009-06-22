From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an extra skb.
Date: Mon, 22 Jun 2009 12:09:15 +0930
Message-ID: <200906221209.16481.rusty@rustcorp.com.au>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906192320.44904.rusty@rustcorp.com.au> <20090619141014.GA19828@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35136 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbZFVCjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 22:39:18 -0400
In-Reply-To: <20090619141014.GA19828@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Jun 2009 11:40:14 pm Herbert Xu wrote:
> > On the other hand, we're underutilizing the queue to avoid it.  I find
> > that a little embarrassing.
>
> Here's why I think this is not an issue.  If your NIC is high
> bandwidth then your ring is going to have to be huge so the
> amount that is underutilised (a 64K packet) is tiny.  If your
> NIC is low bandwidth then this is where you often need QoS and
> in that case you do *NOT* want to fully utilise the HW queue.

Well, we leave that up to the NIC designer.  It's retro-justification for 
throwing away a few percent of the queue, but the QoS issue is even more in 
the noise.

But I will give in now and change virtio_net to use this substandard API :(

Thanks,
Rusty.
