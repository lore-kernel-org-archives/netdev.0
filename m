From: Martin Mares <mj@ucw.cz>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 8 Jul 2011 19:40:55 +0200
Message-ID: <mj+md-20110708.173556.16517.nikam@ucw.cz>
References: <20110708.101056.89960389404725087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nikam.ms.mff.cuni.cz ([195.113.20.16]:39250 "EHLO
	nikam.ms.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab1GHRqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 13:46:02 -0400
Content-Disposition: inline
In-Reply-To: <20110708.101056.89960389404725087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Using Jenkins is over the top.
> 
> If the premise is that the hash_rnd is a random unpredictable key,
> then:
> 
> 	key ^ dev->ifindex ^ hash_rnd
> 
> results in an unpredictable hash result, even if an attacker
> controls 'key' and 'dev->ifindex' completely.
> 
> Therefore, if this hash result is unpredictable, then the
> final fold phase of:
> 
> 	(val >> 8) ^ (val >> 16) ^ (val >> 24)
> 
> is unpredictable as well.

If I understand the new hash function correctly, it should be very easy
for an outside attacker to force arbitrary collisions.

The hash function is linear, so it can be reduced to:

	a = key ^ dev->ifindex
	return (a >> 8) ^ (a >> 16) ^ (a >> 24)				// (1)
	     ^ (hash_rnd >> 8) ^ (hash_rnd >> 16) ^ (hash_rnd >> 24)	// (2)

Where (1) is under control of the attacker and while (2) is not, the
only effect of (2) is a random permutation on the hash buckets.

I.e., the attacker can generate arbitrarily long collision chains,
although he cannot pick the bucket where the collisions happen :)

Am I right?

				Have a nice fortnight
-- 
Martin `MJ' Mares                          <mj@ucw.cz>   http://mj.ucw.cz/
Faculty of Math and Physics, Charles University, Prague, Czech Rep., Earth
If going to a church makes you a Christian, does going to a garage make you a car?
