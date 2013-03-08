From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Fri, 8 Mar 2013 06:57:18 +0100
Message-ID: <20130308055718.GA28531@order.stressinduktion.org>
References: <20130307214211.GP7941@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50655 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932161Ab3CHF5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 00:57:20 -0500
Content-Disposition: inline
In-Reply-To: <20130307214211.GP7941@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 10:42:11PM +0100, Hannes Frederic Sowa wrote:
> ipv6_addr_hash can yield the exact same hash value for countless ip
> addresses from one /64 subnet. Let's make it a bit harder to create a
> long list of reassembly queues in the hash table by using a stronger hash.
> 
> I spotted this just by looking at the source and did not verify if it
> is really the case, so this patch has RFC status. But the jhash change
> should not really hurt anyway. This patch is only compile tested.

Hmpf, I haven't seen Eric's change(279e9f2: ipv6: optimize
inet6_hash_frag()) and tried to compare a v3.8 against a net-next
kernel. At a first sight, it seems in some kind of denial of service
scenario the relative amount of time spend in inet_frag_find increased,
but I will do more comparable benchmarks later today (could be also
because of other changes). I just wanted to let you know that I will do
more research on this one and that you shouldn't apply this patch for now.

I also noticed that this function is also used by netfilter in the
forwarding path. Perhaps a jenkins hash on the destination address would
be better, too. Perhaps a netfilter specific hash function could also
be used.

Greetings,

  Hannes
