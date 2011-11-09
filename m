From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: PKTINFO doesnt need dst reference
Date: Wed, 09 Nov 2011 16:37:08 -0500 (EST)
Message-ID: <20111109.163708.2156133928191684256.davem@davemloft.net>
References: <1320673364.3020.21.camel@bwh-desktop>
	<1320676422.2361.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, pstaszewski@itcare.pl,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab1KIVhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 16:37:19 -0500
In-Reply-To: <1320859475.3916.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Nov 2011 18:24:35 +0100

> [PATCH net-next] ipv4: IP_PKTINFO doesnt need dst reference
> 
> When a socket uses IP_PKTINFO notifications, we currently force a dst
> reference for each received skb. Reader has to access dst to get needed
> information (rt_iif & rt_spec_dst) and must release dst reference.
> 
> We also forced a dst reference if skb was put in socket backlog, even
> without IP_PKTINFO handling. This happens under stress/load.
> 
> We can instead store the needed information in skb->cb[], so that only
> softirq handler really access dst, improving cache hit ratios.
> 
> This removes two atomic operations per packet, and false sharing as
> well.
> 
> On a benchmark using a mono threaded receiver (doing only recvmsg()
> calls), I can reach 720.000 pps instead of 570.000 pps.
> 
> IP_PKTINFO is typically used by DNS servers, and any multihomed aware
> UDP application.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, if it compiles I'll push it out to net-next :-)
