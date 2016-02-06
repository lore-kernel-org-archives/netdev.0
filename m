From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: addrconf: Fix recursive spin lock call
Date: Sat, 06 Feb 2016 03:09:44 -0500 (EST)
Message-ID: <20160206.030944.1340132870709460187.davem@davemloft.net>
References: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	hannes@stressinduktion.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcBFIJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 03:09:49 -0500
In-Reply-To: <f323a260f8bc358412de59575b058cdf.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: subashab@codeaurora.org
Date: Tue, 2 Feb 2016 02:11:10 -0000

> A rcu stall with the following backtrace was seen on a system with
> forwarding, optimistic_dad and use_optimistic set. To reproduce,
> set these flags and allow ipv6 autoconf.
> 
> This occurs because the device write_lock is acquired while already
> holding the read_lock. Back trace below -
 ...
> v2: do addrconf_dad_kick inside read lock and then acquire write
> lock for ipv6_ifa_notify as suggested by Eric
> 
> Fixes: 7fd2561e4ebdd ("net: ipv6: Add a sysctl to make optimistic
> addresses useful candidates")
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Erik Kline <ek@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

Applied and queued up for -stable, thanks.
