From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] fib: use atomic_inc_not_zero() in
 fib_rules_lookup
Date: Mon, 27 Sep 2010 21:51:47 -0700 (PDT)
Message-ID: <20100927.215147.48498294.davem@davemloft.net>
References: <1285597107.23938.250.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751012Ab0I1Ev1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:51:27 -0400
In-Reply-To: <1285597107.23938.250.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Sep 2010 16:18:27 +0200

> It seems we dont use appropriate refcount increment in an
> rcu_read_lock() protected section.
> 
> fib_rule_get() might increment a null refcount and bad things could
> happen.
> 
> While fib_nl_delrule() respects an rcu grace period before calling
> fib_rule_put(), fib_rules_cleanup_ops() calls fib_rule_put() without a
> grace period.
> 
> Note : after this patch, we might avoid the synchronize_rcu() call done
> in fib_nl_delrule()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
