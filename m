From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 12:47:34 +0000
Message-ID: <20090729124734.GD5490@ff.dom.local>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local> <20090729111134.GA6478@gondor.apana.org.au> <20090729112614.GB5490@ff.dom.local> <20090729123041.GA7440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:46992 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbZG2Mrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 08:47:41 -0400
Received: by fxm18 with SMTP id 18so363706fxm.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 05:47:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090729123041.GA7440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 08:30:41PM +0800, Herbert Xu wrote:
> On Wed, Jul 29, 2009 at 11:26:14AM +0000, Jarek Poplawski wrote:
> >
> > If you mean the tx lock there should be no "real" contention: only
> > one waiter max. qdisc lock's contention might be higher, but it's
> > use (during contention) better: enqueue + dequeue together instead
> > of doing it separately.
> 
> Hmm, you will have contention if they're both transmitting a
> single flow which must always go into a single physical queue.
> 
> So you'll have two CPUs doing the work of a single CPU, with one
> of them always spinning on the TX lock.

Hmm.. I'd call it a little waiting, but OK let's call it contention;-)
When tx is faster than queue operations there could be no contention
at all. I'm not saying I must be right: IMHO it's only worth trying.

Cheers,
Jarek P.
