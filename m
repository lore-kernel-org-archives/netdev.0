From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Thu, 13 Oct 2016 09:54:03 -0400 (EDT)
Message-ID: <20161013.095403.1806984759673575482.davem@davemloft.net>
References: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60906 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbcJMNzH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:55:07 -0400
In-Reply-To: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Oct 2016 20:25:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> There are two ways to get tc filters from kernel to user space.
> 
> 1) Full dump (tc_dump_tfilter())
> 2) RTM_GETTFILTER to get one precise filter, reducing overhead.
> 
> The second operation is unfortunately broadcasting its result,
> polluting "tc monitor" users.
> 
> This patch makes sure only the requester gets the result, using
> netlink_unicast() instead of rtnetlink_send()
> 
> Jamal cooked an iproute2 patch to implement "tc filter get" operation,
> but other user space libraries already use RTM_GETTFILTER when a single
> filter is queried, instead of dumping all filters.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

Want me to queue this up for -stable too?
