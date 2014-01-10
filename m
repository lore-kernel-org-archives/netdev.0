From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2 2/5] tcp: metrics: Add source-address to tcp-metrics
Date: Sat, 11 Jan 2014 00:10:59 +0100
Message-ID: <20140110231059.GA30388@order.stressinduktion.org>
References: <1389203751.26646.100.camel@edumazet-glaptop2.roam.corp.google.com> <20140108224344.GE4700@cpaasch-mac> <1389222826.31367.28.camel@edumazet-glaptop2.roam.corp.google.com> <20140110.173711.1541969326146414340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, ycheng@google.com, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55440 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaAJXLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:11:02 -0500
Content-Disposition: inline
In-Reply-To: <20140110.173711.1541969326146414340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 05:37:11PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 08 Jan 2014 15:13:46 -0800
> 
> > On Wed, 2014-01-08 at 23:43 +0100, Christoph Paasch wrote:
> >> Hello Eric,
> >> 
> >> On 08/01/14 - 09:55:51, Eric Dumazet wrote:
> >> > On Wed, 2014-01-08 at 16:05 +0100, Christoph Paasch wrote:
> >> > > We add the source-address to the tcp-metrics, so that different metrics
> >> > > will be used per source/destination-pair. We use the destination-hash to
> >> > > store the metric inside the hash-table. That way, deleting and dumping
> >> > > via "ip tcp_metrics" is easy.
> >> > 
> >> > Note that this has the following problem :
> >> > 
> >> > Some applications use a set of source IP addresses to overcome the 64K
> >> > port limitation.
> >> 
> >> Ok, did not know about that.
> >> 
> >> > tcp_metrics uses a hard-coded TCP_METRICS_RECLAIM_DEPTH value of 5,
> >> > meaning that cache wont be able to store more than 5 source IP addresses
> >> > (reaching one particular remote IP).
> >> 
> >> Maybe we could do something like the below (yet untested). That way we allow
> >> up to 32 entries with the same destination but different source and still
> >> only 5 with different destinations.
> >> 
> >> I guess 32 * 64K connections is enough. :)
> >> We could also make TCP_METRICS_RECLAIM_DEPTH(_DST) a tunable.
> > 
> > Well, not sure if this is a problem anyway, and if we want extra
> > complexity for this rare use case, considering tcp metrics for
> > high number of flows sharing a common path is unlikely to be useful
> > (with exception of Fast Open, but again it must be rare)
> 
> I think we are overthinking this, even for the aforementioned case.
> 
> If people report that this is a real problem they are hitting, and
> not just with constructed test cases, we can work on a solution.

I was thinking if this would be a problem then one could switch to not
use the source address but something like the interface group index as
the additional match. Seems to fit into the weak end host model.

Greetings,

  Hannes
