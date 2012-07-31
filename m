From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Restore old dst_free() behavior.
Date: Tue, 31 Jul 2012 14:42:17 -0700 (PDT)
Message-ID: <20120731.144217.708886493005872001.davem@davemloft.net>
References: <20120730.223827.74792864437911339.davem@davemloft.net>
	<1343732903.21269.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab2GaVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 17:42:20 -0400
In-Reply-To: <1343732903.21269.190.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jul 2012 13:08:23 +0200

> [PATCH v2] ipv4: Restore old dst_free() behavior
> 
> commit 404e0a8b6a55 (net: ipv4: fix RCU races on dst refcounts) tried
> to solve a race but added a problem at device/fib dismantle time :
> 
> We really want to call dst_free() as soon as possible, even if sockets
> still have dst in their cache.
> dst_release() calls in free_fib_info_rcu() are not welcomed.
> 
> Root of the problem was that now we also cache output routes (in
> nh_rth_output), we must use call_rcu() instead of call_rcu_bh() in
> rt_free(), because output route lookups are done in process context.
> 
> Based on feedback and initial patch from David Miller (adding another
> call_rcu_bh() call in fib, but it appears it was not the right fix)
> 
> I left the inet_sk_rx_dst_set() helper and added __rcu attributes
> to nh_rth_output and nh_rth_input to better document what is going on in
> this code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
