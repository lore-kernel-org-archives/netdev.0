From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix lockdep warning when intra-node messages
 are delivered
Date: Tue, 21 Oct 2014 15:30:25 -0400 (EDT)
Message-ID: <20141021.153025.246696199217285626.davem@davemloft.net>
References: <1413787595-14700-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755252AbaJUTa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 15:30:27 -0400
In-Reply-To: <1413787595-14700-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 20 Oct 2014 14:46:35 +0800

> When running tipcTC&tipcTS test suite, below lockdep unsafe locking
> scenario is reported:
 ...
> When intra-node messages are delivered from one process to another
> process, tipc_link_xmit() doesn't disable BH before it directly calls
> tipc_sk_rcv() on process context to forward messages to destination
> socket. Meanwhile, if messages delivered by remote node arrive at the
> node and their destinations are also the same socket, tipc_sk_rcv()
> running on process context might be preempted by tipc_sk_rcv() running
> BH context. As a result, the latter cannot obtain the socket lock as
> the lock was obtained by the former, however, the former has no chance
> to be run as the latter is owning the CPU now, so headlock happens. To
> avoid it, BH should be always disabled in tipc_sk_rcv().
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
