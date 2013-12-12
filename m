From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: ipv4: must add synchronization in
 udp_sk_rx_dst_set()
Date: Wed, 11 Dec 2013 20:22:12 -0500 (EST)
Message-ID: <20131211.202212.1810247707228138095.davem@davemloft.net>
References: <1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386802011.19078.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab3LLBWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 20:22:13 -0500
In-Reply-To: <1386802011.19078.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Dec 2013 14:46:51 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Unlike TCP, UDP input path does not hold the socket lock.
> 
> Before messing with sk->sk_rx_dst, we must use a spinlock, otherwise
> multiple cpus could leak a refcount.
> 
> This patch also takes care of renewing a stale dst entry.
> (When the sk->sk_rx_dst would not be used by IP early demux)
> 
> Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.

Longterm, perhaps a candidate for using xchg() instead of this
spinlock?
