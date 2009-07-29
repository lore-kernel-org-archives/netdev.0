From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 11:26:14 +0000
Message-ID: <20090729112614.GB5490@ff.dom.local>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local> <20090729111134.GA6478@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:52118 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbZG2L0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 07:26:19 -0400
Received: by fxm18 with SMTP id 18so319798fxm.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 04:26:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090729111134.GA6478@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 07:11:34PM +0800, Herbert Xu wrote:
> On Wed, Jul 29, 2009 at 11:04:36AM +0000, Jarek Poplawski wrote:
> >
> > How about this: instead of the _RUNNING flag we take tx lock while
> > holding qdisc lock and release qdisc lock just after (before xmit).
> > This should prevent reordering, and probably could improve cache use:
> > CPU B which takes qdisc lock only for enqueuing now, would use it for
> > dequeuing too, plus if accidentally the next xmit goes to a different
> > tx queue, it could start before CPU A finishes. Otherwise it would
> > simply wait for CPU A (without tx lock contention). Of course it
> > needs testing... 
> 
> Well reordering isn't the only problem, the lock contention brought
> upon by two CPUs both trying to transmit the same flow from the
> qdisc is just as bad.

If you mean the tx lock there should be no "real" contention: only
one waiter max. qdisc lock's contention might be higher, but it's
use (during contention) better: enqueue + dequeue together instead
of doing it separately.

Cheers,
Jarek P.
