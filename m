From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: output path optimizations
Date: Tue, 07 Aug 2012 16:26:30 -0700 (PDT)
Message-ID: <20120807.162630.311474956563871276.davem@davemloft.net>
References: <1344341996.28967.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932838Ab2HGX0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 19:26:30 -0400
In-Reply-To: <1344341996.28967.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Aug 2012 14:19:56 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Avoid dirtying neighbour's confirmed field.
> 
>   TCP workloads hits this cache line for each incoming ACK.
>   Lets write n->confirmed only if there is a jiffie change.
> 
> 2) Optimize neigh_hh_output() for the common Ethernet case, were
>    hh_len is less than 16 bytes. Replace the memcpy() call
>    by two inlined 64bit load/stores on x86_64.
> 
> Bench results using udpflood test, with -C option (MSG_CONFIRM flag
> added to sendto(), to reproduce the n->confirmed dirtying on UDP)
> 
> 24 threads doing 1.000.000 UDP sendto() on dummy device, 4 runs.
> 
> before : 2.247s, 2.235s, 2.247s, 2.318s
> after  : 1.884s, 1.905s, 1.891s, 1.895s
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, I'd like to significantly redo how the neigh confirmation
stuff works.

I'm not at all surprised it shows up on TCP workloads.
