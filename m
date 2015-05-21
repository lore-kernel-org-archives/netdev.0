From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add a force_schedule argument to
 sk_stream_alloc_skb()
Date: Thu, 21 May 2015 16:58:13 -0400 (EDT)
Message-ID: <20150521.165813.1925516530964458536.davem@davemloft.net>
References: <1432067215.621.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702AbbEUU6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 16:58:14 -0400
In-Reply-To: <1432067215.621.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 May 2015 13:26:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 8e4d980ac215 ("tcp: fix behavior for epoll edge trigger")
> we fixed a possible hang of TCP sockets under memory pressure,
> by allowing sk_stream_alloc_skb() to use sk_forced_mem_schedule()
> if no packet is in socket write queue.
> 
> It turns out there are other cases where we want to force memory
> schedule :
> 
> tcp_fragment() & tso_fragment() need to split a big TSO packet into
> two smaller ones. If we block here because of TCP memory pressure,
> we can effectively block TCP socket from sending new data.
> If no further ACK is coming, this hang would be definitive, and socket
> has no chance to effectively reduce its memory usage.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
