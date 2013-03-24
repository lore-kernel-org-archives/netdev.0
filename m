From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove a WARN_ON() in net_enable_timestamp()
Date: Sun, 24 Mar 2013 17:27:50 -0400 (EDT)
Message-ID: <20130324.172750.346803352885480915.davem@davemloft.net>
References: <1363999108.4431.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chavey@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab3CXV1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:27:52 -0400
In-Reply-To: <1363999108.4431.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Mar 2013 17:38:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> The WARN_ON(in_interrupt()) in net_enable_timestamp() can get false
> positive, in socket clone path, run from softirq context :
 ...
> Its safe at this point because the parent socket owns a reference
> on the netstamp_needed, so we cant have a 0 -> 1 transition, which
> requires to lock a mutex.
> 
> Instead of refining the check, lets remove it, as all known callers
> are safe. If it ever changes in the future, static_key_slow_inc()
> will complain anyway.
> 
> Reported-by: Laurent Chavey <chavey@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
