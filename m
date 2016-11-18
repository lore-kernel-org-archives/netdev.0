From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: enable busy polling for all sockets
Date: Fri, 18 Nov 2016 10:45:49 -0500 (EST)
Message-ID: <20161118.104549.1326421456884426702.davem@davemloft.net>
References: <1479316242.8455.213.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbcKRPqA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 10:46:00 -0500
In-Reply-To: <1479316242.8455.213.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Nov 2016 09:10:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> UDP busy polling is restricted to connected UDP sockets.
> 
> This is because sk_busy_loop() only takes care of one NAPI context.
> 
> There are cases where it could be extended.
> 
> 1) Some hosts receive traffic on a single NIC, with one RX queue.
> 
> 2) Some applications use SO_REUSEPORT and associated BPF filter
>    to split the incoming traffic on one UDP socket per RX
> queue/thread/cpu
> 
> 3) Some UDP sockets are used to send/receive traffic for one flow, but
> they do not bother with connect()
> 
> 
> This patch records the napi_id of first received skb, giving more
> reach to busy polling.
> 
> Tested:
> 
> lpaa23:~# echo 70 >/proc/sys/net/core/busy_read
> lpaa24:~# echo 70 >/proc/sys/net/core/busy_read
> 
> lpaa23:~# for f in `seq 1 10`; do ./super_netperf 1 -H lpaa24 -t UDP_RR -l 5; done
> 
> Before patch :
>    27867   28870   37324   41060   41215
>    36764   36838   44455   41282   43843
> After patch :
>    73920   73213   70147   74845   71697
>    68315   68028   75219   70082   73707
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
