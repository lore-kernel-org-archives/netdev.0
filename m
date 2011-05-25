From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hold rtnl again in dump callbacks
Date: Wed, 25 May 2011 17:58:28 -0400 (EDT)
Message-ID: <20110525.175828.952417507003208045.davem@davemloft.net>
References: <1306344844.11400.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378Ab1EYV7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:59:39 -0400
In-Reply-To: <1306344844.11400.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 May 2011 19:34:04 +0200

> Commit e67f88dd12f6 (dont hold rtnl mutex during netlink dump callbacks)
> missed fact that rtnl_fill_ifinfo() must be called with rtnl held.
> 
> Because of possible deadlocks between two mutexes (cb_mutex and rtnl),
> its not easy to solve this problem, so revert this part of the patch.
> 
> It also forgot one rcu_read_unlock() in FIB dump_rules()
> 
> Add one ASSERT_RTNL() in rtnl_fill_ifinfo() to remind us the rule.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> ---
> I tried to solve this problem differently but failed. We need more
> preliminary steps.

Applied.
