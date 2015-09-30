From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: add pfmemalloc check in sk_add_backlog()
Date: Tue, 29 Sep 2015 21:56:07 -0700 (PDT)
Message-ID: <20150929.215607.1418732892830129304.davem@davemloft.net>
References: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gthelen@google.com, mhocko@suse.com,
	mgorman@suse.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbbI3E4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:56:08 -0400
In-Reply-To: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Sep 2015 18:52:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Greg reported crashes hitting the following check in __sk_backlog_rcv()
> 
> 	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC)); 
> 
> The pfmemalloc bit is currently checked in sk_filter().
> 
> This works correctly for TCP, because sk_filter() is ran in
> tcp_v[46]_rcv() before hitting the prequeue or backlog checks.
> 
> For UDP or other protocols, this does not work, because the sk_filter()
> is ran from sock_queue_rcv_skb(), which might be called _after_ backlog
> queuing if socket is owned by user by the time packet is processed by
> softirq handler.
> 
> Fixes: b4b9e35585089 ("netvm: set PF_MEMALLOC as appropriate during SKB processing")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Greg Thelen <gthelen@google.com>

Applied, thanks Eric.
