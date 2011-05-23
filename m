From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: avoid synchronize_rcu() in
 dev_deactivate_many
Date: Sun, 22 May 2011 21:02:55 -0400 (EDT)
Message-ID: <20110522.210255.1260763671419618526.davem@davemloft.net>
References: <1305884529.3173.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab1EWBED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:04:03 -0400
In-Reply-To: <1305884529.3173.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 May 2011 11:42:09 +0200

> dev_deactivate_many() issues one synchronize_rcu() call after qdiscs set
> to noop_qdisc.
> 
> This call is here to make sure they are no outstanding qdisc-less
> dev_queue_xmit calls before returning to caller.
> 
> But in dismantle phase, we dont have to wait, because we wont activate
> again the device, and we are going to wait one rcu grace period later in
> rollback_registered_many().
> 
> After this patch, device dismantle uses one synchronize_net() and one
> rcu_barrier() call only, so we have a ~30% speedup and a smaller RTNL
> latency.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>,
> CC: Ben Greear <greearb@candelatech.com>

Applied.
