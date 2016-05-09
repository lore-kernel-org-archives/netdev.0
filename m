From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: add memory limitation per queue
Date: Sun, 08 May 2016 23:49:57 -0400 (EDT)
Message-ID: <20160508.234957.1297149850441877380.davem@davemloft.net>
References: <D29AB9B2-D514-4D14-9A16-CFB9ECD05B17@gmx.de>
	<1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, dave.taht@gmail.com, netdev@vger.kernel.org,
	moeller0@gmx.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913AbcEIDuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:50:00 -0400
In-Reply-To: <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 May 2016 08:55:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> On small embedded routers, one wants to control maximal amount of
> memory used by fq_codel, instead of controlling number of packets or
> bytes, since GRO/TSO make these not practical.
> 
> Assuming skb->truesize is accurate, we have to keep track of
> skb->truesize sum for skbs in queue.
> 
> This patch adds a new TCA_FQ_CODEL_MEMORY_LIMIT attribute.
> 
> I chose a default value of 32 MBytes, which looks reasonable even
> for heavy duty usages. (Prior fq_codel users should not be hurt
> when they upgrade their kernels)
> 
> Two fields are added to tc_fq_codel_qd_stats to report :
>  - Current memory usage
>  - Number of drops caused by memory limits
> 
> # tc qd replace dev eth1 root est 1sec 4sec fq_codel memory_limit 4M
> ..
> # tc -s -d qd sh dev eth1
> qdisc fq_codel 8008: root refcnt 257 limit 10240p flows 1024
>  quantum 1514 target 5.0ms interval 100.0ms memory_limit 4Mb ecn 
>  Sent 2083566791363 bytes 1376214889 pkt (dropped 4994406, overlimits 0
> requeues 21705223) 
>  rate 9841Mbit 812549pps backlog 3906120b 376p requeues 21705223 
>   maxpacket 68130 drop_overlimit 4994406 new_flow_count 28855414
>   ecn_mark 0 memory_used 4190048 drop_overmemory 4994406
>   new_flows_len 1 old_flows_len 177
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
