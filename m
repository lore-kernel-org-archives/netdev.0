From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 19:20:41 +0300
Message-ID: <20070220162040.GA8194@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com> <20070220155928.GA26600@2ka.mipt.ru> <200702201708.12858.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54016 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030198AbXBTQWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:22:15 -0500
Content-Disposition: inline
In-Reply-To: <200702201708.12858.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 05:08:12PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > Adding XOR with constant value does not change distribution.
> > Variable salt will end up with differnet buckets for the same flow.
> > It is forbidden - it is not the situation created for passwd/des decades
> > ago.
> 
> Adding a random hint to jhash (random value picked at boot time, not known by 
> attacker) permits to have a secure hash table : An attacker cannot build an 
> attack to fill one particular hash chain.
> 
> See net/ipv4/route.c (function rt_hash_code()) to see how its used for route 
> cache.

It is secrecy, not security - attacker will check the source and find
where constant per-boot value is added and recalculate attack vector -
we all were college students, it would be even more fun to crack.

In that regard Jenkins ahsh and XOR one have _exactly_ the same attack
vector, only Jenkins is a bit more sophisticated. I even think that
example in rt_hash_code() will endup with heavy problems when one of the
addresses is constant - my tests show problem exactly in the case of
jhash_2words() with random third parameter and constant one of the first
like in rt_hash_code().

-- 
	Evgeniy Polyakov
