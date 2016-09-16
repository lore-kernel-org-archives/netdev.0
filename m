From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix a stale ooo_last_skb after a replace
Date: Fri, 16 Sep 2016 04:13:59 -0400 (EDT)
Message-ID: <20160916.041359.1883591254375953017.davem@davemloft.net>
References: <1473832505.22679.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, wygivan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38304 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcIPIOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:14:05 -0400
In-Reply-To: <1473832505.22679.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Sep 2016 22:55:05 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When skb replaces another one in ooo queue, I forgot to also
> update tp->ooo_last_skb as well, if the replaced skb was the last one
> in the queue.
> 
> To fix this, we simply can re-use the code that runs after an insertion,
> trying to merge skbs at the right of current skb.
> 
> This not only fixes the bug, but also remove all small skbs that might
> be a subset of the new one.
> 
> Example:
> 
> We receive segments 2001:3001,  4001:5001
> 
> Then we receive 2001:8001 : We should replace 2001:3001 with the big
> skb, but also remove 4001:50001 from the queue to save space.
> 
> packetdrill test demonstrating the bug
 ...
> Fixes: 9f5afeae5152 ("tcp: use an RB tree for ooo receive queue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Yuchung Cheng <ycheng@google.com>

Applied.
