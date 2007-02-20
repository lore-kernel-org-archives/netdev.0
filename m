From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 18:20:26 +0100
Message-ID: <200702201820.27095.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201738.19590.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44728 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030325AbXBTRUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 12:20:37 -0500
In-Reply-To: <20070220165907.GB24930@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 17:59, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 05:38:19PM +0100, Eric Dumazet (dada1@cosmosbay.com) 
wrote:
> > > It is secrecy, not security - attacker will check the source and find
> > > where constant per-boot value is added and recalculate attack vector -
> > > we all were college students, it would be even more fun to crack.
> > >
> > > In that regard Jenkins ahsh and XOR one have _exactly_ the same attack
> > > vector, only Jenkins is a bit more sophisticated. I even think that
> > > example in rt_hash_code() will endup with heavy problems when one of
> > > the addresses is constant - my tests show problem exactly in the case
> > > of jhash_2words() with random third parameter and constant one of the
> > > first like in rt_hash_code().
> >
> > Please define heavy problem.
> >
> > On most hosts, with one NIC, one IP address, most entries in cache have
> > the same address (IP address of eth0 or localhost). It just works.
> >
> > Last time I checked, the 2^21 route cache I am using was correctly
> > filled, thanks to jhash.
> >
> > Again, the random value is 32bits. If jhash happens to be cracked by your
> > students, we just put md5 or whatever in...
> >
> > You can call it secrecy or whatever, fact is : it's just working, far
> > better than XOR previous hash function.
>
> Hmm, I've just ran following test:
> 1. created 2^20 hash table.
> 2. ran in loop (100*(2^20) iterations) following hashes:
>  a. xor hash (const_ip, const_ip, random_word)

So what ? to attack me you want to send 100*2^20 packets every minute ?

Thats nonsense... If you really can send so many packets, My pipe is full 
whatever I do of received packets. No Algo will protect me, even designed by 
Einstein.

If you look again at route cache, you will see chains length are limited by 
elasticity factor, that is usually 8... No need to try to reach 100 entries 
in a chain.

Yes, I can destroy Russia sending 2^10 nuclear weapons on major cities. You 
really should build a bunker right now :)

Now try to build an attack with 100 packets per second... and I will try to be 
smart too.

