From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/1] tipc: fix bug in multicast congestion
 handling
Date: Tue, 07 Oct 2014 14:50:35 -0400 (EDT)
Message-ID: <20141007.145035.531731732780897375.davem@davemloft.net>
References: <1412705554-24252-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755100AbaJGSuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 14:50:37 -0400
In-Reply-To: <1412705554-24252-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue,  7 Oct 2014 14:12:34 -0400

> One aim of commit 50100a5e39461b2a61d6040e73c384766c29975d ("tipc:
> use pseudo message to wake up sockets after link congestion") was
> to handle link congestion abatement in a uniform way for both unicast
> and multicast transmit. However, the latter doesn't work correctly,
> and has been broken since the referenced commit was applied.
> 
> If a user now sends a burst of multicast messages that is big
> enough to cause broadcast link congestion, it will be put to sleep,
> and not be waked up when the congestion abates as it should be.
> 
> This has two reasons. First, the flag that is used, TIPC_WAKEUP_USERS,
> is set correctly, but in the wrong field. Instead of setting it in the
> 'action_flags' field of the arrival node struct, it is by mistake set
> in the dummy node struct that is owned by the broadcast link, where it
> will never tested for. Second, we cannot use the same flag for waking
> up unicast and multicast users, since the function tipc_node_unlock()
> needs to pick the wakeup pseudo messages to deliver from different
> queues. It must hence be able to distinguish between the two cases.
> 
> This commit solves this problem by adding a new flag
> TIPC_WAKEUP_BCAST_USERS, and a new function tipc_bclink_wakeup_user().
> The latter is to be called by tipc_node_unlock() when the named flag,
> now set in the correct field, is encountered.
> 
> v2: using explicit 'unsigned int' declaration instead of 'uint', as
> per comment from David Miller.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
