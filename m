From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/3] ipv4: Invalidate the socket cached route on
 pmtu events if possible
Date: Fri, 18 Jan 2013 14:38:58 -0500 (EST)
Message-ID: <20130118.143858.897140770429940003.davem@davemloft.net>
References: <50F3C153.9030204@oktetlabs.ru>
	<20130118081145.GB24987@secunet.com>
	<20130118081419.GC24987@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, bhutchings@solarflare.com,
	netdev@vger.kernel.org, Alexandra.Kossovsky@oktetlabs.ru
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:39:01 -0500
In-Reply-To: <20130118081419.GC24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 18 Jan 2013 09:14:20 +0100

> The route lookup in ipv4_sk_update_pmtu() might return a route
> different from the route we cached at the socket. This is because
> standart routes are per cpu, so each cpu has it's own struct rtable.
> This means that we do not invalidate the socket cached route if the
> NET_RX_SOFTIRQ is not served by the same cpu that the sending socket
> uses. As a result, the cached route reused until we disconnect.
> 
> With this patch we invalidate the socket cached route if possible.
> If the socket is owened by the user, we can't update the cached
> route directly. A followup patch will implement socket release
> callback functions for datagram sockets to handle this case.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

This looks fine.
