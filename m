From: Andi Kleen <andi@firstfloor.org>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 15:06:04 -0700
Message-ID: <m2r57xx9rn.fsf@firstfloor.org>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<20110517.174431.1004332995189918916.davem@davemloft.net>
	<m262p9yp5f.fsf@firstfloor.org>
	<20110517.175044.2057517197524794568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1887 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932389Ab1EQWGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 18:06:37 -0400
In-Reply-To: <20110517.175044.2057517197524794568.davem@davemloft.net> (David
	Miller's message of "Tue, 17 May 2011 17:50:44 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>
> We're discussing the idea to do the defragmentation first
> so we can choose the flow properly and steer the packet
> to the correct cpu.
>
> This also would allos each fragmented packet to traverse the
> stack only once (one route lookup etc.) instead of once per
> fragment.

You could always check first in a cheap way (e.g. a small hash table) if
it's local or not (and bypass the defragmentation if routing is turned
off or the hash table would have collisions)

On the other hand if fragmentation is expensive it's probably
better to do it later anyways to spread it out better.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only
