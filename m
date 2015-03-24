From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [v1 PATCH 9/10] rhashtable: Allow GFP_ATOMIC bucket table
 allocation
Date: Mon, 23 Mar 2015 21:24:11 -0700
Message-ID: <1427171051.25985.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150322075300.GA2441@gondor.apana.org.au>
	 <E1YZahk-0000jW-Ry@gondolin.me.apana.org.au>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB077F0@AcuExch.aculab.com>
	 <20150324030913.GA8184@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37018 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbCXEYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 00:24:14 -0400
Received: by igcqo1 with SMTP id qo1so57264912igc.0
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 21:24:13 -0700 (PDT)
In-Reply-To: <20150324030913.GA8184@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-24 at 14:09 +1100, Herbert Xu wrote:
> On Mon, Mar 23, 2015 at 12:53:11PM +0000, David Laight wrote:
> >
> > Given the lock is only used for insert and delete, I'm also not at
> > all clear why you allocate 128 locks per cpu for very large tables.
> > With the locks in their own array I don't think there can be 'false
> > sharing', the worst than can happen is two cpus spinning on locks
> > in the same cache line.
> 
> Personally I'm totally against Bucket locks.  If you have a
> scalability problem you really need to solve them at a higher
> level, e.g., multiqueue transmission in networking.  Bucket
> locks are simply kicking the can down the road, it'll come back
> to bite you sooner or later in terms of scalability.


Well, keep in mind a lock can be very big with LOCKDEP.

One lock per bucket is totally overkill.

A hash array of locks is a good compromise.

128 locks per cpu is also a good compromise, because one cache line can
hold 16 locks.

Number of locks has nothing to do with number of buckets,
unless you have unlimited memory and can afford one lock per bucket,
and don't care of memory thrashing when dumping whole hash table.

I thought this kind of solution was well understood among network
developers.
