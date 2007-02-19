From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 17:25:05 +0300
Message-ID: <20070219142504.GA5626@2ka.mipt.ru>
References: <20070204074143.26312.qmail@science.horizon.com> <200702191438.14010.dada1@cosmosbay.com> <20070219135608.GA10268@2ka.mipt.ru> <200702191514.02937.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53696 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbXBSO0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 09:26:08 -0500
Content-Disposition: inline
In-Reply-To: <200702191514.02937.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 03:14:02PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > Forget about cache misses and cache lines - we have a hash table, only
> > part of which is used (part for time-wait sockets, part for established
> > ones).
> 
> No you didnt not read my mail. Current ehash is not as decribed by you.

I did.
And I also said that my tests do not have timewait sockets at all - I
removed sk_for_each and so on, which should effectively increase lookup 
time twice on busy system with lots of created/removed sockets per
timeframe (that is theory from my side already).
Anyway, I ran the same test with increased table too.

> > Anyway, even with 2^20 (i.e. when the whole table is only used for
> > established sockets) search time is about 360-370 nsec on 3.7 GHz Core
> > Duo (only one CPU is used) with 2 GB of ram.
> 
> Your tests are user land, so unfortunatly are biased...
> 
> (Unless you use hugetlb data ?)

No I do not. But the same can be applied to trie test - it is also
performed in userspace and thus suffers from possible swapping/cache
flushing and so on.

And I doubt moving test into kernel will suddenly end up with 10 times 
increased rates.

Anyway, trie test (broken implementation) is two times slower than hash
table (resized already), and it does not include locking isses of the
hash table access and further scalability issues.

I think I need to fix my trie implementation to fully show its
potential, but original question was why tree/trie based implementation
is not considered at all although it promises better performance and
scalability.

-- 
	Evgeniy Polyakov
