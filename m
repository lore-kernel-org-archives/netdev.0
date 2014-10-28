From: David Miller <davem@davemloft.net>
Subject: Re: irq disable in __netdev_alloc_frag() ?
Date: Tue, 28 Oct 2014 00:56:42 -0400 (EDT)
Message-ID: <20141028.005642.1332691629979036817.davem@davemloft.net>
References: <20141027213523.799da09c@redhat.com>
	<alpine.DEB.2.11.1410272129530.21936@gentwo.org>
	<CANn89i+U0=YrwoUSASejsS37EiXO7dKR25Vx04at3PqGA1EpHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux.com, brouer@redhat.com, eric.dumazet@gmail.com,
	alexander.duyck@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299AbaJ1E4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 00:56:44 -0400
In-Reply-To: <CANn89i+U0=YrwoUSASejsS37EiXO7dKR25Vx04at3PqGA1EpHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 27 Oct 2014 19:46:20 -0700

> Unfortunately, SLUB is more expensive than SLAB for many networking
> workloads.
> 
> The cost of disabling interrupts is pure noise compared to cache
> line misses.
> 
> SLUB has poor behavior compared to SLAB with alien caches, even with
> the side effect that 'struct page' is 64 bytes aligned instead of
> being 56 bytes with SLAB

And SLAB completely shits itself when lots of memory gets cached up on
a foreign node.

This discussion has happened many times, SLAB may be faster when things
work out nicely, but it acts poorly wrt. keeping foreign memory from
being cached too aggressively.

And there is a cost for that, which is that foreign memory has to be
properly balanced back to it's home node.
