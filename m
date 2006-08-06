From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 10:06:59 +0200
Message-ID: <20060806080659.GA22168@edgar.underground.se.axis.com>
References: <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <20060806071418.GB20432@edgar.underground.se.axis.com> <20060806.002644.26512828.davem@davemloft.net> <20060806073655.GA28735@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, edgar.iglesias@axis.com,
	hadi@cyberus.ca, shemminger@osdl.org, mchan@broadcom.com,
	jesse.brandeburg@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:47263 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP id S932421AbWHFIHC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 04:07:02 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k7686xP0027497
	for <netdev@vger.kernel.org>; Sun, 6 Aug 2006 10:06:59 +0200
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060806073655.GA28735@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 05:36:55PM +1000, Herbert Xu wrote:
> On Sun, Aug 06, 2006 at 12:26:44AM -0700, David Miller wrote:
> > 
> > Increasingly I find that orphan'ing an SKB once it hits the real
> > device for transmit is something to seriously consider.
> 
> Yes that certainly makes a lot of sense.
> 
> Actually, why do we charge the memory to the socket at all between
> the packet leaving the TCP stack and it entering the device? Most
> packets spend a tiny amount of time on this journey so it seems
> silly to do atomic operations as they leave the stack only to undo
> it when they enter the device.
> 
> The biggest reason packets spend a non-trivial amount of time on
> this journey is traffic shaping.  In that case the memory is already
> accounted to the device anyway (in terms of queue length) so it would
> seem unfair to charge the socket as well.
> 
> So how about simply charging the socket for the retransmit queue
> as we do now and skip the caharge for packets leaving the stack?
> 
> For UDP it's different since it doesn't have a retransmit queue.
> However, I'm unsure how much of a positive effect the socket charge
> actually has for UDP.

It makes sense, but I see a problem with this. It will remove some of the
control applications have on how much of their data gets queued on local
queues. Small SNDBUF's are sometimes used to somewhat avoid/control latency.

For now, I think it's better to orphan the skb when it hits a real device for
transmit, as David mentioned.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
