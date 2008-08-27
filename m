From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 11:22:45 +0000
Message-ID: <20080827112245.GC7258@ff.dom.local>
References: <20080827104457.GA7258@ff.dom.local> <20080827.034723.73512507.davem@davemloft.net> <20080827110938.GB7258@ff.dom.local> <20080827.041511.189138671.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:12209 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbYH0LWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 07:22:50 -0400
Received: by ey-out-2122.google.com with SMTP id 6so476026eyi.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 04:22:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080827.041511.189138671.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 04:15:11AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Aug 2008 11:09:39 +0000
> 
> > On Wed, Aug 27, 2008 at 03:47:23AM -0700, David Miller wrote:
> > > From: Jarek Poplawski <jarkao2@gmail.com>
> > > Date: Wed, 27 Aug 2008 10:44:58 +0000
> > > 
> > > > Yes, it should be simpler. (We can probably consider a pointer to
> > > > itself instead of NULL for root qdiscs, to skip testing for NULL e.g.
> > > > while getting a lock.) On the other hand, we lose with this the
> > > > possibility to easily determine which dev_queue is "the owner" of the
> > > > qdisc, or if some dev_queue contains a clone only.
> > > 
> > > For root qdiscs we can add a TCQ_F_SHARED flag for this purpose.
> > 
> > Yes, but we can't do something like this:
> 
> Good point.
> 
> We could go back to using a device scope list.  The only piece to
> solve at that point is how to differentiate the different entries in
> the non-shared multiq case.
> 
> What it comes down to is semantics, and how we might want to handle
> multiq non-shared cases in future uses.
> 
> Maybe some day we'll allow real complicated configurations, such as
> mixes of shared and non-shared qdiscs on the TX queues.
> 
> So we'd need to think about how that would look, implementation wise.

On the other hand, we could save this functionality with another flag
e.g.:__QDISC_STATE_CLONED for all dev_queues, except "the owner"?

Jarek P.
