From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 10:47:39 -0700 (PDT)
Message-ID: <20110708.104739.169518036069870432.davem@davemloft.net>
References: <20110708.101056.89960389404725087.davem@davemloft.net>
	<mj+md-20110708.173556.16517.nikam@ucw.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mj@ucw.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab1GHRrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 13:47:46 -0400
In-Reply-To: <mj+md-20110708.173556.16517.nikam@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Mares <mj@ucw.cz>
Date: Fri, 8 Jul 2011 19:40:55 +0200

> The hash function is linear, so it can be reduced to:
> 
> 	a = key ^ dev->ifindex
> 	return (a >> 8) ^ (a >> 16) ^ (a >> 24)				// (1)
> 	     ^ (hash_rnd >> 8) ^ (hash_rnd >> 16) ^ (hash_rnd >> 24)	// (2)

Is this really the same?  The inclusion of a full 32-bit xor
with hash_rnd before folding was intentional, so that the
final folding occurs on a completely "random" value.

> Where (1) is under control of the attacker and while (2) is not, the
> only effect of (2) is a random permutation on the hash buckets.
> 
> I.e., the attacker can generate arbitrarily long collision chains,
> although he cannot pick the bucket where the collisions happen :)
> 
> Am I right?

Please give an example :-)
