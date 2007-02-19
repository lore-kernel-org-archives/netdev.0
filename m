From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 15:14:02 +0100
Message-ID: <200702191514.02937.dada1@cosmosbay.com>
References: <20070204074143.26312.qmail@science.horizon.com> <200702191438.14010.dada1@cosmosbay.com> <20070219135608.GA10268@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, linux@horizon.com, davem@davemloft.net,
	netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:55222 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932273AbXBSOOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 09:14:12 -0500
In-Reply-To: <20070219135608.GA10268@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 19 February 2007 14:56, Evgeniy Polyakov wrote:
> On Mon, Feb 19, 2007 at 02:38:13PM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > On Monday 19 February 2007 12:41, Evgeniy Polyakov wrote:
> > > > 1 microsecond ? Are you kidding ? We want no more than 50 ns.
> > >
> > > Theory again.
> >
> > Theory is nice, but I personally prefer oprofile :)
> > I base my comments on real facts.
> > We *want* 50 ns tcp lookups (2 cache line misses, one with reader intent,
> > one for exclusive access intent)
>
> I said that your words are theory in previous mails :)
>
> Current code works 10 times worse than you expect.
>
> > > Existing table does not scale that good - I created (1<<20)/2 (to cover
> > > only established part) entries table and filled it with 1 million of
> > > random entries -search time is about half of microsecod.
> >
> > I use exactly 1^20 slots, not 1^19 (see commit
> > dbca9b2750e3b1ee6f56a616160ccfc12e8b161f , where I changed layout of
> > ehash table so that two chains (established/timewait) are on the same
> > cache line. every cache miss *counts*)
>
> Forget about cache misses and cache lines - we have a hash table, only
> part of which is used (part for time-wait sockets, part for established
> ones).

No you didnt not read my mail. Current ehash is not as decribed by you.

>
> Anyway, even with 2^20 (i.e. when the whole table is only used for
> established sockets) search time is about 360-370 nsec on 3.7 GHz Core
> Duo (only one CPU is used) with 2 GB of ram.

Your tests are user land, so unfortunatly are biased...

(Unless you use hugetlb data ?)

