From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Mon, 21 Jan 2013 14:18:07 -0500 (EST)
Message-ID: <20130121.141807.1939155236333256972.davem@davemloft.net>
References: <20130121115911.GE30530@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, ja@ssi.bg, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3AUTSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:18:10 -0500
In-Reply-To: <20130121115911.GE30530@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 21 Jan 2013 12:59:11 +0100

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
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
