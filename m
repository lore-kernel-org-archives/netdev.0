From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,v2] Fixes: 5943634fc559 ("ipv4: Maintain redirect
 and PMTU info in struct rtable again.")
Date: Wed, 09 Nov 2016 20:20:34 -0500 (EST)
Message-ID: <20161109.202034.2263389836773612417.davem@davemloft.net>
References: <1478558919-12014-1-git-send-email-ssurya@ieee.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssurya@ieee.org
To: stephen.suryaputra.lin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbcKJBUh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:20:37 -0500
In-Reply-To: <1478558919-12014-1-git-send-email-ssurya@ieee.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Suryaputra Lin <stephen.suryaputra.lin@gmail.com>
Date: Mon,  7 Nov 2016 17:48:39 -0500

> ICMP redirects behavior is different after the commit above. An email
> requesting the explanation on why the behavior needs to be different
> was sent earlier to netdev (https://patchwork.ozlabs.org/patch/687728/).
> Since there isn't a reply yet, I decided to prepare this formal patch.
> 
> In v2.6 kernel, it used to be that ip_rt_redirect() calls
> arp_bind_neighbour() which returns 0 and then the state of the neigh for
> the new_gw is checked. If the state isn't valid then the redirected
> route is deleted. This behavior is maintained up to v3.5.7 by
> check_peer_redirect() because rt->rt_gateway is assigned to
> peer->redirect_learned.a4 before calling ipv4_neigh_lookup().
> 
> After the commit, ipv4_neigh_lookup() is performed without the
> rt_gateway assigned to the new_gw. In the case when rt_gateway (old_gw)
> isn't zero, the function uses it as the key. The neigh is most likely valid
> since the old_gw is the one that sends the ICMP redirect message. Then the
> new_gw is assigned to fib_nh_exception. The problem is: the new_gw ARP may
> never gets resolved and the traffic is blackholed.
> 
> Changes from v1:
>  - use __ipv4_neigh_lookup instead (per Eric Dumazet).
> 
> Signed-off-by: Stephen Suryaputra Lin <ssurya@ieee.org>

The Fixes tag belongs in the commit message body, right before the
signoff(s).  And you need to therefore write an appropriate subject
line of the form:

	[PATCH net,v2] $SUBSYSTEM: $DESCRIPTION
