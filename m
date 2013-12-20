From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: autocork should not hold first packet in write
 queue
Date: Fri, 20 Dec 2013 17:56:52 -0500 (EST)
Message-ID: <20131220.175652.1043712694585011764.davem@davemloft.net>
References: <1387303110.19078.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135Ab3LUBhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 20:37:17 -0500
In-Reply-To: <1387303110.19078.279.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Dec 2013 09:58:30 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Willem noticed a TCP_RR regression caused by TCP autocorking
> on a Mellanox test bed. MLX4_EN_TX_COAL_TIME is 16 us, which can be
> right above RTT between hosts.
> 
> We can receive a ACK for a packet still in NIC TX ring buffer or in a
> softnet completion queue.
> 
> Fix this by always pushing the skb if it is at the head of write queue.
> 
> Also, as TX completion is lockless, it's safer to perform sk_wmem_alloc
> test after setting TSQ_THROTTLED.
> 
> erd:~# MIB="MIN_LATENCY,MEAN_LATENCY,MAX_LATENCY,P99_LATENCY,STDDEV_LATENCY"
> erd:~#  ./netperf -H remote -t TCP_RR -- -o $MIB | tail -n 1
> (repeat 3 times)
 ...
> Reported-by: Willem de Bruijn <willemb@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: f54b311142a9 ("tcp: auto corking")

Applied, but please put "net-next" in the subject line next time.

Thank you.
