From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid frag allocation for small frames
Date: Mon, 24 Oct 2011 01:53:00 -0400 (EDT)
Message-ID: <20111024.015300.2004557385108450324.davem@davemloft.net>
References: <1319286237.6180.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991Ab1JXFxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 01:53:04 -0400
In-Reply-To: <1319286237.6180.49.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Oct 2011 14:23:57 +0200

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

Applied, thanks Eric.
