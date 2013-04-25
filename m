From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Thu, 25 Apr 2013 16:06:19 +0200
Message-ID: <1366898779.26911.609.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
	 <1366855546.8964.125.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758208Ab3DYOGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 10:06:24 -0400
In-Reply-To: <1366855546.8964.125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 19:05 -0700, Eric Dumazet wrote:
> By the way, the frag_evictor() idea of cleaning 20% or 30% of the
> frags simply doesn't scale to thousands of fragments.

Yes I know, that's why I changed the mem limit in this patch to "only"
clean 128K (one max frag mem acct size).

> It adds huge latencies in softirq context.

Yes, it sucks.  This is one thing I would really like to get rid of.
Does the "direct-hash-cleaning" solve this?


> If we really want to evict old fragments before expiration timer, then
> we can introduce a garbage collector in a work queue, and remove the
> need of a timer per fragment. 

I like this idea (just don't know how to implement it).  As my perf
results with "direct-hash-cleaning", show that we can hit a very
unfortunate situation, where the add/remove timer spinlock gets
hot/congested.

--Jesper
