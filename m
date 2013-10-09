From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: make lookups simpler and faster
Date: Tue, 08 Oct 2013 23:21:25 -0400 (EDT)
Message-ID: <20131008.232125.1605815898898029345.davem@davemloft.net>
References: <1380840149.19002.256.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab3JIDV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 23:21:29 -0400
In-Reply-To: <1380840149.19002.256.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Oct 2013 15:42:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP listener refactoring, part 4 :
> 
> To speed up inet lookups, we moved IPv4 addresses from inet to struct
> sock_common
> 
> Now is time to do the same for IPv6, because it permits us to have fast
> lookups for all kind of sockets, including upcoming SYN_RECV.
> 
> Getting IPv6 addresses in TCP lookups currently requires two extra cache
> lines, plus a dereference (and memory stall).
> 
> inet6_sk(sk) does the dereference of inet_sk(__sk)->pinet6
> 
> This patch is way bigger than its IPv4 counter part, because for IPv4,
> we could add aliases (inet_daddr, inet_rcv_saddr), while on IPv6,
> it's not doable easily.
> 
> inet6_sk(sk)->daddr becomes sk->sk_v6_daddr
> inet6_sk(sk)->rcv_saddr becomes sk->sk_v6_rcv_saddr
> 
> And timewait socket also have tw->tw_v6_daddr & tw->tw_v6_rcv_saddr
> at the same offset.
> 
> We get rid of INET6_TW_MATCH() as INET6_MATCH() is now the generic
> macro.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot Eric.
