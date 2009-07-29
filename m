From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 19:11:34 +0800
Message-ID: <20090729111134.GA6478@gondor.apana.org.au>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59988 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754030AbZG2LLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 07:11:41 -0400
Content-Disposition: inline
In-Reply-To: <20090729110436.GA5490@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 11:04:36AM +0000, Jarek Poplawski wrote:
>
> How about this: instead of the _RUNNING flag we take tx lock while
> holding qdisc lock and release qdisc lock just after (before xmit).
> This should prevent reordering, and probably could improve cache use:
> CPU B which takes qdisc lock only for enqueuing now, would use it for
> dequeuing too, plus if accidentally the next xmit goes to a different
> tx queue, it could start before CPU A finishes. Otherwise it would
> simply wait for CPU A (without tx lock contention). Of course it
> needs testing... 

Well reordering isn't the only problem, the lock contention brought
upon by two CPUs both trying to transmit the same flow from the
qdisc is just as bad.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
