From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 21:54:49 +1000
Message-ID: <20080911115449.GA22860@gondor.apana.org.au>
References: <20080821.005250.117238212.davem@davemloft.net> <20080911.033956.233317469.davem@davemloft.net> <20080911104531.GA21913@gondor.apana.org.au> <20080911.034955.111797743.davem@davemloft.net> <20080911110035.GA22065@gondor.apana.org.au> <20080911115132.GA5765@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45734 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752210AbYIKLyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 07:54:55 -0400
Content-Disposition: inline
In-Reply-To: <20080911115132.GA5765@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 11:51:32AM +0000, Jarek Poplawski wrote:
> 
> IMHO, the most reasonable test here is for all tx_queues of a qdisc
> beeing stopped, but since this is quite heavy, probably we need an
> additional qdisc flag for such an occasion.

Yes we could do that too.  Although the head-of-qdisc approach
will eventually lead to the same result.  That is, as you pop
things off the head eventually you'll hit a packet that belongs
to the stopped queue and that'll then block the whole qdisc.

So I don't think there's anything inherently advantageous in
checking all the queues.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
