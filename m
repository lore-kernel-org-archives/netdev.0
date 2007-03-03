From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Sat, 3 Mar 2007 13:46:21 +0300
Message-ID: <20070303104620.GD22557@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <20070217131302.GA22732@2ka.mipt.ru> <20070302085246.GA30951@2ka.mipt.ru> <200703021056.24100.dada1@cosmosbay.com> <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43289 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbXCCKw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 05:52:56 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 02, 2007 at 12:45:36PM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> On 3/2/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> >Thank you for this report. (Still avoiding cache misses studies, while they
> >obviously are the limiting factor)
> 
> 1)  The entire point of going to a tree-like structure would be to
> allow the leaves to age out of cache (or even forcibly evict them)
> when the structure bloats (generally under DDoS attack), on the theory
> that most of them are bogus and won't be referenced again.  It's not
> about the speed of the data structure -- it's about managing its
> impact on the rest of the system.
> 
> 2)  The other entire point of going to a tree-like structure is that
> they're drastically simpler to RCU than hashes, and more generally
> they don't involve individual atomic operations (RCU reaping passes,
> resizing, etc.) that cause big latency hiccups and evict a bunch of
> other stuff from cache.
> 
> 3)  The third entire point of going to a tree-like structure is to
> have a richer set of efficient operations, since you can give them a
> second "priority"-type index and have "pluck-highest-priority-item",
> three-sided search, and bulk delete operations.  These aren't that
> much harder to RCU than the basic modify-existing-node operation.
> 
> Now can we give these idiotic micro-benchmarks a rest until Robert's
> implementation is tuned and ready for stress-testing?

Mmm, you have learnt new words from other threads :)
It is not a benchmark, it is analysis of the structure processing.
All you have written above is correct, since it was said in this thread
multiple times, but it does not change the fact, that tree traversal is
slower than list one, so to compete tree (or another algo, which would 
be even more interesting) implementation must have that in mind and be 
faster in any (the most) load. As is tree/trie does not have it (it is
feature of algorithm), but has another advantages (extremely suitable in
routing cache whihc requires wildcard support and scaling) you did not
mention - ability to scale without structure recreations.

Btw, you could try to implement something you have written above to show
its merits, so that it would not be an empty words :)

> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
