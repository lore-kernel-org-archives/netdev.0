From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net 1/1] tipc: fix bug in link failover handling
Date: Mon, 09 Mar 2015 16:20:27 -0400 (EDT)
Message-ID: <20150309.162027.114207740254748981.davem@redhat.com>
References: <1425932182-31518-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752407AbbCIUUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 16:20:51 -0400
In-Reply-To: <1425932182-31518-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon,  9 Mar 2015 16:16:22 -0400

> In commit c637c1035534867b85b78b453c38c495b58e2c5a
> ("tipc: resolve race problem at unicast message reception") we
> introduced a new mechanism for delivering buffers upwards from link
> to socket layer.
> 
> That code contains a bug in how we handle the new link input queue
> during failover. When a link is reset, some of its users may be blocked
> because of congestion, and in order to resolve this, we add any pending
> wakeup pseudo messages to the link's input queue, and deliver them to
> the socket. This misses the case where the other, remaining link also
> may have congested users. Currently, the owner node's reference to the
> remaining link's input queue is unconditionally overwritten by the
> reset link's input queue. This has the effect that wakeup events from
> the remaining link may be unduely delayed (but not lost) for a
> potentially long period.
> 
> We fix this by adding the pending events from the reset link to the
> input queue that is currently referenced by the node, whichever one
> it is.
> 
> This commit should be applied to both net and net-next.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Jon, there is no such thing, ever, as a patch that gets applied to both
'net' and 'net-next'.

The patch is either targetted at 'net' or 'net-next', not both.

If it is targetted at 'net', as a proper bug fix should be, then naturally
it will propagate implicitly to 'net-next' as merges occur.

I'm applying this, but I'm getting kinda tired of explaining this stuff
to people, expecially as it is clearly documented in the netdev FAQ.
