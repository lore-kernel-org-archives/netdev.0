From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Fix walker list corruption
Date: Wed, 16 Dec 2015 11:13:47 -0500 (EST)
Message-ID: <20151216.111347.341690028686366662.davem@davemloft.net>
References: <561797B7.3090807@canonical.com>
	<20151216084554.GA24395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbbLPQNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 11:13:49 -0500
In-Reply-To: <20151216084554.GA24395@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Dec 2015 16:45:54 +0800

> The commit ba7c95ea3870fe7b847466d39a049ab6f156aa2c ("rhashtable:
> Fix sleeping inside RCU critical section in walk_stop") introduced
> a new spinlock for the walker list.  However, it did not convert
> all existing users of the list over to the new spin lock.  Some
> continued to use the old mutext for this purpose.  This obviously
> led to corruption of the list.
> 
> The fix is to use the spin lock everywhere where we touch the list.
> 
> This also allows us to do rcu_rad_lock before we take the lock in
> rhashtable_walk_start.  With the old mutex this would've deadlocked
> but it's safe with the new spin lock.
> 
> Fixes: ba7c95ea3870 ("rhashtable: Fix sleeping inside RCU...")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
