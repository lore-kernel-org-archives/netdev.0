From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Fix default route failover when
 CONFIG_IPV6_ROUTER_PREF=n
Date: Mon, 03 Dec 2012 15:35:13 -0500 (EST)
Message-ID: <20121203.153513.739323448119933601.davem@davemloft.net>
References: <20121203.135923.1359930693250099951.davem@davemloft.net>
	<1354566414-5752-1-git-send-email-pmarks@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: pmarks@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab2LCUfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 15:35:14 -0500
In-Reply-To: <1354566414-5752-1-git-send-email-pmarks@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Marks <pmarks@google.com>
Date: Mon,  3 Dec 2012 12:26:54 -0800

> I believe this commit from 2008 was incorrect:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=398bcbebb6f721ac308df1e3d658c0029bb74503
> 
> When CONFIG_IPV6_ROUTER_PREF is disabled, the kernel should follow
> RFC4861 section 6.3.6: if no route is NUD_VALID, then traffic should be
> sprayed across all routers (indirectly triggering NUD) until one of them
> becomes NUD_VALID.
> 
> However, the following experiment demonstrates that this does not work:
> 
> 1) Connect to an IPv6 network.
> 2) Change the router's MAC (and link-local) address.
> 
> The kernel will lock onto the first router and never try the new one, even
> if the first becomes unreachable.  This patch fixes the problem by
> allowing rt6_check_neigh() to return 0; if all routers return 0, then
> rt6_select() will fall back to round-robin behavior.
> 
> This patch should have no effect when CONFIG_IPV6_ROUTER_PREF=y.
> 
> Note that rt6_check_neigh() is only used in a boolean context, so I've
> changed its return type accordingly.
> 
> Signed-off-by: Paul Marks <pmarks@google.com>

Applied to net-next, thanks Paul.
