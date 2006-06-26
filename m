From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Mon, 26 Jun 2006 10:43:11 -0700 (PDT)
Message-ID: <20060626.104311.111204162.davem@davemloft.net>
References: <20060623201928.32482.69191.stgit@stevo-desktop>
	<20060623.132647.39159829.davem@davemloft.net>
	<1151335571.2398.37.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4254
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751201AbWFZRnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 13:43:11 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151335571.2398.37.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Mon, 26 Jun 2006 10:26:11 -0500

> I guess what I think we should do is pass the fib_info * when its a IPv4
> route add/del, and a rt6_info * when its a IPv6 add/del.  This avoids
> having to create some new family independent struct.  What I'll have to
> do, however, is have specific notifier event enums for each: 
> 
> NETEVENT_IPV4_ROUTE_ADD
> NETEVENT_IPV4_ROUTE_DEL
> NETEVENT_IPV6_ROUTE_ADD
> NETEVENT_IPV6_ROUTE_DEL
> 
> This keeps it simple IMO...
> 
> Does that sound reasonable to you?

You can avoid creating an event per address family by defining your
data as:

	struct netevent_route_info {
		u16 family;
		void *data;
	};

and passing that through the notifier.

Then you just need NETEVENT_ROUTE_{ADD,DEL}

Just an idea...
