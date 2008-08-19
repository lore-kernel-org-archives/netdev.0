From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 17:11:24 -0700 (PDT)
Message-ID: <20080818.171124.192743795.davem@davemloft.net>
References: <20080818201236.GA3366@ami.dom.local>
	<20080818.165411.255925269.davem@davemloft.net>
	<20080819000551.GA26699@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48100
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753728AbYHSALY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 20:11:24 -0400
In-Reply-To: <20080819000551.GA26699@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 19 Aug 2008 10:05:51 +1000

> On Mon, Aug 18, 2008 at 04:54:11PM -0700, David Miller wrote:
> > 
> > Yep, and that's the lock debugging thing which is triggering now.
> > Likely what I'll do is simply reinstate RCU but only for the freeing
> > of the memory, nothing more.
> > 
> > This keeps everything doing destruction under RTNL as desired,
> > yet fixes the "we're holding lock that's being freed" problem.
> 
> Is this the problem with dev_shutdown freeing the qdisc while
> holding its lock?
> 
> Couldn't we just drop the lock before calling qdisc_destroy?
> 
> dev_shutdown can only be called after dev_deactivate, as such
> all qdisc users should have disappeared by now (and if they
> haven't, our waiting loop in dev_deactivate didn't work and
> we should fix that).

Yep, that's another possible approach.

Especially since we've bullet-proof'd dev_deactivate(), there
should be absolutely no more references to the qdisc any
longer.

I'll look into doing it this way, thanks.
