From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Thu, 15 Oct 2009 10:59:19 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910151045220.2830@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: w@1wt.eu, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:38869 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755391AbZJOH7N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 03:59:13 -0400
In-Reply-To: <20091014.154349.83940908.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 14 Oct 2009, David Miller wrote:

> For now I'm pushing Willy's change into Linus's tree.

	Better do not apply this change because it's reasoning is
wrong - counter is increased at the same time when threshold
decreases - what this change does is to half the TCP_DEFER_ACCEPT
period (assuming first ACK comes immediately) with the side
effect to switch off the TCP_DEFER_ACCEPT flag during
SYN-ACK next retransmits. When one uses TCP_DEFER_ACCEPT=1 as
flag the listener will see the new socket on the 2nd ACK which
contradicts with the TCP_DEFER_ACCEPT semantic to wakeup only
when data comes.

> After more discussion we can revert if necessary.
> 
> I won't submit this to -stable until the discussion is fully resolved.
> 
> Thanks!

Regards

--
Julian Anastasov <ja@ssi.bg>
