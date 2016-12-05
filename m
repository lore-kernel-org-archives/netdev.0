From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] tcp: tsq: performance series
Date: Mon, 05 Dec 2016 14:06:30 -0500 (EST)
Message-ID: <20161205.140630.1112051018980890950.davem@davemloft.net>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbcLETHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 14:07:15 -0500
In-Reply-To: <1480792497-16607-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat,  3 Dec 2016 11:14:49 -0800

> Under very high TX stress, CPU handling NIC TX completions can spend
> considerable amount of cycles handling TSQ (TCP Small Queues) logic.
> 
> This patch series avoids some atomic operations, but most notable
> patch is the 3rd one, allowing other cpus processing ACK packets and
> calling tcp_write_xmit() to grab TCP_TSQ_DEFERRED so that
> tcp_tasklet_func() can skip already processed sockets.
> 
> This avoid lots of lock acquisitions and cache lines accesses,
> particularly under load.
> 
> In v2, I added :
> 
> - tcp_small_queue_check() change to allow 1st and 2nd packets
>   in write queue to be sent, even in the case TX completion of
>   already acknowledged packets did not happen yet.
>   This helps when TX completion coalescing parameters are set
>   even to insane values, and/or busy polling is used.
> 
> - A reorganization of struct sock fields to
>   lower false sharing and increase data locality.
> 
> - Then I moved tsq_flags from tcp_sock to struct sock also
>   to reduce cache line misses during TX completions.
> 
> I measured an overall throughput gain of 22 % for heavy TCP use
> over a single TX queue.

Looks fantastic, series applied, thanks Eric.
