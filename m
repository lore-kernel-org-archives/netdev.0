From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 05:18:41 -0700 (PDT)
Message-ID: <20080822.051841.259820995.davem@davemloft.net>
References: <20080822.044248.175133807.davem@davemloft.net>
	<20080822120918.GB14981@ff.dom.local>
	<20080822121144.GA32397@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754052AbYHVMSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 08:18:42 -0400
In-Reply-To: <20080822121144.GA32397@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Aug 2008 22:11:44 +1000

> On Fri, Aug 22, 2008 at 12:09:18PM +0000, Jarek Poplawski wrote:
> >
> > I guess, we need to establish first how much it's needed on fast
> > paths. But anyway, it seems something like qdisc_match_from_root()
> > should be enough in this qdisc_tree_decrease_qlen().
> 
> Or we could just replace requeue with a peek interface.

Yes, and as per discussions over the past week or so, that would
allow us to eliminate basically everything except the netem usage.

Netem is trying to create packet reordering by requeueing (which is
logically like a head insert) instead of enqueueing (which is
logically like a tail insert).
