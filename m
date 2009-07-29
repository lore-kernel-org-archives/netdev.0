From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 20:30:41 +0800
Message-ID: <20090729123041.GA7440@gondor.apana.org.au>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local> <20090729111134.GA6478@gondor.apana.org.au> <20090729112614.GB5490@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58200 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754445AbZG2Mat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 08:30:49 -0400
Content-Disposition: inline
In-Reply-To: <20090729112614.GB5490@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 11:26:14AM +0000, Jarek Poplawski wrote:
>
> If you mean the tx lock there should be no "real" contention: only
> one waiter max. qdisc lock's contention might be higher, but it's
> use (during contention) better: enqueue + dequeue together instead
> of doing it separately.

Hmm, you will have contention if they're both transmitting a
single flow which must always go into a single physical queue.

So you'll have two CPUs doing the work of a single CPU, with one
of them always spinning on the TX lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
