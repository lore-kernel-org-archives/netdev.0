From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_make_synack() should use sock_wmalloc
Date: Fri, 30 Aug 2013 16:03:32 -0400 (EDT)
Message-ID: <20130830.160332.1978667608563540935.davem@davemloft.net>
References: <20130827234140.GA3301@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	eric.dumazet@gmail.com, pablo@netfilter.org
To: kernel@linuxace.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603Ab3H3UDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 16:03:35 -0400
In-Reply-To: <20130827234140.GA3301@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>
Date: Tue, 27 Aug 2013 16:41:40 -0700

> In commit 90ba9b19 (tcp: tcp_make_synack() can use alloc_skb()), Eric changed
> the call to sock_wmalloc in tcp_make_synack to alloc_skb.  In doing so,
> the netfilter owner match lost its ability to block the SYNACK packet on
> outbound listening sockets.  Revert the change, restoring the owner match
> functionality.
> 
> This closes netfilter bugzilla #847.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>

Applied and queued up for -stable, thanks.

Eric, I guess if you really want to get rid of the wmem atomics you
can just attach the socket and make a special destructor.  Maybe it
is not even worth it at that point however.
