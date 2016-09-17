From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid sk_forward_alloc overflows
Date: Sat, 17 Sep 2016 10:00:32 -0400 (EDT)
Message-ID: <20160917.100032.1050667343503329377.davem@davemloft.net>
References: <1473954526.22679.38.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbcIQOAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:00:34 -0400
In-Reply-To: <1473954526.22679.38.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Sep 2016 08:48:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> A malicious TCP receiver, sending SACK, can force the sender to split
> skbs in write queue and increase its memory usage.
> 
> Then, when socket is closed and its write queue purged, we might
> overflow sk_forward_alloc (It becomes negative)
> 
> sk_mem_reclaim() does nothing in this case, and more than 2GB
> are leaked from TCP perspective (tcp_memory_allocated is not changed)
> 
> Then warnings trigger from inet_sock_destruct() and
> sk_stream_kill_queues() seeing a not zero sk_forward_alloc
> 
> All TCP stack can be stuck because TCP is under memory pressure.
> 
> A simple fix is to preemptively reclaim from sk_mem_uncharge().
> 
> This makes sure a socket wont have more than 2 MB forward allocated,
> after burst and idle period.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
