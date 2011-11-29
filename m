From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid frag allocation for small frames
Date: Tue, 29 Nov 2011 13:23:29 -0500 (EST)
Message-ID: <20111129.132329.1243799125033342977.davem@davemloft.net>
References: <1322556107.2970.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, subramanian.vijay@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab1K2SXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 13:23:32 -0500
In-Reply-To: <1322556107.2970.82.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 09:41:47 +0100

> tcp_sendmsg() uses select_size() helper to choose skb head size when a
> new skb must be allocated.
> 
> If GSO is enabled for the socket, current strategy is to force all
> payload data to be outside of headroom, in PAGE fragments.
> 
> This strategy is not welcome for small packets, wasting memory.
> 
> Experiments show that best results are obtained when using 2048 bytes
> for skb head (This includes the skb overhead and various headers)
> 
> This patch provides better len/truesize ratios for packets sent to
> loopback device, and reduce memory needs for in-flight loopback packets,
> particularly on arches with big pages.
> 
> If a sender sends many 1-byte packets to an unresponsive application,
> receiver rmem_alloc will grow faster and will stop queuing these packets
> sooner, or will collapse its receive queue to free excess memory.
> 
> netperf -t TCP_RR results are improved by ~4 %, and many workloads are
> improved as well (tbench, mysql...)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
