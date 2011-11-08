From: David Miller <davem@davemloft.net>
Subject: Re: dst->obsolete has become pointless
Date: Tue, 08 Nov 2011 12:20:20 -0500 (EST)
Message-ID: <20111108.122020.1080743546477280623.davem@davemloft.net>
References: <20111104.230910.520924516201406800.davem@davemloft.net>
	<20111108093424.GG22141@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448Ab1KHRUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 12:20:36 -0500
In-Reply-To: <20111108093424.GG22141@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 8 Nov 2011 10:34:24 +0100

> I don't know what to do with DecNET, but we probaply need to decide
> about the future of dst->obsolete before we can fix the ipv4 PMTU
> problems. Possible fixes might depend on whether ->dst_check() is
> always invoked or not.

Simplest thing to do is to move dst->obsolete check into DecNET's
->dst_check() handler, then call ->dst_check() unconditionally.

Then we can just set dst->obsolete to zero for all route types,
and kill the "initial_obsolete" argument to dst_alloc() and
associated logic.

As things are currently implemented, because of how we elide the full
table scan and flush, ipv4 and ipv6 really need to do the serial
number check every time so we have to keep things as they are.

Things get more interesting with the routing cache removed, of course,
but that is still a long ways off. :-)
