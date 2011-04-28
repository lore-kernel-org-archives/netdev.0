From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] net: dont hold rtnl mutex during netlink
 dump callbacks
Date: Thu, 28 Apr 2011 08:43:37 -0700
Message-ID: <20110428084337.6b54603e@nehalam>
References: <1303980967.3360.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	Remi Denis-Courmont <remi.denis-courmont@nokia.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60314 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760149Ab1D1Pnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 11:43:40 -0400
In-Reply-To: <1303980967.3360.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Apr 2011 10:56:07 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Four years ago, Patrick made a change to hold rtnl mutex during netlink
> dump callbacks.
> 
> I believe it was a wrong move. This slows down concurrent dumps, making
> good old /proc/net/ files faster than rtnetlink in some situations.
> 
> This occurred to me because one "ip link show dev ..." was _very_ slow
> on a workload adding/removing network devices in background.
> 
> All dump callbacks are able to use RCU locking now, so this patch does
> roughly a revert of commits :
> 
> 1c2d670f366 : [RTNETLINK]: Hold rtnl_mutex during netlink dump callbacks
> 6313c1e0992 : [RTNETLINK]: Remove unnecessary locking in dump callbacks
> 
> This let writers fight for rtnl mutex and readers going full speed.
> 
> It also takes care of phonet : phonet_route_get() is now called from rcu
> read section. I renamed it to phonet_route_get_rcu()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Remi Denis-Courmont <remi.denis-courmont@nokia.com>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
