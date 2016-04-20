From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp-tso: do not split TSO packets at
 retransmit time
Date: Tue, 19 Apr 2016 20:36:56 -0400 (EDT)
Message-ID: <20160419.203656.505846026424405432.davem@davemloft.net>
References: <1461012972-15757-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbcDTAg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 20:36:59 -0400
In-Reply-To: <1461012972-15757-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 18 Apr 2016 13:56:12 -0700

> 1 % packet losses are common today, and at 100Gbit speeds, this
> translates to ~80,000 losses per second. If we are unlucky and
> first MSS of a 45-MSS TSO is lost, we are cooking 44 MSS segments
> at rtx instead of a single 44-MSS TSO packet.

I'm having trouble understanding this.

If the first mss is lost, then we simply chop the 45 MSS TSO skb into
two pieces.  The first piece is a 1 MSS chunk for the retransmit, and
the second piece is remaining 44 MSS TSO skb.

I am pretty sure that is what the current stack does, and regardless
it is certainly what I intended it to do all those years ago when I
wrote this code. :-)

The only case where I can see this patch helping is when we have to
retransmit multi-mss chunks.  And yes indeed, it might be a useful
optimization to TSO those frames rather than sending them one MSS at a
time.
