From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 17:08:12 +0100
Message-ID: <200702201708.12858.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com> <20070220155928.GA26600@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43756 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965224AbXBTQIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:08:22 -0500
In-Reply-To: <20070220155928.GA26600@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 16:59, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 07:49:11AM -0800, Michael K. Edwards 
(medwards.linux@gmail.com) wrote:
> > On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > >Jenkins _does_ have them, I showed tests half a year ago and in this
> > >thread too. Actually _any_ hash has them it is just a matter of time
> > >to find one.
> >
> > I think you misunderstood me.  If you are trying to DoS me from
> > outside with a hash collision attack, you are trying to feed me
> > packets that fall into the same hash bucket.  The Jenkins hash does
> > not have to be artifact-free, and does not have to be
> > cryptographically strong.  It just has to do a passable job of mixing
> > a random salt into the tuple, so you don't know which string of
> > packets to feed me in order to fill one (or a few) of my buckets.
> > XORing salt into a folded tuple doesn't help; it just permutes the
> > buckets.
>
> Adding XOR with constant value does not change distribution.
> Variable salt will end up with differnet buckets for the same flow.
> It is forbidden - it is not the situation created for passwd/des decades
> ago.

Adding a random hint to jhash (random value picked at boot time, not known by 
attacker) permits to have a secure hash table : An attacker cannot build an 
attack to fill one particular hash chain.

See net/ipv4/route.c (function rt_hash_code()) to see how its used for route 
cache.

