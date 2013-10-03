From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: shrink tcp6_timewait_sock by one
 cache line
Date: Thu, 03 Oct 2013 17:43:57 -0400 (EDT)
Message-ID: <20131003.174357.89621984330679119.davem@davemloft.net>
References: <1380829642.19002.225.camel@edumazet-glaptop.roam.corp.google.com>
	<20131003.160252.2071364130742864278.davem@davemloft.net>
	<1380835645.19002.236.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873Ab3JCVoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:44:00 -0400
In-Reply-To: <1380835645.19002.236.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Oct 2013 14:27:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While working on tcp listener refactoring, I found that it
> would really make things easier if sock_common could include
> the IPv6 addresses needed in the lookups, instead of doing
> very complex games to get their values (depending on sock
> being SYN_RECV, ESTABLISHED, TIME_WAIT)
> 
> For this to happen, I need to be sure that tcp6_timewait_sock
> and tcp_timewait_sock consume same number of cache lines.
> 
> This is possible if we only use 32bits for tw_ttd, as we remove
> one 32bit hole in inet_timewait_sock
> 
> inet_tw_time_stamp() is defined and used, even if its current
> implementation looks like tcp_time_stamp : We might need finer
> resolution for tcp_time_stamp in the future.
> 
> Before patch : sizeof(struct tcp6_timewait_sock) = 0xc8
> 
> After patch : sizeof(struct tcp6_timewait_sock) = 0xc0
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v2: add a inet_tw_time_stamp() helper, per David request.

Looks great, applied, thanks Eric.
