From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 10:44:58 +0000
Message-ID: <20080827104457.GA7258@ff.dom.local>
References: <E1KXy78-0000mY-00@gondolin.me.apana.org.au> <20080827.022633.132959334.davem@davemloft.net> <20080827095549.GA12583@gondor.apana.org.au> <20080827.025747.197547570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:2041 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbYH0KpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 06:45:04 -0400
Received: by ey-out-2122.google.com with SMTP id 6so471405eyi.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 03:45:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080827.025747.197547570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 02:57:47AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 27 Aug 2008 19:55:49 +1000
> 
> > What I mean is a pointer like sch->root_qdisc, and we would provide
> > that to qdisc_create as a parameter in place of dev_queue (and
> > NULL for root qdiscs themselves).  So as long as we assign it at
> > the top of this function it would be available here too.
> 
> Ok, that makes sense.

Yes, it should be simpler. (We can probably consider a pointer to
itself instead of NULL for root qdiscs, to skip testing for NULL e.g.
while getting a lock.) On the other hand, we lose with this the
possibility to easily determine which dev_queue is "the owner" of the
qdisc, or if some dev_queue contains a clone only.

Jarek P.
