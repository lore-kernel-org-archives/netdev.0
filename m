From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 17:38:19 +0100
Message-ID: <200702201738.19590.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201708.12858.dada1@cosmosbay.com> <20070220162040.GA8194@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44103 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030243AbXBTQi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:38:29 -0500
In-Reply-To: <20070220162040.GA8194@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 17:20, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 05:08:12PM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > > Adding XOR with constant value does not change distribution.
> > > Variable salt will end up with differnet buckets for the same flow.
> > > It is forbidden - it is not the situation created for passwd/des
> > > decades ago.
> >
> > Adding a random hint to jhash (random value picked at boot time, not
> > known by attacker) permits to have a secure hash table : An attacker
> > cannot build an attack to fill one particular hash chain.
> >
> > See net/ipv4/route.c (function rt_hash_code()) to see how its used for
> > route cache.
>
> It is secrecy, not security - attacker will check the source and find
> where constant per-boot value is added and recalculate attack vector -
> we all were college students, it would be even more fun to crack.
>
> In that regard Jenkins ahsh and XOR one have _exactly_ the same attack
> vector, only Jenkins is a bit more sophisticated. I even think that
> example in rt_hash_code() will endup with heavy problems when one of the
> addresses is constant - my tests show problem exactly in the case of
> jhash_2words() with random third parameter and constant one of the first
> like in rt_hash_code().

Please define heavy problem.

On most hosts, with one NIC, one IP address, most entries in cache have the 
same address (IP address of eth0 or localhost). It just works.

Last time I checked, the 2^21 route cache I am using was correctly filled, 
thanks to jhash.

Again, the random value is 32bits. If jhash happens to be cracked by your 
students, we just put md5 or whatever in...

You can call it secrecy or whatever, fact is : it's just working, far better 
than XOR previous hash function.

