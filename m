From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: correctly unlink packets from deferred
 packet queue
Date: Tue, 07 Jan 2014 16:17:10 -0500 (EST)
Message-ID: <20140107.161710.1111837486038919201.davem@davemloft.net>
References: <1389127896-7428-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbaAGVRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 16:17:14 -0500
In-Reply-To: <1389127896-7428-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue,  7 Jan 2014 15:51:36 -0500

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> When we pull a received packet from a link's 'deferred packets' queue
> for processing, its 'next' pointer is not cleared, and still refers to
> the next packet in that queue, if any. This is incorrect, but caused
> no harm before commit 40ba3cdf542a469aaa9083fa041656e59b109b90 ("tipc:
> message reassembly using fragment chain") was introduced. After that
> commit, it may sometimes lead to the following oops:
 ...
> This happens when the last fragment of a message has passed through the
> the receiving link's 'deferred packets' queue, and at least one other
> packet was added to that queue while it was there. After the fragment
> chain with the complete message has been successfully delivered to the
> receiving socket, it is released. Since 'next' pointer of the last
> fragment in the released chain now is non-NULL, we get the crash shown
> above.
> 
> We fix this by clearing the 'next' pointer of all received packets,
> including those being pulled from the 'deferred' queue, before they
> undergo any further processing.
> 
> Fixes: 40ba3cdf542a4 ("tipc: message reassembly using fragment chain")
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.
