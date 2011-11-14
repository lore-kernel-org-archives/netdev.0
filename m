From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Mon, 14 Nov 2011 14:33:20 -0500 (EST)
Message-ID: <20111114.143320.773675445837769668.davem@davemloft.net>
References: <20111012.170805.2172804476308993385.davem@davemloft.net>
	<20111108.143630.106539981030509701.davem@davemloft.net>
	<20111114101244.GB20943@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1KNTda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:33:30 -0500
In-Reply-To: <20111114101244.GB20943@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 14 Nov 2011 11:12:44 +0100

> So for the moment I'm thinking about adding an ip_dst_mtu()
> function that returns dst->ops->default_mtu() for input routes
> and dst_mtu() for output routes. Then we could convert the
> dst_mtu() users in net/ipv4/ over to this one.

We'll need something similar for ipv6 eventually...

I would suggest that we do away with dst_ops->default_mtu() and just
have dst_ops->mtu() which gets invoked unconditionally by dst_mtu().

You can integrate the ->default_mtu() handling and the input route
check into this new method.  Then IPv6 can be fixed in a
straightforward manner later.
