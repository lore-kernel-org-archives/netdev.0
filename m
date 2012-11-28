From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Introduce notification events for routing changes
Date: Wed, 28 Nov 2012 17:59:29 -0500 (EST)
Message-ID: <20121128.175929.618012822860698468.davem@davemloft.net>
References: <1354048045-17846-1-git-send-email-kadlec@blackhole.kfki.hu>
	<1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kadlec@blackhole.kfki.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1354048045-17846-2-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Date: Tue, 27 Nov 2012 21:27:25 +0100

> The netfilter MASQUERADE target does not handle the case when the routing
> changes and the source address of existing connections become invalid.
> The problem can be solved if routing modifications create events to which
> the MASQUERADE target can subscribe and then delete the affected
> connections.
> 
> The patch adds the required event support for IPv4/IPv6.
> 
> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

What part of the information are you actually interested in?

Because just saying that a route is added or removed using fib_info X
doesn't tell you a whole lot.

fib_info only encapsulates the information that can be shared heaving
with many ipv4 routes.  It doesn't include the TOS or other aspects
stored in the fib_alias part.  I can only guess that you did not
use fib_alias in order to avoid having to export that structure to
the callers, as it is currently private to net/ipv4/

The notifier doesn't seem to distinguish between adds or removes
either, making it less useful in another way.

I would suggest passing a super-structure that gives the event type:

	struct route_changed_info {
		enum {
			add,
			remove,
		} event_type;
		void *data;
	};

or something like that.

Can you also show us exactly how this will be used?  Otherwise we
have to guess.
