From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: avoid a pair of dst_hold()/dst_release() in ip_append_data()
Date: Tue, 25 Nov 2008 03:22:32 +0100
Message-ID: <20081125022232.GE6703@one.firstfloor.org>
References: <87y6z9h33h.fsf@basil.nowhere.org> <492A7E85.3060502@cosmosbay.com> <492A8F05.3080509@cosmosbay.com> <20081124.155531.135918197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, andi@firstfloor.org, netdev@vger.kernel.org,
	minyard@acm.org, christian@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41540 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbYKYCMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 21:12:19 -0500
Content-Disposition: inline
In-Reply-To: <20081124.155531.135918197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Thinking more I believe we can do similar tricks for all TCP
> transmit traffic.

Sounds reasonable.

> 
> Packets bound to sockets never outlive those sockets (and thus
> their cached routes) unless we skb_orphan().
> 
> The only not covered case is where the socket cached route
> is reset or changed.  We could defer the dst put until the
> transmit queue reaches a certain point, kind of like a retransmit
> queue RCU :-)
> 
> Just some ideas...

netfilter makes it somewhat tricky, for compatibility you would
need to reclone the route on the fly.

-Andi

-- 
ak@linux.intel.com
