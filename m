From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: percpu nh_rth_output cache
Date: Tue, 31 Jul 2012 14:43:11 -0700 (PDT)
Message-ID: <20120731.144311.1857420608722189065.davem@davemloft.net>
References: <1343749530.21269.336.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab2GaVnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 17:43:12 -0400
In-Reply-To: <1343749530.21269.336.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jul 2012 17:45:30 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Input path is mostly run under RCU and doesnt touch dst refcnt
> 
> But output path on forwarding or UDP workloads hits
> badly dst refcount, and we have lot of false sharing, for example
> in ipv4_mtu() when reading rt->rt_pmtu
> 
> Using a percpu cache for nh_rth_output gives a nice performance
> increase at a small cost.
> 
> 24 udpflood test on my 24 cpu machine (dummy0 output device)
> (each process sends 1.000.000 udp frames, 24 processes are started)
> 
> before : 5.24 s
> after : 2.06 s
> For reference, time on linux-3.5 : 6.60 s
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.

However I think fib_create_info() should fail if it cannot alloc_percpu()
successfully, instead of having funny logic in rt_cache_route().
