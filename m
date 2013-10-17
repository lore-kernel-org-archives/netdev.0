From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: must unclone packets before mangling them
Date: Thu, 17 Oct 2013 16:08:53 -0400 (EDT)
Message-ID: <20131017.160853.1730185223687230325.davem@davemloft.net>
References: <1381863270.2045.62.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759409Ab3JQUIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:08:55 -0400
In-Reply-To: <1381863270.2045.62.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Oct 2013 11:54:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP stack should make sure it owns skbs before mangling them.
> 
> We had various crashes using bnx2x, and it turned out gso_size
> was cleared right before bnx2x driver was populating TC descriptor
> of the _previous_ packet send. TCP stack can sometime retransmit
> packets that are still in Qdisc.
> 
> Of course we could make bnx2x driver more robust (using
> ACCESS_ONCE(shinfo->gso_size) for example), but the bug is TCP stack.
> 
> We have identified two points where skb_unclone() was needed.
> 
> This patch adds a WARN_ON_ONCE() to warn us if we missed another
> fix of this kind.
> 
> Kudos to Neal for finding the root cause of this bug. Its visible
> using small MSS.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Applied and queued up for -stable.
