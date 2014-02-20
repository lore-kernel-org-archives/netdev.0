From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Potentially-Failed state should not be
 reached from unconfirmed state
Date: Thu, 20 Feb 2014 13:25:16 -0500 (EST)
Message-ID: <20140220.132516.300630512363540955.davem@davemloft.net>
References: <5305FF60.80404@nsn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: matija.glavinic-pecotic.ext@nsn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbaBTSZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:25:18 -0500
In-Reply-To: <5305FF60.80404@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>
Date: Thu, 20 Feb 2014 14:13:04 +0100

> In current implementation it is possible to reach PF state from unconfirmed.
> We can interpret sctp-failover-02 in a way that PF state is meant to be reached
> only from active state, in the end, this is when entering PF state makes sense.
> Here are few quotes from sctp-failover-02, but regardless of these, same
> understanding can be reached from whole section 5:
> 
> Section 5.1, quickfailover guide:
>     "The PF state is an intermediate state between Active and Failed states."
> 
>     "Each time the T3-rtx timer expires on an active or idle
>     destination, the error counter of that destination address will 
>     be incremented.  When the value in the error counter exceeds
>     PFMR, the endpoint should mark the destination transport address as PF."
> 
> There are several concrete reasons for such interpretation. For start, rfc4960
> does not take into concern quickfailover algorithm. Therefore, quickfailover
> must comply to 4960. Point where this compliance can be argued is following
> behavior:
> When PF is entered, association overall error counter is incremented for each
> missed HB. This is contradictory to rfc4960, as address, while in unconfirmed
> state, is subjected to probing, and while it is probed, it should not increment
> association overall error counter. This has as a consequence that we might end
> up in situation in which we drop association due path failure on unconfirmed
> address, in case we have wrong configuration in a way:
> Association.Max.Retrans == Path.Max.Retrans.
> 
> Another reason is that entering PF from unconfirmed will cause a loss of address
> confirmed event when address is once (if) confirmed. This is fine from failover
> guide point of view, but it is not consistent with behavior preceding failover
> implementation and recommendation from 4960:
> 
> 5.4.  Path Verification
>    Whenever a path is confirmed, an indication MAY be given to the upper
>    layer.
> 
> Signed-off-by: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nsn.com>

Applied, thank you.
