From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 6 Aug 2006 17:36:55 +1000
Message-ID: <20060806073655.GA28735@gondor.apana.org.au>
References: <1154821010.5517.48.camel@jzny2> <20060806025123.GA27051@gondor.apana.org.au> <20060806071418.GB20432@edgar.underground.se.axis.com> <20060806.002644.26512828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edgar.iglesias@axis.com, hadi@cyberus.ca, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36114 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932543AbWHFHhW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 03:37:22 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060806.002644.26512828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 12:26:44AM -0700, David Miller wrote:
> 
> Increasingly I find that orphan'ing an SKB once it hits the real
> device for transmit is something to seriously consider.

Yes that certainly makes a lot of sense.

Actually, why do we charge the memory to the socket at all between
the packet leaving the TCP stack and it entering the device? Most
packets spend a tiny amount of time on this journey so it seems
silly to do atomic operations as they leave the stack only to undo
it when they enter the device.

The biggest reason packets spend a non-trivial amount of time on
this journey is traffic shaping.  In that case the memory is already
accounted to the device anyway (in terms of queue length) so it would
seem unfair to charge the socket as well.

So how about simply charging the socket for the retransmit queue
as we do now and skip the caharge for packets leaving the stack?

For UDP it's different since it doesn't have a retransmit queue.
However, I'm unsure how much of a positive effect the socket charge
actually has for UDP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
