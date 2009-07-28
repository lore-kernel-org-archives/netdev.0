From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 15:12:47 +0800
Message-ID: <20090728071247.GA25611@gondor.apana.org.au>
References: <20090725032436.GA30741@gondor.apana.org.au> <20090727.192844.163233275.davem@davemloft.net> <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41658 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753299AbZG1HM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 03:12:58 -0400
Content-Disposition: inline
In-Reply-To: <20090727.212107.161491585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2009 at 09:21:07PM -0700, David Miller wrote:
>
> Good point, but this only suggests that we might want to undo that
> queue runner exclusivity state bit for this case especially when we
> know that we are feeding a multiqueue device.

I'm not convinced that would generate a postivie outcome.  If
you remove the exclusivity and go back to taking two locks in
turns (the qdisc lock or the xmit lock) then the only case where
you might win is if multiple CPUs perform qdisc_run at the same
time.

However, in that case you'll now have two locks bouncing around
instead of one and my guess would be that the cache overhead
would offset any gain that is made from the parallel processing.

But I think the fundamental question is should we treat the scenario
where each CPU is transmitting to its own TX queue as the ideal
and optimise for that over the case where the CPUs are transmitting
more or less randomly into the queues.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
