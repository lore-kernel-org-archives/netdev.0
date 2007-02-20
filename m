From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 20:17:31 +0100
Message-ID: <200702202017.31965.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201955.15567.dada1@cosmosbay.com> <20070220190634.GA12193@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:45862 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbXBTTRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:17:41 -0500
In-Reply-To: <20070220190634.GA12193@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 20:06, Evgeniy Polyakov wrote:

> > I added to my 'simulator_plugged_on_real_server' the average cost
> > calculation, relative to number of cache line per lookup.
> >
> > ehash_size=2^20
> > xor hash :
> > 386290 sockets, Avg lookup cost=3.2604 cache lines/lookup
> > 393667 sockets, Avg lookup cost=3.30579 cache lines/lookup
> > 400777 sockets, Avg lookup cost=3.3493 cache lines/lookup
> > 404720 sockets, Avg lookup cost=3.36705 cache lines/lookup
> > 406671 sockets, Avg lookup cost=3.37677 cache lines/lookup
> > jenkin hash:
> > 386290 sockets, Avg lookup cost=2.36763 cache lines/lookup
> > 393667 sockets, Avg lookup cost=2.37533 cache lines/lookup
> > 400777 sockets, Avg lookup cost=2.38211 cache lines/lookup
> > 404720 sockets, Avg lookup cost=2.38582 cache lines/lookup
> > 406671 sockets, Avg lookup cost=2.38679 cache lines/lookup
> >
> > (you can see that when number of sockets increase, the xor hash becomes
> > worst)
> >
> > So the jenkin hash function CPU cost is balanced by the fact its
> > distribution is better. In the end you are faster.
>
> Very strange test - it shows that jenkins distribution for your setup is
> better than xor one, although for the true random data they are roughly
> the same, and jenkins one has more instructions.
>
> But _you_ have shown that with true random data of 2^16 ports jenkins
> distribution is _worse_ than xor without any gain to buy.

I shown your test was bogus. All your claims are just bogus.
I claim your 'true random data' is a joke. rand() in your program is a pure 
joke.

Given 48 bits of input, you *can* find a lot of addr/port to hit one 
particular cache line if XOR function is used. With jhash, without knowing 
the 32bits random secret, you *cant*.

Again, you dont take into account the chain length.

If all chains were of length <= 1, then yes, xor would be faster. In real 
life, we *know* chain length can be larger, especially in DOS situations.

