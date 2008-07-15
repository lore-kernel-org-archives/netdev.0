From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Tue, 15 Jul 2008 03:45:57 -0700 (PDT)
Message-ID: <20080715.034557.06568516.davem@davemloft.net>
References: <E1KIMIg-0007MB-00@gondolin.me.apana.org.au>
	<20080714.045806.213105998.davem@davemloft.net>
	<487C487C.5030403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754261AbYGOKp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 06:45:56 -0400
In-Reply-To: <487C487C.5030403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 15 Jul 2008 08:49:32 +0200

> f2(X) = X % N ;
> ->g2(X) = ((u64)X * N) >> 32;
> 
> But g2() is quite similar to g1() :)
> 
> f2() & g2() functions are different of course, but should give 
> same hash spreading if X has an uniform distribution in 32bits space.

I thought about this some more and I'm having my doubts about
this.

Let's say N is 8, this means that all values of X smaller than
0x20000000 will hash to zero.

It means that all of your entropy comes from the top 3 bits of
the X.

So like hashlimit we'd need to use jhash or something like that
to spread the bits around some more.

I also wonder if we should add hash randomization like the ipv4
routing cache.  I wonder if the performance hit is bad enough
to warrant protection against that.  After all, if you "exploit"
this hash you just end up with the performance we have today.

For now I'm leaving the modulus in there until we understand this
better.

