From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 14:30:12 -0500 (EST)
Message-ID: <20131219.143012.205185984019527730.davem@davemloft.net>
References: <20131219000759.GF3505@order.stressinduktion.org>
	<20131219.001203.1942468169345523058.davem@davemloft.net>
	<20131219121757.GD14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911Ab3LSTaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:30:14 -0500
In-Reply-To: <20131219121757.GD14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 19 Dec 2013 13:17:57 +0100

> Networking software on the end system which wants to guard against
> that kind of fragmentation can do so by using the various knobs to
> limit pmtu notification processing or use IP_PMTUDISC_INTERFACE to
> protect itself from sending fragments.

And that's part of where my irritation is coming from.

Applications have to opt-in to this new socket option based behavior,
but you're making the routing thing default to on.

And even if we default it to off, someone is going to cry and tell all
the distributions to turn it on in /etc/sysctl.conf, just like they
did for rp_filter.  And they will.  I don't have the strength and time
to fight every person who makes these decisions at all the major
distributions to explain to each and every one of them how foolish it
would be.

No end host should have rp_filter on.  It unnecessarily makes our
routing lookups much more expensive for zero gain on an end host.  But
people convinced the distributions that turning it on everywhere by
default was a good idea and it stuck.

I don't want to create a carrot for that kind of situation again.
