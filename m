From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: do not create inetpeer on SYNACK message
Date: Fri, 01 Jun 2012 14:24:12 -0400 (EDT)
Message-ID: <20120601.142412.1490248352687260207.davem@davemloft.net>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	<1338534026.2760.1451.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	brouer@redhat.com, ncardwell@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690Ab2FASYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 14:24:14 -0400
In-Reply-To: <1338534026.2760.1451.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Jun 2012 09:00:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Another problem on SYNFLOOD/DDOS attack is the inetpeer cache getting
> larger and larger, using lots of memory and cpu time.
> 
> tcp_v4_send_synack()
> ->inet_csk_route_req()
>  ->ip_route_output_flow()
>   ->rt_set_nexthop()
>    ->rt_init_metrics()
>     ->inet_getpeer( create = true)
> 
> This is a side effect of commit a4daad6b09230 (net: Pre-COW metrics for
> TCP) added in 2.6.39
> 
> Possible solution : 
> 
> Instruct inet_csk_route_req() to remove FLOWI_FLAG_PRECOW_METRICS 
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This is definitely the right thing to do.

Applied, thanks Eric.
