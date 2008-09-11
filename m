From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Thu, 11 Sep 2008 12:10:10 +0000
Message-ID: <20080911121010.GB5765@ff.dom.local>
References: <20080821.005250.117238212.davem@davemloft.net> <20080911.033956.233317469.davem@davemloft.net> <20080911104531.GA21913@gondor.apana.org.au> <20080911.034955.111797743.davem@davemloft.net> <20080911110035.GA22065@gondor.apana.org.au> <20080911115132.GA5765@ff.dom.local> <20080911115449.GA22860@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:57703 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbYIKMKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 08:10:19 -0400
Received: by gxk9 with SMTP id 9so16136680gxk.13
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 05:10:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080911115449.GA22860@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 09:54:49PM +1000, Herbert Xu wrote:
> On Thu, Sep 11, 2008 at 11:51:32AM +0000, Jarek Poplawski wrote:
> > 
> > IMHO, the most reasonable test here is for all tx_queues of a qdisc
> > beeing stopped, but since this is quite heavy, probably we need an
> > additional qdisc flag for such an occasion.
> 
> Yes we could do that too.  Although the head-of-qdisc approach
> will eventually lead to the same result.  That is, as you pop
> things off the head eventually you'll hit a packet that belongs
> to the stopped queue and that'll then block the whole qdisc.
> 
> So I don't think there's anything inherently advantageous in
> checking all the queues.

Yes, but this is only because this current behaviour of blocking all
transmit by one stopped tx_queue is wrong (IMHO), and with sch_multiq
there should be a real advantage.

Cheers,
Jarek P.
