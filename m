From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Thu, 07 Jan 2010 01:27:01 -0800 (PST)
Message-ID: <20100107.012701.257511338.davem@davemloft.net>
References: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750930Ab0AGJ0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:26:53 -0500
In-Reply-To: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 6 Jan 2010 20:43:48 -0800

> In rt6_pmtu_discovery a route lookup is done constrained to the
> receiving interface of the ICMP message.  In the case of an asymmetric
> routing, the receive interface may be different than the sending
> interface, so no route will be found in such cases and pmtu is never
> correctly set in the route to the destination.  This patch fixes that
> by not using the receive interface in the lookup.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

This needs to do what the IPV4 side does, iterate over specific then
"any" device index, doing a lookup for each case until the route is
found, therefore starting from more specific and going towards less
specific routes.
