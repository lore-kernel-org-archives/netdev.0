From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Don't update slave->link until ready to commit
Date: Thu, 25 May 2017 14:50:40 -0400 (EDT)
Message-ID: <20170525.145040.1004688199988361146.davem@davemloft.net>
References: <1495680317-11308-1-git-send-email-nsujir@tintri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com,
        jay.vosburgh@canonical.com
To: nsujir@tintri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759115AbdEYSul (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 14:50:41 -0400
In-Reply-To: <1495680317-11308-1-git-send-email-nsujir@tintri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@tintri.com>
Date: Wed, 24 May 2017 19:45:17 -0700

> In the loadbalance arp monitoring scheme, when a slave link change is
> detected, the slave->link is immediately updated and slave_state_changed
> is set. Later down the function, the rtnl_lock is acquired and the
> changes are committed, updating the bond link state.
> 
> However, the acquisition of the rtnl_lock can fail. The next time the
> monitor runs, since slave->link is already updated, it determines that
> link is unchanged. This results in the bond link state permanently out
> of sync with the slave link.
> 
> This patch modifies bond_loadbalance_arp_mon() to handle link changes
> identical to bond_ab_arp_{inspect/commit}(). The new link state is
> maintained in slave->new_link until we're ready to commit at which point
> it's copied into slave->link.
> 
> NOTE: miimon_{inspect/commit}() has a more complex state machine
> requiring the use of the bond_{propose,commit}_link_state() functions
> which maintains the intermediate state in slave->link_new_state. The arp
> monitors don't require that.
> 
> Testing: This bug is very easy to reproduce with the following steps.
> 1. In a loop, toggle a slave link of a bond slave interface.
> 2. In a separate loop, do ifconfig up/down of an unrelated interface to
> create contention for rtnl_lock.
> Within a few iterations, the bond link goes out of sync with the slave
> link.
> 
> Signed-off-by: Nithin Nayak Sujir <nsujir@tintri.com>

Applied, thank you.
