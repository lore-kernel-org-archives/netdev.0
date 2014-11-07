From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net-next 2/2] mlx4: use napi_complete_done()
Date: Fri, 07 Nov 2014 17:00:53 -0500 (EST)
Message-ID: <20141107.170053.1003349690694025765.davem@redhat.com>
References: <1415337011.13896.103.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ogerlitz@mellanox.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256AbaKGWBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 17:01:01 -0500
In-Reply-To: <1415337011.13896.103.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Nov 2014 21:10:11 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> To enable gro_flush_timeout, a driver has to use napi_complete_done()
> instead of napi_complete().
> 
> Tested:
>  Ran 200 netperf TCP_STREAM from A to B (10Gbe mlx4 link, 8 RX queues)
> 
> Without this feature, we send back about 305,000 ACK per second.
> 
> GRO aggregation ratio is low (811/305 = 2.65 segments per GRO packet)
> 
> Setting a timer of 2000 nsec is enough to increase GRO packet sizes
> and reduce number of ACK packets. (811/19.2 = 42)
> 
> Receiver performs less calls to upper stacks, less wakes up.
> This also reduces cpu usage on the sender, as it receives less ACK
> packets.
> 
> Note that reducing number of wakes up increases cpu efficiency, but can
> decrease QPS, as applications wont have the chance to warmup cpu caches
> doing a partial read of RPC requests/answers if they fit in one skb.
> 
> B:~# sar -n DEV 1 10 | grep eth0 | tail -1
> Average:         eth0 811269.80 305732.30 1199462.57  19705.72      0.00
> 0.00      0.50
> 
> B:~# echo 2000 >/sys/class/net/eth0/gro_flush_timeout
> 
> B:~# sar -n DEV 1 10 | grep eth0 | tail -1
> Average:         eth0 811577.30  19230.80 1199916.51   1239.80      0.00
> 0.00      0.50
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
