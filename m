From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 15:51:00 -0500 (EST)
Message-ID: <20151222.155100.2233619580820015796.davem@davemloft.net>
References: <20151222204539.GA10690@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@codemonkey.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932782AbbLVUvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:51:01 -0500
In-Reply-To: <20151222204539.GA10690@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@codemonkey.org.uk>
Date: Tue, 22 Dec 2015 15:45:39 -0500

> ===============================
> [ INFO: suspicious RCU usage. ]
> 4.4.0-rc6-think+ #1 Not tainted
> -------------------------------
> lib/rhashtable.c:522 suspicious rcu_dereference_protected() usage!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 2 locks held by trinity-c1/3652:
>  #0:  (&p->lock){+.+.+.}, at: [<ffffffff9a3335a7>] seq_read+0xd7/0x900
>  #1:  (&(&ht->lock)->rlock){+.+...}, at: [<ffffffff9a56f29d>] rhashtable_walk_init+0x9d/0x170

I'm so confused, the code reads:

	spin_lock(&ht->lock);
	iter->walker->tbl =
		rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));

?!?!?!
