From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/14] tipc: clean up media and bearer layer
Date: Thu, 13 Feb 2014 17:57:32 -0500 (EST)
Message-ID: <20140213.175732.676150849615456691.davem@davemloft.net>
References: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbaBMW5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:57:36 -0500
In-Reply-To: <1392330558-19048-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 13 Feb 2014 17:29:04 -0500

> This commit series aims at facilitating future changes to the
> locking policy around nodes, links and bearers.
> 
> Currently, we have a big read/write lock (net_lock) that is used for
> serializing all changes to the node, link and bearer lists, as well
> as to their mutual pointers and references.
> 
> But, in order to allow for concurrent access to the contents of these
> structures, net_lock is only used in read mode by the data path code,
> and hence a finer granular locking policy must be applied inside the
> scope of net_lock: a spinlock (node_lock) for each node structure,
> and another one (bearer_lock) for protection of bearer structures.
> 
> This locking policy has proved hard to maintain. We have several 
> times encountered contention problems between node_lock and 
> bearer_lock, and with the advent of the RCU locking mechanism we
> feel it is anyway obsolete and ripe for improvements.
> 
> We now plan to replace net_lock with an RCU lock, as well as
> getting rid of bearer_lock altogether. This will both reduce data
> path overhead and make the code more manageable, while reducing the
> risk of future lock contention problems.
> 
> Prior to these changes, we need to do some necessary cleanup and
> code consolidation. This is what we do with this commit series,
> before we finally remove bearer_lock. In a later series we will
> replace net_lock with an RCU lock.
> 
> v2:
>  - Re-inserted a removed kerneldoc entry in commit#5, based on 
>    feedback from D. Miller.

Series applied, thanks.
