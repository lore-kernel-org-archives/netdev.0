From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: dont handle MTU reduction on LISTEN socket
Date: Mon, 18 Mar 2013 13:32:25 -0400 (EDT)
Message-ID: <20130318.133225.1613717870612687705.davem@davemloft.net>
References: <1363626088.29475.155.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dormando@rydia.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3CRRc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 13:32:29 -0400
In-Reply-To: <1363626088.29475.155.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 18 Mar 2013 10:01:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When an ICMP ICMP_FRAG_NEEDED (or ICMPV6_PKT_TOOBIG) message finds a
> LISTEN socket, and this socket is currently owned by the user, we
> set TCP_MTU_REDUCED_DEFERRED flag in listener tsq_flags.
> 
> This is bad because if we clone the parent before it had a chance to
> clear the flag, the child inherits the tsq_flags value, and next
> tcp_release_cb() on the child will decrement sk_refcnt.
> 
> Result is that we might free a live TCP socket, as reported by
> Dormando.
> 
> IPv4: Attempt to release TCP socket in state 1
> 
> Fix this issue by testing sk_state against TCP_LISTEN early, so that we
> set TCP_MTU_REDUCED_DEFERRED on appropriate sockets (not a LISTEN one)
> 
> This bug was introduced in commit 563d34d05786
> (tcp: dont drop MTU reduction indications)
> 
> Reported-by: dormando <dormando@rydia.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
