From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix bug in broadcast retransmit code
Date: Mon, 12 Jan 2015 16:02:26 -0500 (EST)
Message-ID: <20150112.160226.1565196942326918189.davem@davemloft.net>
References: <1420738047-16466-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbALVC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:02:28 -0500
In-Reply-To: <1420738047-16466-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  8 Jan 2015 12:27:27 -0500

> In commit 58dc55f25631178ee74cd27185956a8f7dcb3e32 ("tipc: use generic
> SKB list APIs to manage link transmission queue") we replace all list
> traversal loops with the macros skb_queue_walk() or
> skb_queue_walk_safe(). While the previous loops were based on the
> assumption that the list was NULL-terminated, the standard macros
> stop when the iterator reaches the list head, which is non-NULL.
> 
> In the function bclink_retransmit_pkt() this macro replacement has
> lead to a bug. When we receive a BCAST STATE_MSG we unconditionally
> call the function bclink_retransmit_pkt(), whether there really is
> anything to retransmit or not, assuming that the sequence number
> comparisons will lead to the correct behavior. However, if the
> transmission queue is empty, or if there are no eligible buffers in
> the transmission queue, we will by mistake pass the list head pointer
> to the function tipc_link_retransmit(). Since the list head is not a
> valid sk_buff, this leads to a crash.
> 
> In this commit we fix this by only calling tipc_link_retransmit()
> if we actually found eligible buffers in the transmission queue.
> 
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
