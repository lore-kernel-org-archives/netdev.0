From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Tue, 17 Jul 2012 23:41:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1207172249270.1831@ja.ssi.bg>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54279 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858Ab2GQUeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 16:34:08 -0400
In-Reply-To: <20120717.061418.1893307699868826531.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 17 Jul 2012, David Miller wrote:

> These patches implement the final mechanism necessary to really allow
> us to go without the route cache in ipv4.
> 
> We need a place to have long-term storage of PMTU/redirect information
> which is independent of the routes themselves, yet does not get us
> back into a situation where we have to write to metrics or anything
> like that.
> 
> For this we use an "next-hop exception" table in the FIB nexthops.
> 
> Currently it is a simple linked list and uses a single global lock
> for synchronization, but that can be easily adjusted as-needed.
> 
> The one thing I desperately want to avoid is having to create clone
> routes in the FIB trie for this purpose, because that is very
> expensive.   However, I'm willing to entertain such an idea later
> if this current scheme proves to have downsides that the FIB trie
> variant would not have.

	IIRC, struct fib_info was shared by different
prefixes. It saves a lot of memory when thousands of
routes are created to same GW. Now if we end up with 1 or
2 fib_info structures for default routes, the nh_exceptions list
can become very long. May be fib_info is not a good place
to hide such data.

Regards

--
Julian Anastasov <ja@ssi.bg>
