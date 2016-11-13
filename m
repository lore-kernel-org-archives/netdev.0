From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] ipv4: use new_gw for redirect neigh lookup
Date: Sun, 13 Nov 2016 12:25:41 -0500 (EST)
Message-ID: <20161113.122541.301891001345068219.davem@davemloft.net>
References: <1478794575-28748-1-git-send-email-ssurya@ieee.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssurya@ieee.org
To: stephen.suryaputra.lin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933841AbcKMRZm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:25:42 -0500
In-Reply-To: <1478794575-28748-1-git-send-email-ssurya@ieee.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Date: Thu, 10 Nov 2016 11:16:15 -0500

> In v2.6, ip_rt_redirect() calls arp_bind_neighbour() which returns 0
> and then the state of the neigh for the new_gw is checked. If the state
> isn't valid then the redirected route is deleted. This behavior is
> maintained up to v3.5.7 by check_peer_redirect() because rt->rt_gateway
> is assigned to peer->redirect_learned.a4 before calling
> ipv4_neigh_lookup().
> 
> After commit 5943634fc559 ("ipv4: Maintain redirect and PMTU info in
> struct rtable again."), ipv4_neigh_lookup() is performed without the
> rt_gateway assigned to the new_gw. In the case when rt_gateway (old_gw)
> isn't zero, the function uses it as the key. The neigh is most likely
> valid since the old_gw is the one that sends the ICMP redirect message.
> Then the new_gw is assigned to fib_nh_exception. The problem is: the
> new_gw ARP may never gets resolved and the traffic is blackholed.
> 
> So, use the new_gw for neigh lookup.
> 
> Changes from v1:
>  - use __ipv4_neigh_lookup instead (per Eric Dumazet).
> 
> Fixes: 5943634fc559 ("ipv4: Maintain redirect and PMTU info in struct rtable again.")
> Signed-off-by: Stephen Suryaputra Lin <ssurya@ieee.org>

Looks good, applied and queued up for -stable.

Thanks.
