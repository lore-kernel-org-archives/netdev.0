From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 21:26:41 +0200
Message-ID: <20090729192641.GA3058@ami.dom.local>
References: <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local> <20090729111134.GA6478@gondor.apana.org.au> <20090729112614.GB5490@ff.dom.local> <20090729123041.GA7440@gondor.apana.org.au> <20090729124734.GD5490@ff.dom.local> <OF414D73BF.FAE11563-ON65257602.0047D9A4-65257602.00483330@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:37307 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbZG2T1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 15:27:14 -0400
Received: by fxm28 with SMTP id 28so187939fxm.17
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 12:27:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OF414D73BF.FAE11563-ON65257602.0047D9A4-65257602.00483330@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 06:38:36PM +0530, Krishna Kumar2 wrote:
> Hi Jarek,
> 
> Jarek Poplawski <jarkao2@gmail.com> wrote on 07/29/2009 06:17:34 PM:
> 
> > Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
> >
> > On Wed, Jul 29, 2009 at 08:30:41PM +0800, Herbert Xu wrote:
> > > On Wed, Jul 29, 2009 at 11:26:14AM +0000, Jarek Poplawski wrote:
> > > >
> > > > If you mean the tx lock there should be no "real" contention: only
> > > > one waiter max. qdisc lock's contention might be higher, but it's
> > > > use (during contention) better: enqueue + dequeue together instead
> > > > of doing it separately.
> > >
> > > Hmm, you will have contention if they're both transmitting a
> > > single flow which must always go into a single physical queue.
> > >
> > > So you'll have two CPUs doing the work of a single CPU, with one
> > > of them always spinning on the TX lock.
> >
> > Hmm.. I'd call it a little waiting, but OK let's call it contention;-)
> > When tx is faster than queue operations there could be no contention
> > at all. I'm not saying I must be right: IMHO it's only worth trying.
> 
> My expectation is that tx would be much longer than a few lines of
> queue operation....

I meant here the case of non-default qdisc, like HTB, HFSC or CBQ,
often with many classes and filters, so a few more lines than usual...

Thanks,
Jarek P.
